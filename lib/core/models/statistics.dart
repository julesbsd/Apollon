/// Modèle pour les statistiques globales de l'utilisateur
/// Utilisé dans l'écran StatisticsScreen (EPIC-V2-1)
class Statistics {
  final int totalWorkouts;          // Nombre total de séances
  final int monthWorkouts;          // Séances ce mois
  final double totalVolume;         // Volume total (kg) ce mois
  final int currentStreak;          // Jours consécutifs avec séance
  final int bestStreak;             // Meilleur streak all time
  final String? mostFrequentExercise; // Exercice le plus fréquent
  final int totalExercises;         // Nombre total d'exercices différents
  final DateTime? lastWorkoutDate;  // Date dernière séance

  Statistics({
    required this.totalWorkouts,
    required this.monthWorkouts,
    required this.totalVolume,
    required this.currentStreak,
    required this.bestStreak,
    this.mostFrequentExercise,
    required this.totalExercises,
    this.lastWorkoutDate,
  });

  /// Statistiques vides par défaut
  factory Statistics.empty() {
    return Statistics(
      totalWorkouts: 0,
      monthWorkouts: 0,
      totalVolume: 0,
      currentStreak: 0,
      bestStreak: 0,
      totalExercises: 0,
    );
  }
}

/// Point de données pour les graphiques de progression
class ProgressDataPoint {
  final DateTime date;
  final double value;          // Poids, volume, ou autre métrique
  final String? workoutId;     // Référence à la séance

  ProgressDataPoint({
    required this.date,
    required this.value,
    this.workoutId,
  });
}

/// Données pour le graphique de volume hebdomadaire/mensuel
class VolumeDataPoint {
  final DateTime date;
  final double volume;         // Volume total en kg
  final int workoutCount;      // Nombre de séances dans la période

  VolumeDataPoint({
    required this.date,
    required this.volume,
    required this.workoutCount,
  });
}
