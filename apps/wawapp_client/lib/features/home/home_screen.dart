import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  GoogleMapController? _mapController;
  static const CameraPosition _nouakchott = CameraPosition(
    target: LatLng(18.0735, -15.9582),
    zoom: 14.0,
  );
  bool _hasLocationPermission = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        setState(() {
          _hasLocationPermission = true;
        });
        _getCurrentLocation();
      } else {
        setState(() {
          _errorMessage = 'Location permission denied';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking location: $e';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
    } catch (e) {
      // Fallback to Nouakchott if current location fails
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(l10n.appTitle),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                children: [
                  Container(
                    height: 300,
                    child: _errorMessage != null
                        ? Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.map, size: 64, color: Colors.grey),
                                  const SizedBox(height: 8),
                                  Text(_errorMessage!, textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          )
                        : GoogleMap(
                            onMapCreated: (GoogleMapController controller) {
                              _mapController = controller;
                            },
                            initialCameraPosition: _nouakchott,
                            myLocationEnabled: _hasLocationPermission,
                            myLocationButtonEnabled: _hasLocationPermission,
                          ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    decoration: InputDecoration(
                      labelText: l10n.pickup,
                      prefixIcon: const Icon(Icons.my_location),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: l10n.dropoff,
                      prefixIcon: const Icon(Icons.location_on),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/quote');
                      },
                      child: Text(l10n.get_quote),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}