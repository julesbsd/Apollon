import 'package:flutter_test/flutter_test.dart';
import 'package:apollon/core/models/workout_exercise.dart';
import 'package:apollon/core/models/workout_set.dart';

void main() {
  group('WorkoutExercise', () {
    test('should create WorkoutExercise with valid data', () {
      final exercise = WorkoutExercise(
        exerciseId: 'ex123',
        exerciseName: 'Bench Press',
        sets: [
          WorkoutSet(reps: 10, weight: 80),
          WorkoutSet(reps: 8, weight: 85),
        ],
      );

      expect(exercise.exerciseId, 'ex123');
      expect(exercise.exerciseName, 'Bench Press');
      expect(exercise.sets.length, 2);
    });

    test('should calculate totalSets correctly', () {
      final exercise = WorkoutExercise(
        exerciseId: 'ex123',
        exerciseName: 'Bench Press',
        sets: [
          WorkoutSet(reps: 10, weight: 80),
          WorkoutSet(reps: 8, weight: 85),
          WorkoutSet(reps: 6, weight: 90),
        ],
      );

      expect(exercise.totalSets, 3);
    });

    test('should calculate totalReps correctly', () {
      final exercise = WorkoutExercise(
        exerciseId: 'ex123',
        exerciseName: 'Bench Press',
        sets: [
          WorkoutSet(reps: 10, weight: 80),
          WorkoutSet(reps: 8, weight: 85),
          WorkoutSet(reps: 6, weight: 90),
        ],
      );

      expect(exercise.totalReps, 24);
    });

    test('should calculate totalVolume correctly', () {
      final exercise = WorkoutExercise(
        exerciseId: 'ex123',
        exerciseName: 'Bench Press',
        sets: [
          WorkoutSet(reps: 10, weight: 80), // 800
          WorkoutSet(reps: 8, weight: 85), // 680
          WorkoutSet(reps: 6, weight: 90), // 540
        ],
      );

      expect(exercise.totalVolume, 2020.0);
    });

    test('should convert to/from JSON correctly', () {
      final exercise = WorkoutExercise(
        exerciseId: 'ex123',
        exerciseName: 'Bench Press',
        sets: [
          WorkoutSet(reps: 10, weight: 80),
          WorkoutSet(reps: 8, weight: 85),
        ],
      );

      final json = exercise.toJson();

      expect(json['exerciseId'], 'ex123');
      expect(json['exerciseName'], 'Bench Press');
      expect(json['sets'], isA<List>());
      expect(json['sets'].length, 2);

      final exerciseFromJson = WorkoutExercise.fromJson(json);

      expect(exerciseFromJson.exerciseId, exercise.exerciseId);
      expect(exerciseFromJson.exerciseName, exercise.exerciseName);
      expect(exerciseFromJson.sets.length, 2);
    });

    test('should handle bodyweight sets in volume calculation', () {
      final exercise = WorkoutExercise(
        exerciseId: 'ex123',
        exerciseName: 'Pull-ups',
        sets: [
          WorkoutSet(reps: 10, weight: 0), // Bodyweight
          WorkoutSet(reps: 8, weight: 0),
          WorkoutSet(reps: 6, weight: 0),
        ],
      );

      expect(exercise.totalVolume, 0.0);
      expect(exercise.totalReps, 24);
    });

    test('should handle mixed bodyweight and weighted sets', () {
      final exercise = WorkoutExercise(
        exerciseId: 'ex123',
        exerciseName: 'Dips',
        sets: [
          WorkoutSet(reps: 12, weight: 0), // Bodyweight
          WorkoutSet(reps: 10, weight: 10), // +10kg
          WorkoutSet(reps: 8, weight: 15), // +15kg
        ],
      );

      expect(exercise.totalVolume, 220.0); // (10*10) + (8*15)
      expect(exercise.totalReps, 30);
    });

    test('should support copyWith for adding sets', () {
      final exercise = WorkoutExercise(
        exerciseId: 'ex123',
        exerciseName: 'Bench Press',
        sets: [WorkoutSet(reps: 10, weight: 80)],
      );

      final newSets = [...exercise.sets, WorkoutSet(reps: 8, weight: 85)];

      final updated = exercise.copyWith(sets: newSets);

      expect(updated.sets.length, 2);
      expect(updated.totalSets, 2);
    });

    test('should handle empty sets list', () {
      final exercise = WorkoutExercise(
        exerciseId: 'ex123',
        exerciseName: 'Bench Press',
        sets: [],
      );

      expect(exercise.totalSets, 0);
      expect(exercise.totalReps, 0);
      expect(exercise.totalVolume, 0.0);
    });

    test('should support equality comparison', () {
      final ex1 = WorkoutExercise(
        exerciseId: 'ex123',
        exerciseName: 'Bench Press',
        sets: [WorkoutSet(reps: 10, weight: 80)],
      );

      final ex2 = WorkoutExercise(
        exerciseId: 'ex123',
        exerciseName: 'Bench Press',
        sets: [WorkoutSet(reps: 10, weight: 80)],
      );

      final ex3 = WorkoutExercise(
        exerciseId: 'ex456',
        exerciseName: 'Squat',
        sets: [WorkoutSet(reps: 12, weight: 100)],
      );

      expect(ex1 == ex2, true);
      expect(ex1 == ex3, false);
    });
  });
}
