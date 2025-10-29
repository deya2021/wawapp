import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../../l10n/app_localizations.dart';
import '../../core/location/location_service.dart';
import 'models/order.dart';
import 'widgets/order_status_timeline.dart';

class TrackScreen extends StatefulWidget {
  final Order? order;
  const TrackScreen({super.key, this.order});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  GoogleMapController? _mapController;
  StreamSubscription? _positionSubscription;
  LatLng? _currentPosition;

  static const CameraPosition _nouakchott = CameraPosition(
    target: LatLng(18.0735, -15.9582),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  void _startLocationTracking() {
    _positionSubscription = LocationService.getPositionStream().listen(
      (position) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(_currentPosition!),
        );
      },
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    if (_currentPosition != null) {
      markers.add(Marker(
        markerId: const MarkerId('current'),
        position: _currentPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'موقعك الحالي'),
      ));
    }

    if (widget.order?.pickup != null) {
      markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(
            widget.order!.pickup.latitude, widget.order!.pickup.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow:
            InfoWindow(title: 'الاستلام', snippet: widget.order!.pickupAddress),
      ));
    }

    if (widget.order?.dropoff != null) {
      markers.add(Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(
            widget.order!.dropoff.latitude, widget.order!.dropoff.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow:
            InfoWindow(title: 'التسليم', snippet: widget.order!.dropoffAddress),
      ));
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(kReleaseMode ? l10n.track : '${l10n.track} • DEBUG'),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                initialCameraPosition: widget.order?.pickup != null
                    ? CameraPosition(
                        target: LatLng(widget.order!.pickup.latitude,
                            widget.order!.pickup.longitude),
                        zoom: 14.0,
                      )
                    : _nouakchott,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: _buildMarkers(),
                compassEnabled: true,
                mapToolbarEnabled: false,
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.order != null) ...[
                      OrderStatusTimeline(
                          status: widget.order!.status ?? 'pending'),
                      const SizedBox(height: 12),
                      Text('الحالة: ${widget.order!.status ?? 'pending'}',
                          style: Theme.of(context).textTheme.titleMedium),
                    ] else
                      Text('الحالة: في الطريق',
                          style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    const Text('السائق: ---'),
                    const Text('المركبة: ---'),
                    Text(
                        'السعر: ${widget.order?.price.round() ?? '---'} ${l10n.currency}'),
                    if (widget.order != null) ...[
                      Text('المسافة: ${widget.order!.distanceKm} كم'),
                      Text('من: ${widget.order!.pickupAddress}'),
                      Text('إلى: ${widget.order!.dropoffAddress}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          final trackUrl =
                              'https://wawapp.page.link/track/${widget.order?.hashCode ?? 'unknown'}';
                          await Clipboard.setData(
                              ClipboardData(text: trackUrl));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('تم نسخ رابط التتبع')),
                            );
                          }
                        },
                        child: const Text('نسخ رابط التتبع'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
