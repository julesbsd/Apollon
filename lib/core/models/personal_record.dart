import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle pour un Record Personnel (PR)
/// Suivi du poids maximal levé pour un exercice donné
class PersonalRecord {
  final String? id;
  final String userId;
  final String exerciseId;
  final String exerciseName;
  final double weight;           // Poids du PR en kg
  final int reps;                // Nombre de répétitions
  final DateTime achievedAt;     // Date du PR
  final String? workoutId;       // Référence à la séance

  PersonalRecord({
    this.id,
    required this.userId,
    required this.exerciseId,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.achievedAt,
    this.workoutId,
  });

  /// Conversion vers Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'weight': weight,
      'reps': reps,
      'achievedAt': Timestamp.fromDate(achievedAt),
      if (workoutId != null) 'workoutId': workoutId,
    };
  }

  /// Création depuis Firestore
  factory PersonalRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PersonalRecord(
      id: doc.id,
      userId: data['userId'] as String,
      exerciseId: data['exerciseId'] as String,
      exerciseName: data['exerciseName'] as String,
      weight: (data['weight'] as num).toDouble(),
      reps: data['reps'] as int,
      achievedAt: (data['achievedAt'] as Timestamp).toDate(),
      workoutId: data['workoutId'] as String?,
    );
  }

  /// Copie avec modifications
  PersonalRecord copyWith({
    String? id,
    String? userId,
    String? exerciseId,
    String? exerciseName,
    double? weight,
    int? reps,
    DateTime? achievedAt,
    String? workoutId,
  }) {
    return PersonalRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      achievedAt: achievedAt ?? this.achievedAt,
      workoutId: workoutId ?? this.workoutId,
    );
  }

  /// Comparaison (pour tri par poids)
  int compareTo(PersonalRecord other) {
    return weight.compareTo(other.weight);
  }
}
