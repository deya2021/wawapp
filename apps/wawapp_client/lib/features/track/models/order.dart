import 'package:google_maps_flutter/google_maps_flutter.dart';

class Order {
  final double distanceKm;
  final double price;
  final String pickupAddress;
  final String dropoffAddress;
  final LatLng pickup;
  final LatLng dropoff;

  const Order({
    required this.distanceKm,
    required this.price,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.pickup,
    required this.dropoff,
  });

  Map<String, dynamic> toMap() => {
        'distanceKm': distanceKm,
        'price': price,
        'pickupAddress': pickupAddress,
        'dropoffAddress': dropoffAddress,
        'pickup': {'lat': pickup.latitude, 'lng': pickup.longitude},
        'dropoff': {'lat': dropoff.latitude, 'lng': dropoff.longitude},
      };
}
