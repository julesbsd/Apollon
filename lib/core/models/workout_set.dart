/// Modèle représentant une série d'un exercice
/// Correspond au glossaire métier: Série
/// Respecte RG-003: Validation des données (reps > 0, weight >= 0)
class WorkoutSet {
  final int reps;
  final double weight;

  WorkoutSet({required this.reps, required this.weight}) {
    // RG-003: Validation des données de série
    if (reps <= 0) {
      throw ArgumentError(
        'Le nombre de répétitions doit être supérieur à 0 (reps: $reps)',
      );
    }
    if (weight < 0) {
      throw ArgumentError(
        'Le poids doit être supérieur ou égal à 0 (weight: $weight)',
      );
    }
  }

  /// Conversion depuis Firestore
  factory WorkoutSet.fromFirestore(Map<String, dynamic> data) {
    return WorkoutSet(
      reps: data['reps'] as int,
      weight: (data['weight'] as num).toDouble(),
    );
  }

  /// Conversion vers Firestore
  Map<String, dynamic> toFirestore() {
    return {'reps': reps, 'weight': weight};
  }

  /// Conversion depuis JSON
  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      reps: json['reps'] as int,
      weight: (json['weight'] as num).toDouble(),
    );
  }

  /// Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {'reps': reps, 'weight': weight};
  }

  /// Vérifier si c'est une série au poids de corps (0 kg)
  bool get isBodyweight => weight == 0;

  /// Formater pour affichage (ex: "12 reps × 80kg" ou "12 reps (poids de corps)")
  String display() {
    if (isBodyweight) {
      return '$reps reps (poids de corps)';
    }
    return '$reps reps × ${weight.toStringAsFixed(1)}kg';
  }

  @override
  String toString() {
    return 'WorkoutSet(reps: $reps, weight: $weight)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutSet && other.reps == reps && other.weight == weight;
  }

  @override
  int get hashCode => reps.hashCode ^ weight.hashCode;

  /// Copier avec modifications
  WorkoutSet copyWith({int? reps, double? weight}) {
    return WorkoutSet(reps: reps ?? this.reps, weight: weight ?? this.weight);
  }
}
