/// Modèle représentant un exercice de musculation
/// Correspond au glossaire métier: Exercice
/// Structure Firestore: collection 'exercises'
class Exercise {
  final String id;
  final String name;
  final List<String> muscleGroups;
  final String type;
  final String emoji;
  final String? description;

  Exercise({
    required this.id,
    required this.name,
    required this.muscleGroups,
    required this.type,
    required this.emoji,
    this.description,
  });

  /// Conversion depuis Firestore
  factory Exercise.fromFirestore(Map<String, dynamic> data, String id) {
    return Exercise(
      id: id,
      name: data['name'] as String,
      muscleGroups: List<String>.from(data['muscleGroups'] as List),
      type: data['type'] as String,
      emoji: data['emoji'] as String,
      description: data['description'] as String?,
    );
  }

  /// Conversion vers Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'muscleGroups': muscleGroups,
      'type': type,
      'emoji': emoji,
      if (description != null) 'description': description,
    };
  }

  /// Conversion depuis JSON (pour parsing assets)
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String? ?? '',
      name: json['name'] as String,
      muscleGroups: List<String>.from(json['muscleGroups'] as List),
      type: json['type'] as String,
      emoji: json['emoji'] as String,
      description: json['description'] as String?,
    );
  }

  /// Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'muscleGroups': muscleGroups,
      'type': type,
      'emoji': emoji,
      if (description != null) 'description': description,
    };
  }

  @override
  String toString() {
    return 'Exercise(id: $id, name: $name, type: $type, muscleGroups: $muscleGroups)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Exercise && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Types d'exercices possibles
/// Correspond au glossaire métier: Type d'exercice
class ExerciseType {
  static const String freeWeights = 'Poids libres';
  static const String machine = 'Machine guidée';
  static const String bodyWeight = 'Poids corporel';
  static const String cardio = 'Cardio';

  static const List<String> all = [freeWeights, machine, bodyWeight, cardio];
}

/// Groupes musculaires possibles
/// Correspond au glossaire métier: Groupe musculaire
class MuscleGroup {
  static const String chest = 'Pectoraux';
  static const String back = 'Dorsaux';
  static const String shoulders = 'Épaules';
  static const String biceps = 'Biceps';
  static const String triceps = 'Triceps';
  static const String abs = 'Abdominaux';
  static const String quadriceps = 'Quadriceps';
  static const String hamstrings = 'Ischio-jambiers';
  static const String glutes = 'Fessiers';
  static const String calves = 'Mollets';

  static const List<String> all = [
    chest,
    back,
    shoulders,
    biceps,
    triceps,
    abs,
    quadriceps,
    hamstrings,
    glutes,
    calves,
  ];

  /// Regroupement par catégories principales pour navigation
  static const Map<String, List<String>> categories = {
    'Haut du corps': [chest, back, shoulders, biceps, triceps],
    'Abdominaux': [abs],
    'Bas du corps': [quadriceps, hamstrings, glutes, calves],
  };
}
