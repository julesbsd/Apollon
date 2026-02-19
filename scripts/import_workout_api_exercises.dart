import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/core/models/exercise_library.dart';
import '../lib/firebase_options.dart';

/// Script d'import des exercices Workout API vers Firestore
/// 
/// Usage:
/// ```bash
/// dart scripts/import_workout_api_exercises.dart
/// ```
/// 
/// Ce script:
/// 1. Lit le fichier JSON des exercices Workout API
/// 2. Transforme les données en objets ExerciseLibrary
/// 3. Importe les données dans Firestore (collection: exercises_library)
/// 4. Utilise batch write pour optimiser les performances
/// 
/// Prérequis:
/// - Firebase configuré (firebase_options.dart)
/// - Fichier docs/workout_api_exercises_fr.json présent
/// - Droits d'écriture sur Firestore

Future<void> main() async {
  print('🚀 Import des exercices Workout API vers Firestore\n');

  try {
    // Initialiser Firebase
    print('📱 Initialisation Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialisé\n');

    // Lire le fichier JSON
    print('📖 Lecture du fichier workout_api_exercises_fr.json...');
    final file = File('docs/workout_api_exercises_fr.json');

    if (!file.existsSync()) {
      throw Exception('Fichier workout_api_exercises_fr.json introuvable!');
    }

    final jsonString = await file.readAsString();
    final List<dynamic> exercisesJson = jsonDecode(jsonString);
    print('✅ ${exercisesJson.length} exercices trouvés\n');

    // Firestore instance
    final firestore = FirebaseFirestore.instance;
    final collection = firestore.collection('exercises_library');

    // Statistiques
    int successCount = 0;
    int errorCount = 0;
    final List<String> errors = [];

    // Batch write (plus performant que des writes individuels)
    WriteBatch batch = firestore.batch();
    int batchCount = 0;
    const batchSize = 500; // Limite Firestore

    print('📝 Import en cours...\n');

    for (var i = 0; i < exercisesJson.length; i++) {
      try {
        final exerciseJson = exercisesJson[i] as Map<String, dynamic>;

        // Convertir en ExerciseLibrary
        final exercise = ExerciseLibrary.fromWorkoutApi(exerciseJson);

        // Créer document avec ID = exercise.id
        final docRef = collection.doc(exercise.id);
        batch.set(docRef, exercise.toFirestore());

        batchCount++;
        successCount++;

        // Commit batch tous les 500 documents (limite Firestore)
        if (batchCount >= batchSize) {
          await batch.commit();
          print('   ✅ Batch de $batchCount exercices importé');
          batch = firestore.batch();
          batchCount = 0;
        }
      } catch (e) {
        errorCount++;
        errors.add('Erreur exercice ${i + 1}: $e');
        print('   ⚠️  Erreur exercice ${i + 1}: $e');
      }
    }

    // Commit dernier batch
    if (batchCount > 0) {
      await batch.commit();
      print('   ✅ Dernier batch de $batchCount exercices importé');
    }

    // Afficher résumé
    print('\n' + '=' * 50);
    print('📊 RÉSUMÉ DE L\'IMPORT');
    print('=' * 50);
    print('✅ Succès: $successCount exercices');
    print('❌ Erreurs: $errorCount exercices');
    print('📦 Total: ${exercisesJson.length} exercices');
    print('=' * 50);

    if (errors.isNotEmpty) {
      print('\n⚠️  DÉTAILS DES ERREURS:');
      for (final error in errors) {
        print('   - $error');
      }
    }

    // Vérifier dans Firestore
    print('\n🔍 Vérification dans Firestore...');
    final snapshot = await collection.get();
    print('✅ ${snapshot.docs.length} documents présents dans Firestore\n');

    // Afficher quelques exemples
    if (snapshot.docs.isNotEmpty) {
      print('📋 Exemples d\'exercices importés:');
      for (var i = 0; i < 5 && i < snapshot.docs.length; i++) {
        final data = snapshot.docs[i].data();
        final exercise = ExerciseLibrary.fromFirestore(data);
        print('   ${i + 1}. ${exercise.name} (${exercise.primaryMusclesText})');
      }
    }

    print('\n🎉 Import terminé avec succès!');
    print('💡 Vous pouvez maintenant utiliser le catalogue dans l\'app.\n');
  } catch (e, stackTrace) {
    print('\n❌ ERREUR FATALE:');
    print('$e');
    print('\nStack trace:');
    print('$stackTrace');
    exit(1);
  }
}
