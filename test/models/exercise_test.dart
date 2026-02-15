import 'package:flutter_test/flutter_test.dart';
import 'package:apollon/core/models/exercise.dart';

void main() {
  group('Exercise', () {
    test('should create Exercise with valid data', () {
      final exercise = Exercise(
        id: 'ex123',
        name: 'Bench Press',
        muscleGroups: [MuscleGroup.chest],
        type: ExerciseType.freeWeights,
        emoji: '💪',
      );

      expect(exercise.id, 'ex123');
      expect(exercise.name, 'Bench Press');
      expect(exercise.muscleGroups.length, 1);
      expect(exercise.muscleGroups.first, MuscleGroup.chest);
      expect(exercise.type, ExerciseType.freeWeights);
      expect(exercise.emoji, '💪');
    });

    test('should handle multiple muscle groups', () {
      final exercise = Exercise(
        id: 'ex123',
        name: 'Pull-up',
        muscleGroups: [MuscleGroup.back, MuscleGroup.biceps],
        type: ExerciseType.bodyWeight,
        emoji: '🏋️',
      );

      expect(exercise.muscleGroups.length, 2);
      expect(exercise.muscleGroups.contains(MuscleGroup.back), true);
      expect(exercise.muscleGroups.contains(MuscleGroup.biceps), true);
    });

    test('should convert to/from JSON correctly', () {
      final exercise = Exercise(
        id: 'ex123',
        name: 'Bench Press',
        description: 'Chest exercise',
        muscleGroups: [MuscleGroup.chest, MuscleGroup.triceps],
        type: ExerciseType.freeWeights,
        emoji: '💪',
      );

      final json = exercise.toJson();

      expect(json['id'], 'ex123');
      expect(json['name'], 'Bench Press');
      expect(json['description'], 'Chest exercise');
      expect(json['muscleGroups'], isA<List>());
      expect(json['type'], ExerciseType.freeWeights);

      final exerciseFromJson = Exercise.fromJson(json);

      expect(exerciseFromJson.id, exercise.id);
      expect(exerciseFromJson.name, exercise.name);
      expect(exerciseFromJson.muscleGroups.length, 2);
      expect(exerciseFromJson.type, exercise.type);
    });

    test('should convert to/from Firestore correctly', () {
      final exerciseData = {
        'name': 'Squat',
        'muscleGroups': [MuscleGroup.quadriceps, MuscleGroup.glutes],
        'type': ExerciseType.freeWeights,
        'emoji': '🦵',
        'description': 'Leg exercise',
      };

      final exercise = Exercise.fromFirestore(exerciseData, 'ex456');

      expect(exercise.id, 'ex456');
      expect(exercise.name, 'Squat');
      expect(exercise.muscleGroups.length, 2);

      final firestoreData = exercise.toFirestore();

      expect(firestoreData['name'], 'Squat');
      expect(firestoreData['muscleGroups'], isA<List>());
      expect(firestoreData['type'], ExerciseType.freeWeights);
    });

    test('should support equality comparison by id', () {
      final ex1 = Exercise(
        id: 'ex123',
        name: 'Bench Press',
        muscleGroups: [MuscleGroup.chest],
        type: ExerciseType.freeWeights,
        emoji: '💪',
      );

      final ex2 = Exercise(
        id: 'ex123',
        name: 'Incline Bench Press', // Different name, same id
        muscleGroups: [MuscleGroup.chest],
        type: ExerciseType.freeWeights,
        emoji: '💪',
      );

      final ex3 = Exercise(
        id: 'ex456',
        name: 'Squat',
        muscleGroups: [MuscleGroup.quadriceps],
        type: ExerciseType.freeWeights,
        emoji: '🦵',
      );

      expect(ex1 == ex2, true); // Same id
      expect(ex1 == ex3, false); // Different id
    });

    test('should handle optional description', () {
      final exerciseWithDesc = Exercise(
        id: 'ex123',
        name: 'Bench Press',
        muscleGroups: [MuscleGroup.chest],
        type: ExerciseType.freeWeights,
        emoji: '💪',
        description: 'Great chest exercise',
      );

      final exerciseWithoutDesc = Exercise(
        id: 'ex456',
        name: 'Squat',
        muscleGroups: [MuscleGroup.quadriceps],
        type: ExerciseType.freeWeights,
        emoji: '🦵',
      );

      expect(exerciseWithDesc.description, 'Great chest exercise');
      expect(exerciseWithoutDesc.description, null);
    });
  });

  group('ExerciseType', () {
    test('should have all type constants', () {
      expect(ExerciseType.freeWeights, 'Poids libres');
      expect(ExerciseType.machine, 'Machine guidée');
      expect(ExerciseType.bodyWeight, 'Poids corporel');
      expect(ExerciseType.cardio, 'Cardio');
    });

    test('should have complete list of types', () {
      expect(ExerciseType.all.length, 4);
      expect(ExerciseType.all.contains(ExerciseType.freeWeights), true);
      expect(ExerciseType.all.contains(ExerciseType.bodyWeight), true);
    });
  });

  group('MuscleGroup', () {
    test('should have all muscle group constants', () {
      expect(MuscleGroup.chest, 'Pectoraux');
      expect(MuscleGroup.back, 'Dorsaux');
      expect(MuscleGroup.shoulders, 'Épaules');
      expect(MuscleGroup.biceps, 'Biceps');
      expect(MuscleGroup.triceps, 'Triceps');
      expect(MuscleGroup.abs, 'Abdominaux');
      expect(MuscleGroup.quadriceps, 'Quadriceps');
      expect(MuscleGroup.hamstrings, 'Ischio-jambiers');
      expect(MuscleGroup.glutes, 'Fessiers');
      expect(MuscleGroup.calves, 'Mollets');
    });

    test('should have complete list of muscle groups', () {
      expect(MuscleGroup.all.length, 10);
      expect(MuscleGroup.all.contains(MuscleGroup.chest), true);
      expect(MuscleGroup.all.contains(MuscleGroup.quadriceps), true);
    });

    test('should have correct categories', () {
      expect(MuscleGroup.categories.length, 3);
      expect(MuscleGroup.categories.containsKey('Haut du corps'), true);
      expect(MuscleGroup.categories.containsKey('Abdominaux'), true);
      expect(MuscleGroup.categories.containsKey('Bas du corps'), true);
      
      expect(MuscleGroup.categories['Haut du corps']!.length, 5);
      expect(MuscleGroup.categories['Bas du corps']!.length, 4);
    });
  });
}

