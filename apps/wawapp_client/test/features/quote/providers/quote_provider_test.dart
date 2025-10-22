import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wawapp_client/features/quote/models/latlng.dart';
import 'package:wawapp_client/features/quote/providers/quote_provider.dart';

void main() {
  group('Quote Provider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should calculate price correctly with base fare + distance + service', () {
      final notifier = container.read(quoteProvider.notifier);
      
      // Set pickup and dropoff (approximately 1.5 km apart)
      notifier.setPickup(const LatLng(18.0735, -15.9582));
      notifier.setDropoff(const LatLng(18.0835, -15.9682));
      
      final state = container.read(quoteProvider);
      
      expect(state.pickup, isNotNull);
      expect(state.dropoff, isNotNull);
      expect(state.distanceKm, greaterThan(1.0));
      expect(state.priceInMRU, isNotNull);
      
      // Price should be: base(50) + distance(~1.5*20=30) + service(10) = ~90 MRU
      expect(state.priceInMRU!, greaterThan(80));
      expect(state.priceInMRU!, lessThan(100));
    });

    test('should not be ready without both pickup and dropoff', () {
      final notifier = container.read(quoteProvider.notifier);
      
      expect(container.read(quoteProvider).isReady, false);
      
      notifier.setPickup(const LatLng(18.0735, -15.9582));
      expect(container.read(quoteProvider).isReady, false);
      
      notifier.setDropoff(const LatLng(18.0835, -15.9682));
      expect(container.read(quoteProvider).isReady, true);
    });

    test('should reset state correctly', () {
      final notifier = container.read(quoteProvider.notifier);
      
      notifier.setPickup(const LatLng(18.0735, -15.9582));
      notifier.setDropoff(const LatLng(18.0835, -15.9682));
      
      expect(container.read(quoteProvider).isReady, true);
      
      notifier.reset();
      
      final state = container.read(quoteProvider);
      expect(state.pickup, isNull);
      expect(state.dropoff, isNull);
      expect(state.distanceKm, isNull);
      expect(state.priceInMRU, isNull);
      expect(state.isReady, false);
    });
  });
}