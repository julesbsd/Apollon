import 'package:cloud_firestore/cloud_firestore.dart';
import 'workout_set.dart';

/// Modèle représentant un exercice dans une séance avec ses séries
/// Un WorkoutExercise contient la référence à l'exercice et toutes ses séries
/// Structure: Séance → WorkoutExercise → WorkoutSets
class WorkoutExercise {
  final String exerciseId;
  final String exerciseName;
  final List<WorkoutSet> sets;
  final DateTime createdAt;

  WorkoutExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Conversion depuis Firestore
  factory WorkoutExercise.fromFirestore(Map<String, dynamic> data) {
    return WorkoutExercise(
      exerciseId: data['exerciseId'] as String,
      exerciseName: data['exerciseName'] as String,
      sets: (data['sets'] as List)
          .map((setData) => WorkoutSet.fromFirestore(setData as Map<String, dynamic>))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Conversion vers Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'sets': sets.map((set) => set.toFirestore()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Conversion depuis JSON
  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      sets: (json['sets'] as List)
          .map((setData) => WorkoutSet.fromJson(setData as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'sets': sets.map((set) => set.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Nombre total de séries
  int get totalSets => sets.length;

  /// Volume total (reps * poids) pour cet exercice
  double get totalVolume {
    return sets.fold(0.0, (sum, set) => sum + (set.reps * set.weight));
  }

  /// Nombre total de répétitions
  int get totalReps {
    return sets.fold(0, (sum, set) => sum + set.reps);
  }

  /// Poids maximum utilisé dans les séries
  double get maxWeight {
    if (sets.isEmpty) return 0;
    return sets.map((set) => set.weight).reduce((a, b) => a > b ? a : b);
  }

  /// Formater l'historique pour affichage (RG-005)
  /// Format: "• Série 1: 12 reps × 80kg"
  String displayHistory() {
    final buffer = StringBuffer();
    for (int i = 0; i < sets.length; i++) {
      buffer.writeln('• Série ${i + 1}: ${sets[i].display()}');
    }
    return buffer.toString().trim();
  }

  @override
  String toString() {
    return 'WorkoutExercise(exerciseName: $exerciseName, sets: ${sets.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutExercise && 
           other.exerciseId == exerciseId &&
           other.createdAt == createdAt;
  }

  @override
  int get hashCode => exerciseId.hashCode ^ createdAt.hashCode;

  /// Copier avec modifications
  WorkoutExercise copyWith({
    String? exerciseId,
    String? exerciseName,
    List<WorkoutSet>? sets,
    DateTime? createdAt,
  }) {
    return WorkoutExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      sets: sets ?? this.sets,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Ajouter une série
  WorkoutExercise addSet(WorkoutSet set) {
    return copyWith(sets: [...sets, set]);
  }

  /// Supprimer une série par index
  WorkoutExercise removeSet(int index) {
    if (index < 0 || index >= sets.length) {
      throw RangeError('Index $index hors limites (0-${sets.length - 1})');
    }
    final newSets = List<WorkoutSet>.from(sets);
    newSets.removeAt(index);
    return copyWith(sets: newSets);
  }

  /// Mettre à jour une série par index
  WorkoutExercise updateSet(int index, WorkoutSet set) {
    if (index < 0 || index >= sets.length) {
      throw RangeError('Index $index hors limites (0-${sets.length - 1})');
    }
    final newSets = List<WorkoutSet>.from(sets);
    newSets[index] = set;
    return copyWith(sets: newSets);
  }
}
