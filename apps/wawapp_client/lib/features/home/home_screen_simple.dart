import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../generated/l10n.dart';
import '../quote/providers/quote_provider.dart';
import '../quote/models/latlng.dart' as QuoteLatLng;
import '../../core/geo/distance.dart';
import '../../core/pricing/pricing.dart';

class HomeScreenSimple extends ConsumerStatefulWidget {
  const HomeScreenSimple({super.key});

  @override
  ConsumerState<HomeScreenSimple> createState() => _HomeScreenSimpleState();
}

class _HomeScreenSimpleState extends ConsumerState<HomeScreenSimple> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();

  // مواقع افتراضية لنواكشوط
  final _nouakchottCenter = const QuoteLatLng.LatLng(18.0735, -15.9582);
  final _nouakchottAirport = const QuoteLatLng.LatLng(18.0969, -15.9497);

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  void _setPickupLocation() {
    _pickupController.text = 'وسط نواكشوط';
    ref.read(quoteProvider.notifier).setPickup(_nouakchottCenter);
  }

  void _setDropoffLocation() {
    _dropoffController.text = 'مطار نواكشوط';
    ref.read(quoteProvider.notifier).setDropoff(_nouakchottAirport);
  }

  void _calculateQuote() {
    final pickup = _nouakchottCenter;
    final dropoff = _nouakchottAirport;

    final km = computeDistanceKm(
      lat1: pickup.latitude,
      lng1: pickup.longitude,
      lat2: dropoff.latitude,
      lng2: dropoff.longitude,
    );
    final price = computePrice(km);

    ref.read(quoteProvider.notifier).setDistance(km);
    ref.read(quoteProvider.notifier).setPrice(price.round());

    context.push('/quote');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final quoteState = ref.watch(quoteProvider);

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.appTitle),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // خريطة مؤقتة
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, size: 64, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('الخريطة ستكون متاحة قريباً'),
                        Text('يمكنك استخدام المواقع الافتراضية أدناه'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // نقطة الاستلام
                TextField(
                  controller: _pickupController,
                  decoration: InputDecoration(
                    labelText: l10n.pickup,
                    prefixIcon: const Icon(Icons.my_location),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add_location),
                      onPressed: _setPickupLocation,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: _setPickupLocation,
                ),
                const SizedBox(height: 16),

                // نقطة التسليم
                TextField(
                  controller: _dropoffController,
                  decoration: InputDecoration(
                    labelText: l10n.dropoff,
                    prefixIcon: const Icon(Icons.location_on),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add_location),
                      onPressed: _setDropoffLocation,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: _setDropoffLocation,
                ),
                const SizedBox(height: 24),

                // زر حساب السعر
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (quoteState.pickup != null &&
                            quoteState.dropoff != null)
                        ? _calculateQuote
                        : null,
                    child: const Text('احسب السعر'),
                  ),
                ),

                const SizedBox(height: 16),

                // معلومات إضافية
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'المواقع المتاحة حالياً:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text('• وسط نواكشوط'),
                        const Text('• مطار نواكشوط'),
                        const SizedBox(height: 8),
                        Text(
                          'ملاحظة: هذه نسخة تجريبية. الخرائط التفاعلية ستكون متاحة قريباً.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
