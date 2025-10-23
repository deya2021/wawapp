import 'dart:math';
import '../models/latlng.dart';

double distanceKm(LatLng a, LatLng b) {
  const double earthRadius = 6371.0; // Earth's radius in kilometers

  double lat1Rad = a.latitude * pi / 180;
  double lat2Rad = b.latitude * pi / 180;
  double deltaLatRad = (b.latitude - a.latitude) * pi / 180;
  double deltaLngRad = (b.longitude - a.longitude) * pi / 180;

  double haversine = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
      cos(lat1Rad) * cos(lat2Rad) * sin(deltaLngRad / 2) * sin(deltaLngRad / 2);

  double c = 2 * atan2(sqrt(haversine), sqrt(1 - haversine));

  return earthRadius * c;
}
