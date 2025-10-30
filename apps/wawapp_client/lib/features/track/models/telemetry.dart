import 'package:cloud_firestore/cloud_firestore.dart';

class CurrentLocation {
  final double lat;
  final double lng;
  final Timestamp ts;

  const CurrentLocation({
    required this.lat,
    required this.lng,
    required this.ts,
  });

  Map<String, dynamic> toMap() => {
        'lat': lat,
        'lng': lng,
        'ts': ts,
      };

  factory CurrentLocation.fromMap(Map<String, dynamic> map) => CurrentLocation(
        lat: (map['lat'] ?? 0.0).toDouble(),
        lng: (map['lng'] ?? 0.0).toDouble(),
        ts: map['ts'] ?? Timestamp.now(),
      );
}
