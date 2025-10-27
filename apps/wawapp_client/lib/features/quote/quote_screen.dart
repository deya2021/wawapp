import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'providers/quote_provider.dart';
import 'models/latlng.dart' as quote_lat_lng;
import '../track/models/order.dart';

enum Selection { pickup, dropoff }

class QuoteScreen extends ConsumerWidget {
  const QuoteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteState = ref.watch(quoteProvider);
    return _QuoteView(pickup: quoteState.pickup, dropoff: quoteState.dropoff);
  }
}

class _QuoteView extends ConsumerStatefulWidget {
  const _QuoteView({required this.pickup, required this.dropoff});
  final quote_lat_lng.LatLng? pickup;
  final quote_lat_lng.LatLng? dropoff;

  @override
  ConsumerState<_QuoteView> createState() => _QuoteViewState();
}

class _QuoteViewState extends ConsumerState<_QuoteView> {
  GoogleMapController? _map;
  Selection _currentSelection = Selection.pickup;
  static const _fallback = LatLng(18.0783, -15.9744); // Nouakchott
  bool _hasQuote = false;
  int? _meters;
  int? _price;

  void _onMapTap(LatLng pos) {
    final quotePos = quote_lat_lng.LatLng(pos.latitude, pos.longitude);
    if (_currentSelection == Selection.pickup) {
      ref.read(quoteProvider.notifier).setPickup(quotePos);
    } else {
      ref.read(quoteProvider.notifier).setDropoff(quotePos);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickup = widget.pickup;
    final dropoff = widget.dropoff;

    final camPos = CameraPosition(
      target: pickup != null
          ? LatLng(pickup.latitude, pickup.longitude)
          : _fallback,
      zoom: 12,
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('احسب السعر'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GoogleMap(
                initialCameraPosition: camPos,
                onTap: _onMapTap,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                markers: {
                  if (pickup != null)
                    Marker(
                      markerId: const MarkerId('pickup'),
                      position: LatLng(pickup.latitude, pickup.longitude),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen),
                      infoWindow: const InfoWindow(title: 'الاستلام'),
                    ),
                  if (dropoff != null)
                    Marker(
                      markerId: const MarkerId('dropoff'),
                      position: LatLng(dropoff.latitude, dropoff.longitude),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed),
                      infoWindow: const InfoWindow(title: 'التسليم'),
                    ),
                },
              ),
            ),
            const SizedBox(height: 8),
            _BottomPanel(
              pickup: pickup,
              dropoff: dropoff,
              currentSelection: _currentSelection,
              onSelectionChanged: (selection) =>
                  setState(() => _currentSelection = selection),
              onQuote: (meters, price) {
                setState(() {
                  _hasQuote = true;
                  _meters = meters;
                  _price = price;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomPanel extends ConsumerStatefulWidget {
  const _BottomPanel({
    required this.pickup,
    required this.dropoff,
    required this.currentSelection,
    required this.onSelectionChanged,
    required this.onQuote,
  });
  final quote_lat_lng.LatLng? pickup;
  final quote_lat_lng.LatLng? dropoff;
  final Selection currentSelection;
  final ValueChanged<Selection> onSelectionChanged;
  final void Function(int meters, int price) onQuote;

  @override
  ConsumerState<_BottomPanel> createState() => _BottomPanelState();
}

class _BottomPanelState extends ConsumerState<_BottomPanel> {
  bool _loading = false;
  String? _priceText;
  String? _distanceKmText;
  int? _meters;
  int? _price;

  bool get _hasBoth => widget.pickup != null && widget.dropoff != null;
  bool get _hasQuote => _meters != null && _price != null;

  String formatLatLng(quote_lat_lng.LatLng? p) {
    if (p == null) return 'اضغط على الخريطة لاختيار الموقع';
    return '(${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)})';
  }

  Future<void> _calc() async {
    if (!_hasBoth) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر موقعي الاستلام والتسليم أولاً')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      // Simulate distance calculation using Geolocator
      final p1 = widget.pickup!;
      final p2 = widget.dropoff!;
      final distanceInMeters = (((p1.latitude - p2.latitude).abs() +
                  (p1.longitude - p2.longitude).abs()) *
              111000)
          .round();

      if (distanceInMeters <= 0) {
        throw Exception('لم نستطع حساب المسافة');
      }

      final km = (distanceInMeters / 1000).toStringAsFixed(1);
      final price = 50 +
          (distanceInMeters / 1000 * 20).round() +
          10; // Base fare + per km + service fee

      setState(() {
        _loading = false;
        _meters = distanceInMeters;
        _price = price;
        _distanceKmText = '$km كم';
        _priceText = '$price أوقية';
      });

      widget.onQuote(distanceInMeters, price);
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _requestRide() async {
    if (!_hasBoth || !_hasQuote) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('احسب السعر أولاً ثم اطلب الرحلة')),
      );
      return;
    }
    try {
      final p = widget.pickup!;
      final d = widget.dropoff!;
      final order = Order(
        distanceKm: _meters! / 1000.0,
        price: _price!.toDouble(),
        pickupAddress: formatLatLng(p),
        dropoffAddress: formatLatLng(d),
        pickup: LatLng(p.latitude, p.longitude),
        dropoff: LatLng(d.latitude, d.longitude),
      );
      if (mounted) {
        context.push('/track', extra: order);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل طلب الرحلة: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final quoteState = ref.watch(quoteProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _LocationField(
                  label: 'الاستلام',
                  value: formatLatLng(widget.pickup),
                  isSelected: widget.currentSelection == Selection.pickup,
                  onTap: () => widget.onSelectionChanged(Selection.pickup),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LocationField(
                  label: 'التسليم',
                  value: formatLatLng(widget.dropoff),
                  isSelected: widget.currentSelection == Selection.dropoff,
                  onTap: () => widget.onSelectionChanged(Selection.dropoff),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // إذا كان هناك سعر، نخفي زر "احسب السعر" ونظهر زر "أعد الحساب" صغيراً
          if (!_hasQuote)
            ElevatedButton(
              onPressed: _loading ? null : _calc,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('احسب السعر'),
            )
          else
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _loading ? null : _calc,
                child: const Text('أعد الحساب'),
              ),
            ),
          if (_priceText != null) ...[
            const SizedBox(height: 8),
            Text(
              'السعر المقدر: $_priceText',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'المسافة: $_distanceKmText',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
          ],
          // زر طلب الرحلة يعمل فقط بعد وجود عرض سعر صالح
          ElevatedButton(
            onPressed: _hasQuote ? _requestRide : null,
            child: const Text('طلب الرحلة'),
          ),
        ],
      ),
    );
  }
}

class _LocationField extends StatelessWidget {
  const _LocationField({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.blue : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 10),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
