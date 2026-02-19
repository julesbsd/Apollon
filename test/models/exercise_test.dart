import 'package:flutter_test/flutter_test.dart';
import 'package:apollon/core/models/exercise_library.dart';
import 'package:apollon/core/models/muscle_info.dart';
import 'package:apollon/core/models/type_info.dart';
import 'package:apollon/core/models/category_info.dart';

void main() {
  group('ExerciseLibrary', () {
    late ExerciseLibrary exercise;

    setUp(() {
      exercise = ExerciseLibrary(
        id: 'ex123',
        code: 'BARBELL_BENCH_PRESS',
        name: 'Développé couché barre',
        description: 'Exercice de poitrine avec barre',
        primaryMuscles: [
          MuscleInfo(code: 'CHEST', name: 'Pectoraux'),
        ],
        secondaryMuscles: [
          MuscleInfo(code: 'TRICEPS', name: 'Triceps'),
        ],
        types: [
          TypeInfo(code: 'FREE_WEIGHTS', name: 'Poids libres'),
        ],
        categories: [
          CategoryInfo(code: 'BARBELL', name: 'Barre'),
        ],
        syncedAt: DateTime(2024, 1, 1),
        source: 'workout-api',
        hasImage: true,
      );
    });

    test('should create ExerciseLibrary with valid data', () {
      expect(exercise.id, 'ex123');
      expect(exercise.code, 'BARBELL_BENCH_PRESS');
      expect(exercise.name, 'Développé couché barre');
      expect(exercise.description, 'Exercice de poitrine avec barre');
      expect(exercise.hasImage, true);
      expect(exercise.source, 'workout-api');
    });

    test('should return correct primaryMusclesText', () {
      expect(exercise.primaryMusclesText, 'Pectoraux');
    });

    test('should return correct secondaryMusclesText', () {
      expect(exercise.secondaryMusclesText, 'Triceps');
    });

    test('should return correct categoriesText', () {
      expect(exercise.categoriesText, 'Barre');
    });

    test('should support equality comparison by id', () {
      final ex1 = exercise;
      final ex2 = ExerciseLibrary(
        id: 'ex123',
        code: 'OTHER_CODE',
        name: 'Autre nom',
        description: '',
        primaryMuscles: const [],
        secondaryMuscles: const [],
        types: const [],
        categories: const [],
        syncedAt: DateTime(2024, 1, 1),
        source: 'workout-api',
      );
      final ex3 = ExerciseLibrary(
        id: 'ex456',
        code: 'SQUAT',
        name: 'Squat',
        description: '',
        primaryMuscles: const [],
        secondaryMuscles: const [],
        types: const [],
        categories: const [],
        syncedAt: DateTime(2024, 1, 1),
        source: 'workout-api',
      );

      expect(ex1 == ex2, true); // Même id
      expect(ex1 == ex3, false); // id différent
    });

    test('should handle empty muscle lists', () {
      final emptyExercise = ExerciseLibrary(
        id: 'ex999',
        code: 'TEST',
        name: 'Test',
        description: '',
        primaryMuscles: const [],
        secondaryMuscles: const [],
        types: const [],
        categories: const [],
        syncedAt: DateTime(2024, 1, 1),
        source: 'workout-api',
      );

      expect(emptyExercise.primaryMusclesText, '');
      expect(emptyExercise.secondaryMusclesText, '');
      expect(emptyExercise.categoriesText, '');
      expect(emptyExercise.secondaryMuscles.isEmpty, true);
    });

    test('should handle multiple primary muscles', () {
      final multiMuscle = ExerciseLibrary(
        id: 'ex789',
        code: 'PULLUP',
        name: 'Traction',
        description: '',
        primaryMuscles: [
          MuscleInfo(code: 'BACK', name: 'Dorsaux'),
          MuscleInfo(code: 'BICEPS', name: 'Biceps'),
        ],
        secondaryMuscles: const [],
        types: const [],
        categories: const [],
        syncedAt: DateTime(2024, 1, 1),
        source: 'workout-api',
      );

      expect(multiMuscle.primaryMuscles.length, 2);
      expect(multiMuscle.primaryMusclesText, 'Dorsaux, Biceps');
    });

    test('copyWith should return modified copy', () {
      final modified = exercise.copyWith(name: 'Nouveau nom', hasImage: false);

      expect(modified.id, exercise.id);
      expect(modified.name, 'Nouveau nom');
      expect(modified.hasImage, false);
      expect(modified.code, exercise.code);
    });
  });

  group('MuscleInfo', () {
    test('should create MuscleInfo with code and name', () {
      final muscle = MuscleInfo(code: 'CHEST', name: 'Pectoraux');
      expect(muscle.code, 'CHEST');
      expect(muscle.name, 'Pectoraux');
    });
  });

  group('TypeInfo', () {
    test('should create TypeInfo with code and name', () {
      final type = TypeInfo(code: 'FREE_WEIGHTS', name: 'Poids libres');
      expect(type.code, 'FREE_WEIGHTS');
      expect(type.name, 'Poids libres');
    });
  });

  group('CategoryInfo', () {
    test('should create CategoryInfo with code and name', () {
      final category = CategoryInfo(code: 'BARBELL', name: 'Barre');
      expect(category.code, 'BARBELL');
      expect(category.name, 'Barre');
    });
  });
}
