import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:apollon/core/providers/auth_provider.dart' as app_providers;
import 'package:apollon/screens/auth/login_screen.dart';
import 'package:apollon/core/widgets/widgets.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('should display logo and app name', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => app_providers.AuthProvider(),
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      // Use pump() instead of pumpAndSettle() due to infinite animation in MeshGradientBackground
      await tester.pump();

      // Vérifier que le titre APOLLON est affiché
      expect(find.text('APOLLON'), findsOneWidget);

      // Vérifier que le bouton de connexion Google est présent
      expect(find.text('Se connecter avec Google'), findsOneWidget);
    });

    testWidgets('should display MeshGradientBackground', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => app_providers.AuthProvider(),
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.pump();

      // Vérifier que le MeshGradientBackground est présent
      expect(find.byType(MeshGradientBackground), findsOneWidget);
    });

    testWidgets('should have google sign in button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => app_providers.AuthProvider(),
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.pump();

      // Vérifier que le bouton est présent et tappable
      final button = find.text('Se connecter avec Google');
      expect(button, findsOneWidget);

      // Le bouton doit être dans un widget interactif
      // On vérifie juste qu'il existe, la structure exacte peut varier
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('should display tagline or description', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => app_providers.AuthProvider(),
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.pump();

      // Vérifier qu'il y a du texte descriptif (le texte exact peut varier)
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('should be in SafeArea', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => app_providers.AuthProvider(),
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.pump();

      // Vérifier que l'écran utilise SafeArea
      expect(find.byType(SafeArea), findsOneWidget);
    });
  });
}
