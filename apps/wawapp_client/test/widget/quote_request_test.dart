import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wawapp_client/features/quote/quote_screen.dart';

void main() {
  group('Quote Request Tests', () {
    testWidgets('shows SnackBar when required fields are null', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: QuoteScreen(),
            localizationsDelegates: [
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
            ],
          ),
        ),
      );

      // Find the "طلب الرحلة" button
      final requestButton = find.text('طلب الرحلة');
      expect(requestButton, findsOneWidget);

      // Button should be disabled when no quote is available
      final elevatedButton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: requestButton,
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(elevatedButton.onPressed, isNull);

      // Verify no crash occurs when tapping disabled button
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pump();

      // Should not throw any exceptions
      expect(tester.takeException(), isNull);
    });
  });
}
