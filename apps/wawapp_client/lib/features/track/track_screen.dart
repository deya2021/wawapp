import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'models/order.dart';

class TrackScreen extends StatelessWidget {
  final Order? order;
  const TrackScreen({super.key, this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.track),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(
                    Icons.navigation,
                    size: 64,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الحالة: في الطريق',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    const Text('السائق: ---'),
                    const Text('المركبة: ---'),
                    Text(
                        'السعر: ${order?.price.round() ?? '---'} ${l10n.currency}'),
                    if (order != null) ...[
                      Text('المسافة: ${order!.distanceKm} كم'),
                      Text('من: ${order!.pickupAddress}'),
                      Text('إلى: ${order!.dropoffAddress}'),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
