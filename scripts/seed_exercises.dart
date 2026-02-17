import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:apollon/firebase_options.dart';

/// Script pour importer les exercices prédéfinis (seed data) dans Firestore
/// 
/// Usage:
/// ```bash
/// dart run scripts/seed_exercises.dart
/// ```
/// 
/// IMPORTANT: 
/// - Exécuter une seule fois lors de l'initialisation du projet
/// - Nécessite Firebase configuré et initialisé
/// - Les exercices existants ne seront pas dupliqués (vérification par nom)

Future<void> main() async {
  print('🔥 Démarrage du script de seed data Firestore...\n');

  // Initialiser Firebase avec les options spécifiques au projet
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('✅ Firebase initialisé\n');

  final firestore = FirebaseFirestore.instance;

  // Lire le fichier JSON des exercices
  final file = File('assets/seed_data/exercises.json');
  if (!await file.exists()) {
    print('❌ Erreur: Fichier exercises.json non trouvé');
    print('   Chemin attendu: assets/seed_data/exercises.json');
    exit(1);
  }

  final jsonString = await file.readAsString();
  final List<dynamic> exercisesData = jsonDecode(jsonString);
  print('📄 Fichier chargé: ${exercisesData.length} exercices\n');

  // Compteurs pour statistiques
  int created = 0;
  int skipped = 0;
  int errors = 0;

  // Batch pour optimiser les écritures
  WriteBatch batch = firestore.batch();
  int batchCount = 0;
  const int maxBatchSize = 500; // Limite Firestore

  for (var exerciseData in exercisesData) {
    try {
      final String name = exerciseData['name'] as String;

      // Vérifier si l'exercice existe déjà (RG-002: Unicité des noms)
      final existingQuery = await firestore
          .collection('exercises')
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        print('⏭️  Skipped: "$name" (existe déjà)');
        skipped++;
        continue;
      }

      // Créer nouveau document exercice
      final docRef = firestore.collection('exercises').doc();

      final exerciseMap = {
        'name': name,
        'nameSearch': name.toLowerCase(), // Pour recherche textuelle
        'muscleGroups': exerciseData['muscleGroups'] as List<dynamic>,
        'type': exerciseData['type'] as String,
        'emoji': exerciseData['emoji'] as String,
        'description': exerciseData['description'] as String?,
        'createdAt': FieldValue.serverTimestamp(),
      };

      batch.set(docRef, exerciseMap);
      batchCount++;

      print('➕ Created: "$name" (${exerciseData['type']})');
      created++;

      // Commit batch si limite atteinte
      if (batchCount >= maxBatchSize) {
        await batch.commit();
        print('\n📦 Batch commit ($batchCount documents)\n');
        batch = firestore.batch();
        batchCount = 0;
      }
    } catch (e) {
      print('❌ Erreur lors de l\'ajout de "${exerciseData['name']}": $e');
      errors++;
    }
  }

  // Commit batch final
  if (batchCount > 0) {
    await batch.commit();
    print('\n📦 Batch final commit ($batchCount documents)\n');
  }

  // Afficher statistiques
  print('═══════════════════════════════════════════════');
  print('✅ IMPORT TERMINÉ');
  print('═══════════════════════════════════════════════');
  print('✅ Créés:   $created exercices');
  print('⏭️  Ignorés: $skipped exercices (doublons)');
  print('❌ Erreurs: $errors');
  print('───────────────────────────────────────────────');
  print('📊 Total:   ${exercisesData.length} exercices traités');
  print('═══════════════════════════════════════════════\n');

  // Vérifier indexes manquants
  print('⚠️  N\'OUBLIEZ PAS:');
  print('   1. Créer les indexes composites dans Firebase Console');
  print('   2. muscleGroups (array-contains) + name (ASC)');
  print('   3. type (ASC) + name (ASC)');
  print('   4. nameSearch (ASC) pour recherche textuelle');
  print('\n🔗 Firebase Console: https://console.firebase.google.com\n');
}
