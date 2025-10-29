# Location Implementation - Unified Diff

## Files Modified/Created

### 1. pubspec.yaml
```diff
   geolocator: ^10.1.0
+  geocoding: ^2.1.1
   google_maps_flutter: ^2.5.0
```

### 2. android/app/src/main/AndroidManifest.xml
```diff
-        <meta-data android:name="com.google.android.geo.API_KEY"
-                   android:value="AIzaSyA8Soo8cPB0wzFBsCe_G1_WlQD-r8Kn3uI"/>
+        <meta-data android:name="com.google.android.geo.API_KEY"
+                   android:value="@string/google_maps_api_key"/>
```

### 3. android/app/src/main/res/values/strings.xml (NEW)
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="google_maps_api_key">REPLACE_WITH_YOUR_KEY</string>
</resources>
```

### 4. lib/core/location/location_service.dart (NEW)
```dart
import 'dart:async';
import 'dart:developer' as dev;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  static const String _tag = 'WAWAPP_LOC';

  static Future<bool> checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
  }

  static Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        dev.log('Location permission denied', name: _tag);
        return null;
      }

      final isEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isEnabled) {
        dev.log('Location services disabled', name: _tag);
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
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
```

### 5. lib/features/map/pick_route_controller.dart
```diff
-import '../../utils/geocoding_helper.dart';
+import '../../core/location/location_service.dart';

-    final address = await GeocodingHelper.reverseGeocode(location);
+    final address = await LocationService.resolveAddressFromLatLng(
+        location.latitude, location.longitude);

+  Future<void> setCurrentLocation() async {
+    final position = await LocationService.getCurrentPosition();
+    if (position != null) {
+      final location = MapLatLng(position.latitude, position.longitude);
+      await setLocationFromTap(location);
+    }
+  }
+
+  Future<void> setAddressFromText(String address, bool isPickup) async {
+    final location = await LocationService.resolveLatLngFromAddress(address);
+    if (location != null) {
+      if (isPickup) {
+        state = state.copyWith(pickup: location, pickupAddress: address);
+      } else {
+        state = state.copyWith(dropoff: location, dropoffAddress: address);
+      }
+      _calculateDistance();
+    }
+  }
```

### 6. lib/features/home/home_screen.dart
```diff
+import 'dart:developer' as dev;
-import 'package:geolocator/geolocator.dart';
+import '../../core/location/location_service.dart';

-  Future<void> _checkLocationPermission() async {
-    setState(() {
-      _errorMessage = 'جاري تحديد موقعك...';
-    });
-
-    try {
-      LocationPermission permission = await Geolocator.checkPermission();
-
-      if (permission == LocationPermission.denied) {
-        permission = await Geolocator.requestPermission();
-      }
-
-      if (permission == LocationPermission.whileInUse ||
-          permission == LocationPermission.always) {
-        setState(() {
-          _hasLocationPermission = true;
-          _errorMessage = null;
-        });
-        await _getCurrentLocation();
-      } else if (permission == LocationPermission.deniedForever) {
-        setState(() {
-          _errorMessage = null;
-        });
-        if (mounted) {
-          ScaffoldMessenger.of(context).showSnackBar(
-            SnackBar(
-              content: const Text(
-                  'يرجى تفعيل إذن الموقع من الإعدادات لتحديد موقعك الحالي'),
-              action: SnackBarAction(
-                label: 'الإعدادات',
-                onPressed: () => Geolocator.openAppSettings(),
-              ),
-            ),
-          );
-        }
-      } else {
-        setState(() {
-          _errorMessage = null;
-        });
-        if (mounted) {
-          ScaffoldMessenger.of(context).showSnackBar(
-            const SnackBar(
-              content: Text('يمكنك استخدام الخريطة يدوياً لتحديد المواقع'),
-            ),
-          );
-        }
-      }
-    } catch (e) {
-      setState(() {
-        _errorMessage = null;
-      });
-      if (mounted) {
-        ScaffoldMessenger.of(context).showSnackBar(
-          const SnackBar(
-            content: Text('تعذر الوصول للموقع. يمكنك استخدام الخريطة يدوياً'),
-          ),
-        );
-      }
-    }
-  }
+  Future<void> _checkLocationPermission() async {
+    setState(() {
+      _errorMessage = 'جاري تحديد موقعك...';
+    });
+
+    final hasPermission = await LocationService.checkPermissions();
+    
+    if (hasPermission) {
+      setState(() {
+        _hasLocationPermission = true;
+        _errorMessage = null;
+      });
+      await _getCurrentLocation();
+    } else {
+      setState(() {
+        _errorMessage = null;
+      });
+      if (mounted) {
+        ScaffoldMessenger.of(context).showSnackBar(
+          const SnackBar(
+            content: Text('يمكنك استخدام الخريطة يدوياً لتحديد المواقع'),
+          ),
+        );
+      }
+    }
+  }

-  Future<void> _getCurrentLocation() async {
-    try {
-      Position position = await Geolocator.getCurrentPosition(
-        desiredAccuracy: LocationAccuracy.high,
-        timeLimit: const Duration(seconds: 10),
-      );
-      _mapController?.animateCamera(
-        CameraUpdate.newLatLng(
-          LatLng(position.latitude, position.longitude),
-        ),
-      );
-    } catch (e) {
-      if (mounted) {
-        ScaffoldMessenger.of(context).showSnackBar(
-          const SnackBar(
-            content: Text(
-                'لم يتمكن من تحديد موقعك الحالي. يرجى التأكد من تفعيل GPS'),
-            duration: Duration(seconds: 3),
-          ),
-        );
-      }
-    }
-  }
+  Future<void> _getCurrentLocation() async {
+    final position = await LocationService.getCurrentPosition();
+    if (position != null) {
+      _mapController?.animateCamera(
+        CameraUpdate.newLatLng(
+          LatLng(position.latitude, position.longitude),
+        ),
+      );
+    } else if (mounted) {
+      ScaffoldMessenger.of(context).showSnackBar(
+        const SnackBar(
+          content: Text('لم يتمكن من تحديد موقعك الحالي. يرجى التأكد من تفعيل GPS'),
+          duration: Duration(seconds: 3),
+        ),
+      );
+    }
+  }

-                      prefixIcon: IconButton(
-                        icon: const Icon(Icons.my_location),
-                        onPressed: _getCurrentLocation,
-                      ),
+                      prefixIcon: IconButton(
+                        icon: const Icon(Icons.my_location),
+                        onPressed: () async {
+                          await ref.read(routePickerProvider.notifier).setCurrentLocation();
+                        },
+                      ),

-                              print('Distance: ${km}km, Price: ${price}MRU');
+                              dev.log('Distance: ${km}km, Price: ${price}MRU', name: 'WAWAPP_LOC');
```

### 7. lib/features/track/track_screen.dart
```diff
+import 'package:google_maps_flutter/google_maps_flutter.dart';
+import 'dart:async';
+import '../../core/location/location_service.dart';

-class TrackScreen extends StatelessWidget {
+class TrackScreen extends StatefulWidget {
   final Order? order;
   const TrackScreen({super.key, this.order});

+  @override
+  State<TrackScreen> createState() => _TrackScreenState();
+}
+
+class _TrackScreenState extends State<TrackScreen> {
+  GoogleMapController? _mapController;
+  StreamSubscription? _positionSubscription;
+  LatLng? _currentPosition;
+  
+  static const CameraPosition _nouakchott = CameraPosition(
+    target: LatLng(18.0735, -15.9582),
+    zoom: 14.0,
+  );
+
+  @override
+  void initState() {
+    super.initState();
+    _startLocationTracking();
+  }
+
+  @override
+  void dispose() {
+    _positionSubscription?.cancel();
+    super.dispose();
+  }
+
+  void _startLocationTracking() {
+    _positionSubscription = LocationService.getPositionStream().listen(
+      (position) {
+        setState(() {
+          _currentPosition = LatLng(position.latitude, position.longitude);
+        });
+        _mapController?.animateCamera(
+          CameraUpdate.newLatLng(_currentPosition!),
+        );
+      },
+    );
+  }
+
+  Set<Marker> _buildMarkers() {
+    final markers = <Marker>{};
+
+    if (_currentPosition != null) {
+      markers.add(Marker(
+        markerId: const MarkerId('current'),
+        position: _currentPosition!,
+        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
+        infoWindow: const InfoWindow(title: 'موقعك الحالي'),
+      ));
+    }
+
+    if (widget.order?.pickup != null) {
+      markers.add(Marker(
+        markerId: const MarkerId('pickup'),
+        position: LatLng(widget.order!.pickup.latitude, widget.order!.pickup.longitude),
+        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
+        infoWindow: InfoWindow(title: 'الاستلام', snippet: widget.order!.pickupAddress),
+      ));
+    }
+
+    if (widget.order?.dropoff != null) {
+      markers.add(Marker(
+        markerId: const MarkerId('dropoff'),
+        position: LatLng(widget.order!.dropoff.latitude, widget.order!.dropoff.longitude),
+        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
+        infoWindow: InfoWindow(title: 'التسليم', snippet: widget.order!.dropoffAddress),
+      ));
+    }
+
+    return markers;
+  }

   @override
   Widget build(BuildContext context) {

-            Expanded(
-              flex: 2,
-              child: Container(
-                color: Colors.grey[300],
-                child: const Center(
-                  child: Icon(
-                    Icons.navigation,
-                    size: 64,
-                    color: Colors.blue,
-                  ),
-                ),
-              ),
-            ),
+            Expanded(
+              flex: 2,
+              child: GoogleMap(
+                onMapCreated: (GoogleMapController controller) {
+                  _mapController = controller;
+                },
+                initialCameraPosition: widget.order?.pickup != null
+                    ? CameraPosition(
+                        target: LatLng(widget.order!.pickup.latitude, widget.order!.pickup.longitude),
+                        zoom: 14.0,
+                      )
+                    : _nouakchott,
+                myLocationEnabled: true,
+                myLocationButtonEnabled: true,
+                markers: _buildMarkers(),
+                compassEnabled: true,
+                mapToolbarEnabled: false,
+              ),
+            ),

-                    Text(
-                        'السعر: ${order?.price.round() ?? '---'} ${l10n.currency}'),
-                    if (order != null) ...[
-                      Text('المسافة: ${order!.distanceKm} كم'),
-                      Text('من: ${order!.pickupAddress}'),
-                      Text('إلى: ${order!.dropoffAddress}'),
-                    ],
+                    Text(
+                        'السعر: ${widget.order?.price.round() ?? '---'} ${l10n.currency}'),
+                    if (widget.order != null) ...[
+                      Text('المسافة: ${widget.order!.distanceKm} كم'),
+                      Text('من: ${widget.order!.pickupAddress}'),
+                      Text('إلى: ${widget.order!.dropoffAddress}'),
+                    ],
```

## Setup Instructions

### 1. Google Maps API Key
Replace `REPLACE_WITH_YOUR_KEY` in `android/app/src/main/res/values/strings.xml` with your actual Google Maps API key.

### 2. Google Cloud APIs to Enable
- Maps SDK for Android
- Geocoding API  
- Places API

### 3. Testing Steps
1. Grant location permission when prompted
2. Tap "current location" button (📍) in pickup field
3. Verify current location is captured and address is resolved
4. Type an address in delivery field
5. Tap "احسب السعر" button
6. Navigate to track screen and verify live location tracking

### 4. Commit Message
```
feat(location): stable geolocation + reverse-geocoding + tracking with minimal changes
```