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

  /// Creates an order and immediately marks it as "matching" so drivers can see it.
  /// Minimal-change fix to ensure the order passes the 'creating' limbo.
  Future<String> createOrderAndFinalize(Map<String, dynamic> orderData) async {
    final docRef = _firestore.collection('orders').doc();
    final batch = _firestore.batch();

    final now = FieldValue.serverTimestamp();
    final data = Map<String, dynamic>.from(orderData)
      ..putIfAbsent('status', () => 'creating')
      ..putIfAbsent('createdAt', () => now);

    batch.set(docRef, data, SetOptions(merge: true));
    // Transition to a driver-visible state with the same batch.
    batch.update(docRef, <String, dynamic>{
      'status': 'matching',
      'createdAt': now,
    });

    await batch.commit();
    return docRef.id;
  }
}

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository();
});
