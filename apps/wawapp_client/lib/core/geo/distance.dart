import 'package:geolocator/geolocator.dart';

double computeDistanceKm(
    {required double lat1,
    required double lng1,
    required double lat2,
    required double lng2}) {
  final m = Geolocator.distanceBetween(lat1, lng1, lat2, lng2); // meters
  return double.parse((m / 1000).toStringAsFixed(1)); // one decimal km
}
