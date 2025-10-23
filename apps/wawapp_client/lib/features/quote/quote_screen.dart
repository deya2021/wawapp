import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'providers/quote_provider.dart';
import '../map/pick_route_controller.dart';
import '../track/models/order.dart';

class QuoteScreen extends ConsumerStatefulWidget {
  const QuoteScreen({super.key});

  @override
  ConsumerState<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends ConsumerState<QuoteScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final quoteState = ref.watch(quoteProvider);

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.get_quote),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.local_shipping, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              Text(
                l10n.estimated_price,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                quoteState.priceInMRU != null
                    ? '${l10n.currency} ${quoteState.priceInMRU!.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'
                    : '--- ${l10n.currency}',
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              if (quoteState.distanceKm != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${quoteState.distanceKm!.toStringAsFixed(1)} km',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: quoteState.isReady
                    ? () {
                        final routeState = ref.read(routePickerProvider);
                        final order = Order(
                          distanceKm: quoteState.distanceKm!,
                          price: quoteState.priceInMRU!.toDouble(),
                          pickupAddress: routeState.pickupAddress,
                          dropoffAddress: routeState.dropoffAddress,
                          pickup: routeState.pickup!,
                          dropoff: routeState.dropoff!,
                        );
                        context.push('/track', extra: order);
                      }
                    : null,
                child: Text(l10n.request_now),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
