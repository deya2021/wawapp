import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../generated/l10n.dart';
import '../map/pick_route_controller.dart';
import '../map/places_autocomplete_sheet.dart';
import '../quote/providers/quote_provider.dart';
import '../quote/models/latlng.dart' as QuoteLatLng;
import '../../core/geo/distance.dart';
import '../../core/pricing/pricing.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  GoogleMapController? _mapController;
  static const CameraPosition _nouakchott = CameraPosition(
    target: LatLng(18.0735, -15.9582),
    zoom: 14.0,
  );
  bool _hasLocationPermission = false;
  String? _errorMessage;
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
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
          _errorMessage = 'الرجاء تفعيل إذن الموقع لمتابعة التحديد';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_errorMessage!)),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في الوصول للموقع';
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

  void _onMapTap(LatLng location) async {
    await ref.read(routePickerProvider.notifier).setLocationFromTap(location);
    _mapController?.animateCamera(CameraUpdate.newLatLng(location));
  }

  void _showPlacesSheet(bool isPickup) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PlacesAutocompleteSheet(
        isPickup: isPickup,
        onLocationSelected: () {
          // Update text controllers when location is selected
          final state = ref.read(routePickerProvider);
          _pickupController.text = state.pickupAddress;
          _dropoffController.text = state.dropoffAddress;
        },
      ),
    );
  }

  Set<Marker> _buildMarkers(RoutePickerState state) {
    final markers = <Marker>{};

    final pickup = state.pickup;
    final dropoff = state.dropoff;

    if (pickup != null) {
      markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: pickup,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: 'الاستلام', snippet: state.pickupAddress),
      ));
    }

    if (dropoff != null) {
      markers.add(Marker(
        markerId: const MarkerId('dropoff'),
        position: dropoff,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: 'التسليم', snippet: state.dropoffAddress),
      ));
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final routeState = ref.watch(routePickerProvider);

    // Update text controllers when state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pickupController.text != routeState.pickupAddress) {
        _pickupController.text = routeState.pickupAddress;
      }
      if (_dropoffController.text != routeState.dropoffAddress) {
        _dropoffController.text = routeState.dropoffAddress;
      }
    });

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
                  Stack(
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
                                      const Icon(Icons.map,
                                          size: 64, color: Colors.grey),
                                      const SizedBox(height: 8),
                                      Text(_errorMessage!,
                                          textAlign: TextAlign.center),
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
                                onTap: _onMapTap,
                                markers: _buildMarkers(routeState),
                              ),
                      ),
                      if (_errorMessage == null)
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 4)
                              ],
                            ),
                            child: ChoiceChip(
                              label: Text(
                                routeState.selectingPickup
                                    ? 'اختر موقع الاستلام'
                                    : 'اختر موقع التسليم',
                                style: const TextStyle(fontSize: 12),
                              ),
                              selected: true,
                              onSelected: (_) => ref
                                  .read(routePickerProvider.notifier)
                                  .toggleSelection(),
                              selectedColor: routeState.selectingPickup
                                  ? Colors.green[100]
                                  : Colors.red[100],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _pickupController,
                    decoration: InputDecoration(
                      labelText: l10n.pickup,
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.my_location),
                        onPressed: _getCurrentLocation,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => _showPlacesSheet(true),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () => _showPlacesSheet(true),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _dropoffController,
                    decoration: InputDecoration(
                      labelText: l10n.dropoff,
                      prefixIcon: const Icon(Icons.location_on),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => _showPlacesSheet(false),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () => _showPlacesSheet(false),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (routeState.pickup != null &&
                              routeState.dropoff != null)
                          ? () {
                              final pickup = routeState.pickup;
                              final dropoff = routeState.dropoff;

                              if (pickup == null || dropoff == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('اختر موقعي الاستلام والتسليم')),
                                );
                                return;
                              }

                              final km = computeDistanceKm(
                                lat1: pickup.latitude,
                                lng1: pickup.longitude,
                                lat2: dropoff.latitude,
                                lng2: dropoff.longitude,
                              );
                              final price = computePrice(km);

                              ref.read(quoteProvider.notifier).setPickup(
                                  QuoteLatLng.LatLng(
                                      pickup.latitude, pickup.longitude));
                              ref.read(quoteProvider.notifier).setDropoff(
                                  QuoteLatLng.LatLng(
                                      dropoff.latitude, dropoff.longitude));
                              ref.read(quoteProvider.notifier).setDistance(km);
                              ref
                                  .read(quoteProvider.notifier)
                                  .setPrice(price.round());

                              context.push('/quote');
                            }
                          : null,
                      child: const Text('احسب السعر'),
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
