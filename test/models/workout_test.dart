import 'package:flutter_test/flutter_test.dart';
import 'package:apollon/core/models/workout.dart';
import 'package:apollon/core/models/workout_exercise.dart';
import 'package:apollon/core/models/workout_set.dart';

void main() {
  group('Workout', () {
    test('should create Workout with valid data', () {
      final workout = Workout(
        userId: 'user123',
        date: DateTime(2026, 2, 15),
        status: WorkoutStatus.draft,
        exercises: [],
      );

      expect(workout.userId, 'user123');
      expect(workout.status, WorkoutStatus.draft);
      expect(workout.exercises, isEmpty);
      expect(workout.totalExercises, 0);
      expect(workout.totalSets, 0);
    });

    test('should calculate totalExercises correctly', () {
      final workout = Workout(
        userId: 'user123',
        date: DateTime(2026, 2, 15),
        status: WorkoutStatus.completed,
        exercises: [
          WorkoutExercise(
            exerciseId: 'ex1',
            exerciseName: 'Bench Press',
            sets: [WorkoutSet(reps: 10, weight: 80)],
          ),
          WorkoutExercise(
            exerciseId: 'ex2',
            exerciseName: 'Squat',
            sets: [WorkoutSet(reps: 12, weight: 100)],
          ),
        ],
      );

      expect(workout.totalExercises, 2);
    });

    test('should calculate totalSets correctly', () {
      final workout = Workout(
        userId: 'user123',
        date: DateTime(2026, 2, 15),
        status: WorkoutStatus.completed,
        exercises: [
          WorkoutExercise(
            exerciseId: 'ex1',
            exerciseName: 'Bench Press',
            sets: [
              WorkoutSet(reps: 10, weight: 80),
              WorkoutSet(reps: 8, weight: 85),
              WorkoutSet(reps: 6, weight: 90),
            ],
          ),
          WorkoutExercise(
            exerciseId: 'ex2',
            exerciseName: 'Squat',
            sets: [
              WorkoutSet(reps: 12, weight: 100),
              WorkoutSet(reps: 10, weight: 110),
            ],
          ),
        ],
      );

      expect(workout.totalSets, 5);
    });

    test('should calculate totalVolume correctly', () {
      final workout = Workout(
        userId: 'user123',
        date: DateTime(2026, 2, 15),
        status: WorkoutStatus.completed,
        exercises: [
          WorkoutExercise(
            exerciseId: 'ex1',
            exerciseName: 'Bench Press',
            sets: [
              WorkoutSet(reps: 10, weight: 80), // 800
              WorkoutSet(reps: 8, weight: 85),  // 680
            ],
          ),
        ],
      );

      expect(workout.totalVolume, 1480.0);
    });

    test('should convert to/from JSON correctly', () {
      final originalWorkout = Workout(
        id: 'workout123',
        userId: 'user123',
        date: DateTime(2026, 2, 15, 14, 30),
        status: WorkoutStatus.completed,
        duration: 3600,
        exercises: [
          WorkoutExercise(
            exerciseId: 'ex1',
            exerciseName: 'Bench Press',
            sets: [WorkoutSet(reps: 10, weight: 80)],
          ),
        ],
      );

      final json = originalWorkout.toJson();

      expect(json['id'], 'workout123');
      expect(json['userId'], 'user123');
      expect(json['status'], 'completed');
      expect(json['duration'], 3600);
      expect(json['exercises'], isA<List>());

      final workoutFromJson = Workout.fromJson(json);

      expect(workoutFromJson.id, originalWorkout.id);
      expect(workoutFromJson.userId, originalWorkout.userId);
      expect(workoutFromJson.status, originalWorkout.status);
      expect(workoutFromJson.duration, originalWorkout.duration);
      expect(workoutFromJson.exercises.length, 1);
    });

    test('should support copyWith for status change', () {
      final draft = Workout(
        userId: 'user123',
        date: DateTime(2026, 2, 15),
        status: WorkoutStatus.draft,
        exercises: [],
      );

      final completed = draft.copyWith(
        status: WorkoutStatus.completed,
        duration: 3600,
      );

      expect(completed.status, WorkoutStatus.completed);
      expect(completed.duration, 3600);
      expect(completed.userId, draft.userId);
    });

    test('should handle empty exercises list', () {
      final workout = Workout(
        userId: 'user123',
        date: DateTime(2026, 2, 15),
        status: WorkoutStatus.draft,
        exercises: [],
      );

      expect(workout.totalExercises, 0);
      expect(workout.totalSets, 0);
      expect(workout.totalVolume, 0.0);
    });
  });

  group('WorkoutStatus', () {
    test('should convert from string correctly', () {
      expect(WorkoutStatus.fromString('draft'), WorkoutStatus.draft);
      expect(WorkoutStatus.fromString('completed'), WorkoutStatus.completed);
    });

    test('should have correct values', () {
      expect(WorkoutStatus.draft.value, 'draft');
      expect(WorkoutStatus.completed.value, 'completed');
    });

    test('should return draft as default for invalid status string', () {
      // Defensive programming: invalid status defaults to draft
      expect(WorkoutStatus.fromString('invalid'), WorkoutStatus.draft);
    });
  });
}
