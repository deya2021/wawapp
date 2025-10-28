import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderSummarySheet extends StatelessWidget {
  const OrderSummarySheet({
    super.key,
    required this.orderId,
    required this.price,
    required this.distance,
    required this.pickupAddress,
    required this.dropoffAddress,
  });

  final String orderId;
  final int price;
  final String distance;
  final String pickupAddress;
  final String dropoffAddress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              Text(
                'تم إنشاء الطلب بنجاح',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'رقم الطلب: ${orderId.substring(orderId.length - 6)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('السعر: $price أوقية'),
                  Text('المسافة: $distance'),
                  const SizedBox(height: 8),
                  Text('من: $pickupAddress',
                      style: const TextStyle(fontSize: 12)),
                  Text('إلى: $dropoffAddress',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/track', extra: {'orderId': orderId});
            },
            child: const Text('اذهب للتتبع'),
          ),
        ],
      ),
    );
  }
}
