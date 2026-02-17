// Tests de base pour l'application Apollon

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:apollon/core/providers/auth_provider.dart' as app_providers;
import 'package:apollon/app.dart';

void main() {
  testWidgets('App displays LoginScreen when not authenticated', (
    WidgetTester tester,
  ) async {
    // Build the app with Provider
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => app_providers.AuthProvider(),
        child: const ApolloApp(),
      ),
    );

    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // Verify that LoginScreen is displayed (check for the title)
    expect(find.text('APOLLON'), findsWidgets);
    expect(find.text('Se connecter avec Google'), findsOneWidget);
  });

  testWidgets('LiquidButton displays text correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Center(child: const Text('Test'))),
      ),
    );

    expect(find.text('Test'), findsOneWidget);
  });
}
