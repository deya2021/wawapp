import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

/// Ensures location service & permission are in a usable state
/// before any screen tries to read the position.
Future<void> ensureLocationReady() async {
  // 1) Service (GPS) enabled?
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Non-blocking: try to open settings and let the app continue.
    // The map will still load; user can enable GPS from the prompt.
    await Geolocator.openLocationSettings();
    debugPrint('WawApp/Location: service disabled → prompted settings');
  }

  // 2) Permission flow
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.deniedForever) {
    // Guide the user to app settings if permanently denied.
    await Geolocator.openAppSettings();
    debugPrint('WawApp/Location: deniedForever → prompted app settings');
  }
}