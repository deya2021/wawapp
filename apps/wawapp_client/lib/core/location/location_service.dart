import 'dart:async';
import 'dart:developer' as dev;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  static const String _tag = 'WAWAPP_LOC';

  static Future<bool> checkPermissions() async {
    dev.log('Checking location permissions...', name: _tag);
    LocationPermission permission = await Geolocator.checkPermission();
    dev.log('Current permission: $permission', name: _tag);

    if (permission == LocationPermission.denied) {
      dev.log('Requesting location permission...', name: _tag);
      permission = await Geolocator.requestPermission();
      dev.log('Permission after request: $permission', name: _tag);
    }

    final hasPermission = permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
    dev.log('Has location permission: $hasPermission', name: _tag);
    return hasPermission;
  }

  static Future<Position?> getCurrentPosition() async {
    try {
      dev.log('Getting current position...', name: _tag);
      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        dev.log('Location permission denied', name: _tag);
        return null;
      }

      final isEnabled = await Geolocator.isLocationServiceEnabled();
      dev.log('Location services enabled: $isEnabled', name: _tag);
      if (!isEnabled) {
        dev.log('Location services disabled', name: _tag);
        return null;
      }

      dev.log('Requesting GPS position...', name: _tag);
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      dev.log('Got position: ${position.latitude}, ${position.longitude}',
          name: _tag);
      return position;
    } catch (e) {
      dev.log('Error getting current position: $e', name: _tag);
      return null;
    }
  }

  static Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  static Future<String> resolveAddressFromLatLng(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng)
          .timeout(const Duration(seconds: 5));

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[];

        if (place.street?.isNotEmpty == true) {
          parts.add(place.street!);
        }
        if (place.locality?.isNotEmpty == true) {
          parts.add(place.locality!);
        }
        if (place.administrativeArea?.isNotEmpty == true) {
          parts.add(place.administrativeArea!);
        }

        return parts.isNotEmpty ? parts.join(', ') : 'موقع غير محدد';
      }

      return 'موقع غير محدد';
    } catch (e) {
      dev.log('Reverse geocoding error: $e', name: _tag);
      return 'تعذّر جلب العنوان. تحقّق من الإنترنت أو فعّل الموقع.';
    }
  }

  static Future<LatLng?> resolveLatLngFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address)
          .timeout(const Duration(seconds: 5));

      if (locations.isNotEmpty) {
        final location = locations.first;
        return LatLng(location.latitude, location.longitude);
      }

      return null;
    } catch (e) {
      dev.log('Forward geocoding error: $e', name: _tag);
      return null;
    }
  }
}
