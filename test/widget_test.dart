// Basic Flutter widget test for Breaker Braker

import 'package:flutter_test/flutter_test.dart';
import 'package:breaker_braker/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const BreakerBrakerApp());

    // Verify that the app launches (splash screen loads)
    await tester.pump();

    // Basic smoke test - just verify app doesn't crash on launch
    expect(find.text('BREAKER BRAKER'), findsAtLeastNWidgets(1));
  });
}
