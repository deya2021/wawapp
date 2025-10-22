import 'package:flutter_test/flutter_test.dart';
import 'package:wawapp_client/features/quote/models/latlng.dart';
import 'package:wawapp_client/features/quote/utils/haversine.dart';

void main() {
  group('Haversine Distance Tests', () {
    test('should calculate distance between two points correctly', () {
      // Nouakchott to nearby location (approximately 1.5 km)
      const point1 = LatLng(18.0735, -15.9582);
      const point2 = LatLng(18.0835, -15.9682);
      
      final distance = distanceKm(point1, point2);
      
      expect(distance, greaterThan(1.0));
      expect(distance, lessThan(2.0));
    });

    test('should return 0 for same points', () {
      const point = LatLng(18.0735, -15.9582);
      
      final distance = distanceKm(point, point);
      
      expect(distance, equals(0.0));
    });
  });
}