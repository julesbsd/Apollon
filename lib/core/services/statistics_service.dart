import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout.dart';
import '../models/statistics.dart';
import '../models/personal_record.dart';

/// Service pour calculer les statistiques et données de graphiques
/// Implémente US-V2-1.1 à US-V2-1.5
class StatisticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Référence collection workouts utilisateur
  CollectionReference _workoutsCollection(String userId) {
    return _firestore.collection('users'). doc(userId).collection('workouts');
  }

  /// Référence collection personal records
  CollectionReference _recordsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('personal_records');
  }

  /// US-V2-1.1: Calculer statistiques globales
  Future<Statistics> getGlobalStatistics(String userId) async {
    try {
      // Récupérer toutes les séances terminées
      final allWorkouts = await _workoutsCollection(userId)
          .where('status', isEqualTo: WorkoutStatus.completed.value)
          .orderBy('date', descending: true)
          .get();

      if (allWorkouts.docs.isEmpty) {
        return Statistics.empty();
      }

      final workouts = allWorkouts.docs
          .map((doc) => Workout.fromFirestore(doc))
          .toList();

      // Calculer stats du mois en cours
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final monthWorkouts = workouts.where((w) => w.date.isAfter(startOfMonth)).toList();

      // Volume total du mois (somme de tous les poids × reps)
      double monthVolume = 0;
      for (final workout in monthWorkouts) {
        monthVolume += workout.totalVolume;
      }

      // Calculer streak actuel et meilleur streak
      final streakData = _calculateStreaks(workouts);

      // Exercice le plus fréquent
      final mostFrequent = _getMostFrequentExercise(workouts);

      // Nombre total d'exercices différents testés
      final uniqueExercises = <String>{};
      for (final workout in workouts) {
        for (final ex in workout.exercises) {
          uniqueExercises.add(ex.exerciseId);
        }
      }

      return Statistics(
        totalWorkouts: workouts.length,
        monthWorkouts: monthWorkouts.length,
        totalVolume: monthVolume,
        currentStreak: streakData['current']!,
        bestStreak: streakData['best']!,
        mostFrequentExercise: mostFrequent,
        totalExercises: uniqueExercises.length,
        lastWorkoutDate: workouts.first.date,
      );
    } catch (e) {
      throw Exception('Erreur lors du calcul des statistiques: $e');
    }
  }

  /// US-V2-1.2: Données pour graphique progression exercice
  Future<List<ProgressDataPoint>> getExerciseProgressData(
    String userId,
    String exerciseId, {
    int lastNWorkouts = 20,
  }) async {
    try {
      // Récupérer les séances contenant cet exercice
      final workoutsSnapshot = await _workoutsCollection(userId)
          .where('status', isEqualTo: WorkoutStatus.completed.value)
          .orderBy('date', descending: true)
          .limit(50) // On récupère plus au cas où
          .get();

      final List<ProgressDataPoint> dataPoints = [];

      for (final doc in workoutsSnapshot.docs) {
        final workout = Workout.fromFirestore(doc);

        // Chercher l'exercice dans la séance
        try {
          final exercise = workout.exercises.firstWhere(
            (ex) => ex.exerciseId == exerciseId,
          );

          if (exercise.sets.isEmpty) continue;

        // Prendre le poids maximal de cette séance
        final maxWeight = exercise.sets
            .map((s) => s.weight)
            .reduce((a, b) => a > b ? a : b);

          dataPoints.add(ProgressDataPoint(
            date: workout.date,
            value: maxWeight,
            workoutId: workout.id,
          ));

          if (dataPoints.length >= lastNWorkouts) break;
        } catch (e) {
          // Exercice pas trouvé dans cette séance, on continue
          continue;
        }
      }

      // Trier par date croissante pour le graphique
      dataPoints.sort((a, b) => a.date.compareTo(b.date));

      return dataPoints;
    } catch (e) {
      return [];
    }
  }

  /// US-V2-1.3: Données pour graphique volume total
  Future<List<VolumeDataPoint>> getVolumeByPeriod(
    String userId, {
    required int weeks,
  }) async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: weeks * 7));

      final workoutsSnapshot = await _workoutsCollection(userId)
          .where('status', isEqualTo: WorkoutStatus.completed.value)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .orderBy('date', descending: false)
          .get();

      final workouts = workoutsSnapshot.docs
          .map((doc) => Workout.fromFirestore(doc))
          .toList();

      // Grouper par semaine
      final Map<int, VolumeDataPoint> weeklyData = {};

      for (final workout in workouts) {
        // Calculer le numéro de semaine (0 = semaine la plus ancienne)
        final daysDiff = workout.date.difference(startDate).inDays;
        final weekNumber = daysDiff ~/ 7;

        if (weeklyData.containsKey(weekNumber)) {
          final existing = weeklyData[weekNumber]!;
          weeklyData[weekNumber] = VolumeDataPoint(
            date: existing.date,
            volume: existing.volume + workout.totalVolume,
            workoutCount: existing.workoutCount + 1,
          );
        } else {
          weeklyData[weekNumber] = VolumeDataPoint(
            date: startDate.add(Duration(days: weekNumber * 7)),
            volume: workout.totalVolume,
            workoutCount: 1,
          );
        }
      }

      // Convertir en liste triée
      final dataPoints = weeklyData.values.toList();
      dataPoints.sort((a, b) => a.date.compareTo(b.date));

      return dataPoints;
    } catch (e) {
      return [];
    }
  }

  /// US-V2-1.4: Récupérer tous les records personnels
  /// Un seul record par exercice (le plus lourd)
  Future<List<PersonalRecord>> getAllPersonalRecords(String userId) async {
    try {
      print('📥 Fetching all personal records for user: $userId');
      final snapshot = await _recordsCollection(userId).get();

      print('📊 Found ${snapshot.docs.length} PR documents in Firestore');
      
      // Grouper par exercice et garder seulement le poids max
      final Map<String, PersonalRecord> bestRecords = {};
      
      for (final doc in snapshot.docs) {
        final record = PersonalRecord.fromFirestore(doc);
        final existing = bestRecords[record.exerciseId];
        
        // Si pas de record existant pour cet exercice ou si le nouveau est plus lourd
        if (existing == null || record.weight > existing.weight) {
          bestRecords[record.exerciseId] = record;
        }
      }
      
      final records = bestRecords.values.toList();
      // Trier par date décroissante (plus récent en premier)
      records.sort((a, b) => b.achievedAt.compareTo(a.achievedAt));
          
      print('✅ Returning ${records.length} unique PRs (one per exercise)');
      return records;
    } catch (e) {
      print('❌ Error fetching personal records: $e');
      return [];
    }
  }

  /// US-V2-1.4: Détecter et sauvegarder un nouveau PR
  Future<PersonalRecord?> detectAndSaveNewPR(
    String userId,
    String exerciseId,
    String exerciseName,
    double weight,
    int reps,
    String? workoutId,
  ) async {
    try {
      print('🔍 Checking PR for $exerciseName: ${weight}kg x $reps reps');
      
      // Vérifier si c'est un nouveau record (sans orderBy pour éviter problème d'index)
      final existingPRs = await _recordsCollection(userId)
          .where('exerciseId', isEqualTo: exerciseId)
          .get();

      print('📊 Existing PRs found: ${existingPRs.docs.length}');
      
      bool isNewRecord = false;
      double currentMaxWeight = 0;
      
      if (existingPRs.docs.isEmpty) {
        // Aucun record existant, c'est forcément un nouveau record
        isNewRecord = true;
        print('✨ First PR for this exercise!');
      } else {
        // Trouver le poids max parmi tous les records existants
        for (final doc in existingPRs.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final existingWeight = (data['weight'] as num).toDouble();
          if (existingWeight > currentMaxWeight) {
            currentMaxWeight = existingWeight;
          }
        }
        
        print('📈 Current record: ${currentMaxWeight}kg');
        
        if (weight > currentMaxWeight) {
          isNewRecord = true;
          print('🎉 New PR! ${weight}kg > ${currentMaxWeight}kg');
        } else {
          print('❌ Not a PR: ${weight}kg <= ${currentMaxWeight}kg');
        }
      }

      // Si c'est un nouveau record, le sauvegarder
      if (isNewRecord) {
        final newPR = PersonalRecord(
          userId: userId,
          exerciseId: exerciseId,
          exerciseName: exerciseName,
          weight: weight,
          reps: reps,
          achievedAt: DateTime.now(),
          workoutId: workoutId,
        );

        final docRef = await _recordsCollection(userId).add(newPR.toFirestore());
        print('💾 PR saved with ID: ${docRef.id}');
        return newPR.copyWith(id: docRef.id);
      }

      return null; // Pas de nouveau PR
    } catch (e) {
      print('❌ Error detecting PR: $e');
      print('Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  /// Calculer streak actuel et meilleur streak
  Map<String, int> _calculateStreaks(List<Workout> workouts) {
    if (workouts.isEmpty) return {'current': 0, 'best': 0};

    // Trier par date décroissante
    final sorted = List<Workout>.from(workouts);
    sorted.sort((a, b) => b.date.compareTo(a.date));

    int currentStreak = 0;
    int bestStreak = 0;
    DateTime? lastDate;

    for (final workout in sorted) {
      if (lastDate == null) {
        currentStreak = 1;
        bestStreak = 1;
        lastDate = workout.date;
        continue;
      }

      final daysDiff = lastDate.difference(workout.date).inDays;

      if (daysDiff == 1) {
        // Jours consécutifs
        currentStreak++;
        if (currentStreak > bestStreak) {
          bestStreak = currentStreak;
        }
      } else if (daysDiff > 1) {
        // Streak interrompu
        currentStreak = 1;
      }

      lastDate = workout.date;
    }

    // Vérifier si le streak actuel est toujours valide (dernière séance récente)
    final daysSinceLastWorkout = DateTime.now().difference(sorted.first.date).inDays;
    if (daysSinceLastWorkout > 1) {
      currentStreak = 0;
    }

    return {'current': currentStreak, 'best': bestStreak};
  }

  /// Trouver l'exercice le plus fréquent
  String? _getMostFrequentExercise(List<Workout> workouts) {
    final Map<String, int> exerciseCount = {};

    for (final workout in workouts) {
      for (final ex in workout.exercises) {
        exerciseCount[ex.exerciseName] =
            (exerciseCount[ex.exerciseName] ?? 0) + 1;
      }
    }

    if (exerciseCount.isEmpty) return null;

    // Trouver le plus fréquent
    return exerciseCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}
