import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brain_boost/main.dart';

void main() {
  testWidgets('Brain Boost app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const BrainBoostApp());

    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // Verify that the app starts properly
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
