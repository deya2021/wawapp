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
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicWidth(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_steps.length, (i) {
                final active = i <= current;
                return SizedBox(
                  width: 80,
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
                        style: isSmallScreen
                            ? Theme.of(context).textTheme.labelSmall
                            : Theme.of(context).textTheme.labelSmall,
                        textAlign: TextAlign.center,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
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
