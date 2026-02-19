import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:apollon/core/providers/workout_provider.dart';
import 'package:apollon/core/providers/auth_provider.dart' as app_providers;
import 'package:apollon/core/models/exercise_library.dart';
import 'package:apollon/core/models/muscle_info.dart';
import 'package:apollon/core/models/type_info.dart';
import 'package:apollon/core/models/category_info.dart';
import 'package:apollon/core/services/workout_service.dart';
import 'package:apollon/core/services/exercise_library_repository.dart';
import 'package:apollon/screens/workout/workout_session_screen.dart';
import '../helpers/test_helpers.dart';

class MockExerciseLibraryRepository extends Mock
    implements ExerciseLibraryRepository {}

class MockWorkoutServiceLocal extends Mock implements WorkoutService {}

/// Crée un widget de test avec les providers nécessaires
Widget buildTestWidget(WorkoutProvider workoutProvider, ExerciseLibrary exercise) {
  final mockRepo = MockExerciseLibraryRepository();
  final mockWorkoutService = MockWorkoutServiceLocal();
  when(() => mockRepo.getAll()).thenAnswer((_) async => []);
  when(() => mockRepo.getImageSource(any())).thenAnswer(
    (_) async => const ImageSource.remote(''),
  );
  when(() => mockWorkoutService.getLastWorkoutForExercise(any(), any()))
      .thenAnswer((_) async => null);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<WorkoutProvider>(create: (_) => workoutProvider),
      ChangeNotifierProvider<app_providers.AuthProvider>(
        create: (_) => TestAuthProvider(MockAuthService()),
      ),
      Provider<WorkoutService>.value(value: mockWorkoutService),
      Provider<ExerciseLibraryRepository>.value(value: mockRepo),
    ],
    child: MaterialApp(home: WorkoutSessionScreen(exercise: exercise)),
  );
}

void main() {
  group('WorkoutSessionScreen Widget Tests', () {
    // Exercice de test avec le nouveau modèle ExerciseLibrary
    final testExercise = ExerciseLibrary(
      id: 'test123',
      code: 'BENCH_PRESS',
      name: 'Bench Press',
      description: 'Test exercise',
      primaryMuscles: [MuscleInfo(code: 'CHEST', name: 'Pectoraux')],
      secondaryMuscles: [],
      types: [TypeInfo(code: 'FREE_WEIGHTS', name: 'Poids libres')],
      categories: [CategoryInfo(code: 'BARBELL', name: 'Barre')],
      syncedAt: DateTime(2024, 1, 1),
      source: 'workout-api',
    );

    testWidgets('should display exercise name', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(createTestWorkoutProvider(), testExercise));
      await tester.pump();

      expect(find.text('Bench Press'), findsOneWidget);
    });

    testWidgets('should have Scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(createTestWorkoutProvider(), testExercise));
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have back button', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(createTestWorkoutProvider(), testExercise));
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back), findsWidgets);
    });

    testWidgets('should display muscle chip', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(createTestWorkoutProvider(), testExercise));
      await tester.pump();

      // Vérifier qu'un Chip avec le type est présent
      expect(find.text('Poids libres'), findsOneWidget);
    });
  });
}
