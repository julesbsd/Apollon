import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:apollon/core/providers/workout_provider.dart';
import 'package:apollon/core/providers/auth_provider.dart' as app_providers;
import 'package:apollon/core/models/exercise.dart';
import 'package:apollon/screens/workout/workout_session_screen.dart';

void main() {
  group('WorkoutSessionScreen Widget Tests', () {
    // Créer un exercice de test
    final testExercise = Exercise(
      id: 'test123',
      name: 'Bench Press',
      muscleGroups: [MuscleGroup.chest],
      type: ExerciseType.freeWeights,
      emoji: '💪',
      description: 'Test exercise',
    );

    testWidgets('should display exercise name', (WidgetTester tester) async {
      final workoutProvider = WorkoutProvider();
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WorkoutProvider>(
              create: (_) => workoutProvider,
            ),
            ChangeNotifierProvider<app_providers.AuthProvider>(
              create: (_) => app_providers.AuthProvider(),
            ),
          ],
          child: MaterialApp(
            home: WorkoutSessionScreen(exercise: testExercise),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que le nom de l'exercice est affiché
      expect(find.text('Bench Press'), findsOneWidget);
    });

    testWidgets('should display add set button initially', (WidgetTester tester) async {
      final workoutProvider = WorkoutProvider();
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WorkoutProvider>(
              create: (_) => workoutProvider,
            ),
            ChangeNotifierProvider<app_providers.AuthProvider>(
              create: (_) => app_providers.AuthProvider(),
            ),
          ],
          child: MaterialApp(
            home: WorkoutSessionScreen(exercise: testExercise),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier qu'il y a un bouton pour ajouter une série
      expect(find.textContaining('Ajouter'), findsWidgets);
    });

    testWidgets('should have SafeArea and Scaffold', (WidgetTester tester) async {
      final workoutProvider = WorkoutProvider();
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WorkoutProvider>(
              create: (_) => workoutProvider,
            ),
            ChangeNotifierProvider<app_providers.AuthProvider>(
              create: (_) => app_providers.AuthProvider(),
            ),
          ],
          child: MaterialApp(
            home: WorkoutSessionScreen(exercise: testExercise),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier la structure de base
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('should have back button', (WidgetTester tester) async {
      final workoutProvider = WorkoutProvider();
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WorkoutProvider>(
              create: (_) => workoutProvider,
            ),
            ChangeNotifierProvider<app_providers.AuthProvider>(
              create: (_) => app_providers.AuthProvider(),
            ),
          ],
          child: MaterialApp(
            home: WorkoutSessionScreen(exercise: testExercise),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier qu'il y a un bouton de retour
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should display exercise emoji', (WidgetTester tester) async {
      final workoutProvider = WorkoutProvider();
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WorkoutProvider>(
              create: (_) => workoutProvider,
            ),
            ChangeNotifierProvider<app_providers.AuthProvider>(
              create: (_) => app_providers.AuthProvider(),
            ),
          ],
          child: MaterialApp(
            home: WorkoutSessionScreen(exercise: testExercise),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'emoji est affiché
      expect(find.text('💪'), findsOneWidget);
    });
  });
}
