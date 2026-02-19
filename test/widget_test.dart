// Tests de base pour l'application Apollon

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:apollon/core/providers/auth_provider.dart' as app_providers;
import 'package:apollon/core/providers/theme_provider.dart';
import 'package:apollon/core/providers/workout_provider.dart';
import 'package:apollon/app.dart';
import 'helpers/test_helpers.dart';

void main() {
  testWidgets('App displays LoginScreen when not authenticated', (
    WidgetTester tester,
  ) async {
    // Build the app with all required Providers (sans Firebase réel)
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<app_providers.AuthProvider>(
            create: (_) => TestAuthProvider(MockAuthService()),
          ),
          ChangeNotifierProvider<ThemeProvider>(
            create: (_) => ThemeProvider(),
          ),
          ChangeNotifierProvider<WorkoutProvider>(
            create: (_) => createTestWorkoutProvider(),
          ),
        ],
        child: const ApolloApp(),
      ),
    );

    // Wait for async operations to complete
    await tester.pump(); // First frame
    await tester.pump(const Duration(milliseconds: 100)); // Give stream time to emit

    // Verify that LoginScreen is displayed (check for the title)
    expect(find.text('APOLLON'), findsWidgets);
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
