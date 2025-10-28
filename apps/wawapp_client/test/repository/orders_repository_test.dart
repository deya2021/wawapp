import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wawapp_client/features/track/data/orders_repository.dart';

void main() {
  group('OrdersRepository Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late OrdersRepository repository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = OrdersRepository(fakeFirestore);
    });

    test('createOrder returns orderId and writes correct fields', () async {
      const pickup = LatLng(18.0783, -15.9744);
      const dropoff = LatLng(18.0969, -15.9497);
      const price = 100;

      final orderId = await repository.createOrder(pickup, dropoff, price);

      expect(orderId, isNotEmpty);

      // Verify the document was created with correct fields
      final doc = await fakeFirestore.collection('orders').doc(orderId).get();
      expect(doc.exists, isTrue);

      final data = doc.data()!;
      expect(data['pickup']['lat'], pickup.latitude);
      expect(data['pickup']['lng'], pickup.longitude);
      expect(data['dropoff']['lat'], dropoff.latitude);
      expect(data['dropoff']['lng'], dropoff.longitude);
      expect(data['price'], price);
      expect(data['status'], 'pending');
      expect(data['createdAt'], isNotNull);
    });
  });
}
