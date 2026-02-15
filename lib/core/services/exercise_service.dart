import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exercise.dart';

/// Service pour gérer les exercices dans Firestore
/// Collection: 'exercises'
/// Implémente US-2.2: Récupération et filtrage des exercices
class ExerciseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Collection des exercices
  CollectionReference get _exercisesCollection => 
      _firestore.collection('exercises');

  /// Récupérer tous les exercices (Stream en temps réel)
  /// Utilisé dans ExerciseSelectionScreen pour affichage liste complète
  Stream<List<Exercise>> getAllExercises() {
    return _exercisesCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Exercise.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// Récupérer les exercices filtrés par groupe musculaire
  /// Utilisé dans ExerciseSelectionScreen pour tabs de navigation
  /// Paramètre: muscleGroup (ex: "Pectoraux", "Biceps")
  Stream<List<Exercise>> getExercisesByMuscleGroup(String muscleGroup) {
    return _exercisesCollection
        .where('muscleGroups', arrayContains: muscleGroup)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Exercise.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// Récupérer les exercices filtrés par type
  /// Utilisé dans ExerciseSelectionScreen pour sous-tabs
  /// Paramètre: type (ex: "Poids libres", "Machine guidée")
  Stream<List<Exercise>> getExercisesByType(String type) {
    return _exercisesCollection
        .where('type', isEqualTo: type)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Exercise.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// Récupérer les exercices filtrés par groupe musculaire ET type
  /// Utilisé quand les deux filtres sont actifs simultanément
  Stream<List<Exercise>> getExercisesByMuscleGroupAndType(
    String muscleGroup,
    String type,
  ) {
    return _exercisesCollection
        .where('muscleGroups', arrayContains: muscleGroup)
        .where('type', isEqualTo: type)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Exercise.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// Rechercher des exercices par nom (filtre client-side)
  /// Utilisé dans la barre de recherche de ExerciseSelectionScreen
  /// Note: Firestore ne supporte pas LIKE, donc on charge tout puis filtre
  /// Pour 50 exercices, performance acceptable
  Future<List<Exercise>> searchExercises(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final snapshot = await _exercisesCollection
        .orderBy('name')
        .get();

    final allExercises = snapshot.docs
        .map((doc) => Exercise.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    // Filtrage case-insensitive sur le nom
    final lowerQuery = query.toLowerCase();
    return allExercises
        .where((exercise) => exercise.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Récupérer un exercice par ID
  /// Utilisé pour afficher les détails d'un exercice
  Future<Exercise?> getExerciseById(String exerciseId) async {
    try {
      final doc = await _exercisesCollection.doc(exerciseId).get();
      if (!doc.exists) return null;
      return Exercise.fromFirestore(
          doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'exercice: $e');
    }
  }

  /// Créer un nouvel exercice (Admin/Seed uniquement)
  /// Non utilisé dans MVP V1 (exercices en lecture seule)
  Future<String> createExercise(Exercise exercise) async {
    try {
      final docRef = await _exercisesCollection.add(exercise.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'exercice: $e');
    }
  }

  /// Mettre à jour un exercice (Admin uniquement)
  /// Non utilisé dans MVP V1
  Future<void> updateExercise(Exercise exercise) async {
    if (exercise.id.isEmpty) {
      throw ArgumentError('L\'ID de l\'exercice est requis');
    }

    try {
      await _exercisesCollection
          .doc(exercise.id)
          .update(exercise.toFirestore());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'exercice: $e');
    }
  }

  /// Supprimer un exercice (Admin uniquement)
  /// Non utilisé dans MVP V1
  Future<void> deleteExercise(String exerciseId) async {
    try {
      await _exercisesCollection.doc(exerciseId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'exercice: $e');
    }
  }

  /// Vérifier si un exercice existe par nom (pour éviter doublons)
  /// Utilisé dans seed_service pour respecter RG-002: Unicité des noms
  Future<bool> exerciseExistsByName(String name) async {
    try {
      final snapshot = await _exercisesCollection
          .where('name', isEqualTo: name)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Erreur lors de la vérification de l\'exercice: $e');
    }
  }

  /// Compter le nombre total d'exercices
  /// Utilisé pour statistiques et validation seed
  Future<int> countExercises() async {
    try {
      final snapshot = await _exercisesCollection.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Erreur lors du comptage des exercices: $e');
    }
  }
}
