import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrdersRepository {
  final FirebaseFirestore _firestore;

  OrdersRepository([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> createOrder(LatLng pickup, LatLng dropoff, num price) async {
    final docRef = await _firestore.collection('orders').add({
      'pickup': {'lat': pickup.latitude, 'lng': pickup.longitude},
      'dropoff': {'lat': dropoff.latitude, 'lng': dropoff.longitude},
      'price': price,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }
}

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository();
});
