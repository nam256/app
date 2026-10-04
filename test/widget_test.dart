// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:art_collection_app/main.dart';

void main() {
  testWidgets('Art Collection App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: ArtCollectionApp(),
      ),
    );

    // Wait for the app to fully load
    await tester.pumpAndSettle();

    // Verify that the app title is displayed
    expect(find.text('Art Collection Manager'), findsOneWidget);

    // Verify that the welcome message is displayed
    expect(find.text('Welcome to Art Collection Manager'), findsOneWidget);

    // Verify that the Get Started button is displayed
    expect(find.text('Get Started'), findsOneWidget);

    // Verify that the palette icon is displayed
    expect(find.byIcon(Icons.palette), findsOneWidget);

    // Tap the Get Started button
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify that snackbar appears
    expect(find.text('Login screen coming soon!'), findsOneWidget);
  });
}
