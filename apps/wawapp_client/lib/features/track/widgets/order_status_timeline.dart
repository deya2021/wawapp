import 'package:flutter/material.dart';

class OrderStatusTimeline extends StatelessWidget {
  final String
      status; // pending, matching, assigned, enRoute, pickedUp, delivering, delivered, canceled
  const OrderStatusTimeline({super.key, required this.status});

  static const List<String> _steps = [
    'pending',
    'matching',
    'assigned',
    'enRoute',
    'pickedUp',
    'delivering',
    'delivered'
  ];

  int _indexOf(String s) => _steps.indexOf(s).clamp(0, _steps.length - 1);

  @override
  Widget build(BuildContext context) {
    final current = _indexOf(status);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_steps.length, (i) {
        final active = i <= current;
        return Expanded(
          child: Column(
            children: [
              Container(
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: active
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _label(_steps[i]),
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }

  String _label(String s) {
    switch (s) {
      case 'pending':
        return 'قيد الإنشاء';
      case 'matching':
        return 'جارِ التعيين';
      case 'assigned':
        return 'تم التعيين';
      case 'enRoute':
        return 'في الطريق';
      case 'pickedUp':
        return 'تم الاستلام';
      case 'delivering':
        return 'جاري التوصيل';
      case 'delivered':
        return 'تم التسليم';
      default:
        return s;
    }
  }
}
