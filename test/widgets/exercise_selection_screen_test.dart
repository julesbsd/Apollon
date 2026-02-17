import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:apollon/core/providers/auth_provider.dart' as app_providers;
import 'package:apollon/core/providers/workout_provider.dart';
import 'package:apollon/screens/workout/exercise_selection_screen.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('ExerciseSelectionScreen Widget Tests', () {
    testWidgets('should display screen title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WorkoutProvider>(
              create: (_) => createTestWorkoutProvider(),
            ),
            ChangeNotifierProvider<app_providers.AuthProvider>(
              create: (_) => app_providers.AuthProvider(),
            ),
          ],
          child: const MaterialApp(home: ExerciseSelectionScreen()),
        ),
      );

      await tester.pump();

      // Vérifier que le titre est présent
      expect(find.text('Choisir un exercice'), findsOneWidget);
    });

    testWidgets('should have tabs for muscle groups', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WorkoutProvider>(
              create: (_) => createTestWorkoutProvider(),
            ),
            ChangeNotifierProvider<app_providers.AuthProvider>(
              create: (_) => app_providers.AuthProvider(),
            ),
          ],
          child: const MaterialApp(home: ExerciseSelectionScreen()),
        ),
      );

      await tester.pump();

      // Vérifier que les tabs sont présents
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(Tab), findsWidgets);
    });

    testWidgets('should have search bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WorkoutProvider>(
              create: (_) => createTestWorkoutProvider(),
            ),
            ChangeNotifierProvider<app_providers.AuthProvider>(
              create: (_) => app_providers.AuthProvider(),
            ),
          ],
          child: const MaterialApp(home: ExerciseSelectionScreen()),
        ),
      );

      await tester.pump();

      // Vérifier que la barre de recherche est présente
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should display exercise list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WorkoutProvider>(
              create: (_) => createTestWorkoutProvider(),
            ),
            ChangeNotifierProvider<app_providers.AuthProvider>(
              create: (_) => app_providers.AuthProvider(),
            ),
          ],
          child: const MaterialApp(home: ExerciseSelectionScreen()),
        ),
      );

      await tester.pump();

      // Vérifier qu'il y a une liste (ListView)
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should have back button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WorkoutProvider>(
              create: (_) => createTestWorkoutProvider(),
            ),
            ChangeNotifierProvider<app_providers.AuthProvider>(
              create: (_) => app_providers.AuthProvider(),
            ),
          ],
          child: const MaterialApp(home: ExerciseSelectionScreen()),
        ),
      );

      await tester.pump();

      // Vérifier qu'il y a un bouton de retour
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should be in SafeArea', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WorkoutProvider>(
              create: (_) => createTestWorkoutProvider(),
            ),
            ChangeNotifierProvider<app_providers.AuthProvider>(
              create: (_) => app_providers.AuthProvider(),
            ),
          ],
          child: const MaterialApp(home: ExerciseSelectionScreen()),
        ),
      );

      await tester.pump();

      // Vérifier que l'écran utilise SafeArea
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('search bar should be editable', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WorkoutProvider>(
              create: (_) => createTestWorkoutProvider(),
            ),
            ChangeNotifierProvider<app_providers.AuthProvider>(
              create: (_) => app_providers.AuthProvider(),
            ),
          ],
          child: const MaterialApp(home: ExerciseSelectionScreen()),
        ),
      );

      await tester.pump();

      // Trouver le TextField et vérifier qu'on peut taper dedans
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Bench');
      await tester.pump();

      // Vérifier que le texte a été entré
      expect(find.text('Bench'), findsOneWidget);
    });
  });
}

