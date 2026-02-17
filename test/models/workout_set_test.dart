import 'package:flutter_test/flutter_test.dart';
import 'package:apollon/core/models/workout_set.dart';

void main() {
  group('WorkoutSet', () {
    test('should create WorkoutSet with valid data', () {
      final set = WorkoutSet(reps: 12, weight: 80.0);

      expect(set.reps, 12);
      expect(set.weight, 80.0);
      expect(set.isBodyweight, false);
    });

    test('should create bodyweight WorkoutSet with weight 0', () {
      final set = WorkoutSet(reps: 15, weight: 0);

      expect(set.isBodyweight, true);
      expect(set.display(), '15 reps (poids de corps)');
    });

    test('should display correctly with weight', () {
      final set = WorkoutSet(reps: 10, weight: 65.5);

      expect(set.display(), '10 reps × 65.5kg');
    });

    test('should throw ArgumentError when reps <= 0 (RG-003)', () {
      expect(
        () => WorkoutSet(reps: 0, weight: 50.0),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => WorkoutSet(reps: -5, weight: 50.0),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw ArgumentError when weight < 0 (RG-003)', () {
      expect(
        () => WorkoutSet(reps: 10, weight: -10.0),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should convert to/from JSON correctly', () {
      final set = WorkoutSet(reps: 12, weight: 80.0);
      final json = set.toJson();

      expect(json['reps'], 12);
      expect(json['weight'], 80.0);

      final setFromJson = WorkoutSet.fromJson(json);
      expect(setFromJson.reps, 12);
      expect(setFromJson.weight, 80.0);
    });

    test('should support equality comparison', () {
      final set1 = WorkoutSet(reps: 12, weight: 80.0);
      final set2 = WorkoutSet(reps: 12, weight: 80.0);
      final set3 = WorkoutSet(reps: 10, weight: 80.0);

      expect(set1 == set2, true);
      expect(set1 == set3, false);
    });

    test('should support copyWith', () {
      final set = WorkoutSet(reps: 12, weight: 80.0);
      final modifiedSet = set.copyWith(reps: 15);

      expect(modifiedSet.reps, 15);
      expect(modifiedSet.weight, 80.0);
    });
  });
}
