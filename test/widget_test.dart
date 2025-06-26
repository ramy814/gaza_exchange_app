// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gaza_exchange_app/main.dart';

void main() {
  testWidgets('Gaza Exchange App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app title is displayed
    expect(find.text('تبادل غزة'), findsOneWidget);

    // Verify that the splash screen is shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the timer to complete (2 seconds) and pump
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify that the app has navigated to login screen
    expect(find.text('أهلاً بك في تبادل غزة'), findsOneWidget);
  });
}
