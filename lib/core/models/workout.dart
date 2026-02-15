import 'package:cloud_firestore/cloud_firestore.dart';
import 'workout_exercise.dart';

/// Modèle représentant une séance de musculation complète
/// Correspond au glossaire métier: Séance
/// Structure Firestore: users/{userId}/workouts/{workoutId}
class Workout {
  final String? id;
  final String userId;
  final DateTime date;
  final WorkoutStatus status;
  final List<WorkoutExercise> exercises;
  final int? duration; // Durée en minutes (V2)
  final DateTime createdAt;
  final DateTime updatedAt;

  Workout({
    this.id,
    required this.userId,
    required this.date,
    required this.status,
    required this.exercises,
    this.duration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Conversion depuis Firestore
  factory Workout.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Workout(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      date: (data['date'] as Timestamp).toDate(),
      status: WorkoutStatus.fromString(data['status'] as String),
      exercises: (data['exercises'] as List)
          .map((exerciseData) => WorkoutExercise.fromFirestore(
              exerciseData as Map<String, dynamic>))
          .toList(),
      duration: data['duration'] as int?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Conversion vers Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'status': status.value,
      'exercises': exercises.map((ex) => ex.toFirestore()).toList(),
      if (duration != null) 'duration': duration,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Conversion depuis JSON
  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] as String?,
      userId: json['userId'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      status: WorkoutStatus.fromString(json['status'] as String),
      exercises: (json['exercises'] as List)
          .map((exerciseData) => WorkoutExercise.fromJson(
              exerciseData as Map<String, dynamic>))
          .toList(),
      duration: json['duration'] as int?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  /// Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'status': status.value,
      'exercises': exercises.map((ex) => ex.toJson()).toList(),
      if (duration != null) 'duration': duration,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Nombre total d'exercices
  int get totalExercises => exercises.length;

  /// Nombre total de séries
  int get totalSets {
    return exercises.fold(0, (sum, ex) => sum + ex.totalSets);
  }

  /// Volume total de la séance (reps * poids)
  double get totalVolume {
    return exercises.fold(0.0, (sum, ex) => sum + ex.totalVolume);
  }

  /// Vérifier si la séance est vide (aucun exercice)
  bool get isEmpty => exercises.isEmpty;

  /// Vérifier si la séance est en cours (draft)
  bool get isDraft => status == WorkoutStatus.draft;

  /// Vérifier si la séance est terminée
  bool get isCompleted => status == WorkoutStatus.completed;

  /// Formater la date pour affichage (ex: "15/02/2026")
  String get displayDate {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }

  /// Formater la durée pour affichage (ex: "45 min")
  String get displayDuration {
    if (duration == null) return '-';
    if (duration! < 60) return '$duration min';
    final hours = duration! ~/ 60;
    final minutes = duration! % 60;
    return '${hours}h${minutes.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'Workout(id: $id, date: $displayDate, status: ${status.value}, exercises: ${exercises.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Workout && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Copier avec modifications
  Workout copyWith({
    String? id,
    String? userId,
    DateTime? date,
    WorkoutStatus? status,
    List<WorkoutExercise>? exercises,
    int? duration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Workout(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      status: status ?? this.status,
      exercises: exercises ?? this.exercises,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(), // Toujours mettre à jour
    );
  }

  /// Ajouter un exercice
  Workout addExercise(WorkoutExercise exercise) {
    return copyWith(exercises: [...exercises, exercise]);
  }

  /// Supprimer un exercice par index
  Workout removeExercise(int index) {
    if (index < 0 || index >= exercises.length) {
      throw RangeError('Index $index hors limites (0-${exercises.length - 1})');
    }
    final newExercises = List<WorkoutExercise>.from(exercises);
    newExercises.removeAt(index);
    return copyWith(exercises: newExercises);
  }

  /// Mettre à jour un exercice par index
  Workout updateExercise(int index, WorkoutExercise exercise) {
    if (index < 0 || index >= exercises.length) {
      throw RangeError('Index $index hors limites (0-${exercises.length - 1})');
    }
    final newExercises = List<WorkoutExercise>.from(exercises);
    newExercises[index] = exercise;
    return copyWith(exercises: newExercises);
  }

  /// Marquer la séance comme terminée (RG-006)
  Workout complete({int? duration}) {
    return copyWith(
      status: WorkoutStatus.completed,
      duration: duration,
    );
  }

  /// Créer une nouvelle séance draft (RG-004)
  static Workout createDraft(String userId) {
    return Workout(
      userId: userId,
      date: DateTime.now(),
      status: WorkoutStatus.draft,
      exercises: [],
    );
  }
}

/// Statut d'une séance
/// draft: Séance en cours (RG-004: persistance arrière-plan)
/// completed: Séance terminée (RG-006: sauvegarde finale)
enum WorkoutStatus {
  draft('draft'),
  completed('completed');

  final String value;
  const WorkoutStatus(this.value);

  static WorkoutStatus fromString(String value) {
    return WorkoutStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => WorkoutStatus.draft,
    );
  }
}
