import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout.dart';
import '../models/workout_exercise.dart';

/// Service pour gérer les séances de musculation dans Firestore
/// Collection: users/{userId}/workouts
/// Implémente US-2.3: CRUD des séances et récupération de l'historique
class WorkoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Récupérer la collection des workouts pour un utilisateur
  CollectionReference _workoutsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('workouts');
  }

  /// Créer une nouvelle séance (draft)
  /// Implémente RG-004: Persistance arrière-plan
  /// Retourne: workoutId de la séance créée
  Future<String> createWorkout(String userId, Workout workout) async {
    try {
      final docRef = await _workoutsCollection(userId)
          .add(workout.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de la création de la séance: $e');
    }
  }

  /// Mettre à jour une séance existante
  /// Utilisé pour:
  /// - Auto-save toutes les 10s (RG-004)
  /// - Ajouter/supprimer exercices ou séries
  /// - Finaliser la séance (RG-006)
  Future<void> updateWorkout(String userId, Workout workout) async {
    if (workout.id == null || workout.id!.isEmpty) {
      throw ArgumentError('L\'ID de la séance est requis pour la mise à jour');
    }

    try {
      await _workoutsCollection(userId)
          .doc(workout.id)
          .update(workout.toFirestore());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la séance: $e');
    }
  }

  /// Récupérer toutes les séances d'un utilisateur (Stream en temps réel)
  /// Utilisé dans HistoryScreen pour afficher la liste
  /// Triées par date décroissante (plus récentes en premier)
  Stream<List<Workout>> getWorkouts(String userId) {
    return _workoutsCollection(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Workout.fromFirestore(doc))
            .toList());
  }

  /// Récupérer uniquement les séances terminées (completed)
  /// Filtre les drafts (EC-002: brouillons abandonnés)
  Stream<List<Workout>> getCompletedWorkouts(String userId) {
    return _workoutsCollection(userId)
        .where('status', isEqualTo: WorkoutStatus.completed.value)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Workout.fromFirestore(doc))
            .toList());
  }

  /// Récupérer le brouillon en cours (draft)
  /// Utilisé au démarrage pour vérifier si une séance est en cours (RG-004)
  /// Retourne null si aucun brouillon
  Future<Workout?> getCurrentDraft(String userId) async {
    try {
      final snapshot = await _workoutsCollection(userId)
          .where('status', isEqualTo: WorkoutStatus.draft.value)
          .orderBy('updatedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return Workout.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du brouillon: $e');
    }
  }

  /// Récupérer une séance par ID
  /// Utilisé pour afficher le détail d'une séance dans HistoryScreen
  Future<Workout?> getWorkoutById(String userId, String workoutId) async {
    try {
      final doc = await _workoutsCollection(userId).doc(workoutId).get();
      if (!doc.exists) return null;
      return Workout.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la séance: $e');
    }
  }

  /// Récupérer la dernière séance où un exercice a été effectué
  /// Implémente RG-005: Affichage historique exercice
  /// Utilisé dans WorkoutSessionScreen pour afficher les derniers poids/reps
  /// Retourne null si aucune séance trouvée pour cet exercice
  Future<WorkoutExercise?> getLastWorkoutForExercise(
    String userId,
    String exerciseId,
  ) async {
    try {
      // Récupérer les séances terminées triées par date décroissante
      final snapshot = await _workoutsCollection(userId)
          .where('status', isEqualTo: WorkoutStatus.completed.value)
          .orderBy('date', descending: true)
          .limit(20) // Optimisation: limiter à 20 séances récentes
          .get();

      // Chercher la première séance contenant cet exercice
      for (final doc in snapshot.docs) {
        final workout = Workout.fromFirestore(doc);
        
        // Chercher l'exercice dans la séance
        for (final exercise in workout.exercises) {
          if (exercise.exerciseId == exerciseId) {
            return exercise;
          }
        }
      }

      return null; // Aucune séance trouvée pour cet exercice
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération de l\'historique exercice: $e');
    }
  }

  /// Supprimer une séance (EC-004)
  /// Utilisé dans HistoryScreen avec confirmation
  Future<void> deleteWorkout(String userId, String workoutId) async {
    try {
      await _workoutsCollection(userId).doc(workoutId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la séance: $e');
    }
  }

  /// Finaliser une séance (RG-006: Sauvegarde finale)
  /// Change le status de draft à completed
  /// Utilisé dans WorkoutSessionScreen lors du clic "Terminer la séance"
  Future<void> completeWorkout(
    String userId,
    String workoutId, {
    int? duration,
  }) async {
    try {
      await _workoutsCollection(userId).doc(workoutId).update({
        'status': WorkoutStatus.completed.value,
        if (duration != null) 'duration': duration,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erreur lors de la finalisation de la séance: $e');
    }
  }

  /// Supprimer les brouillons abandonnés (> 24h)
  /// Implémente EC-002: Nettoyage automatique des drafts
  /// À appeler au démarrage de l'app
  Future<int> cleanupOldDrafts(String userId) async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(hours: 24));
      final snapshot = await _workoutsCollection(userId)
          .where('status', isEqualTo: WorkoutStatus.draft.value)
          .where('updatedAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      int deletedCount = 0;
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
        deletedCount++;
      }

      return deletedCount;
    } catch (e) {
      throw Exception(
          'Erreur lors du nettoyage des brouillons: $e');
    }
  }

  /// Compter le nombre de séances terminées
  /// Utilisé pour statistiques (V2)
  Future<int> countCompletedWorkouts(String userId) async {
    try {
      final snapshot = await _workoutsCollection(userId)
          .where('status', isEqualTo: WorkoutStatus.completed.value)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception(
          'Erreur lors du comptage des séances: $e');
    }
  }

  /// Récupérer les séances d'une période
  /// Utilisé pour filtrage dans HistoryScreen (US-5.3)
  Stream<List<Workout>> getWorkoutsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _workoutsCollection(userId)
        .where('status', isEqualTo: WorkoutStatus.completed.value)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Workout.fromFirestore(doc))
            .toList());
  }
}
