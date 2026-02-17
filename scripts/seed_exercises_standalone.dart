import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Script standalone pour importer les exercices dans Firestore
/// Sans dépendance Flutter - ne fonctionne que sur Web/Desktop via firebase-core
/// 
/// Usage:
/// dart run scripts/seed_exercises_standalone.dart

Future<void> main() async {
  print('🔥 Démarrage du script de seed data Firestore...\n');

  // Initialiser Firebase avec les options hardcodées (pour éviter Flutter)
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'FIREBASE_WEB_API_KEY',
        appId: '1:182776342499:web:4f05b0d0779552bc5922d6',
        messagingSenderId: '182776342499',
        projectId: 'apollon-fitness-app',
        authDomain: 'apollon-fitness-app.firebaseapp.com',
        storageBucket: 'apollon-fitness-app.firebasestorage.app',
        measurementId: 'G-38WFHCNCT9',
      ),
    );
    print('✅ Firebase initialisé\n');
  } catch (e) {
    print('⚠️  Firebase déjà initialisé ou erreur: $e\n');
  }

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

  // Importer chaque exercice un par un
  for (var i = 0; i < exercisesData.length; i++) {
    final exerciseJson = exercisesData[i] as Map<String, dynamic>;
    final name = exerciseJson['name'] as String;

    try {
      // Vérifier si l'exercice existe déjà
      final existingDocs = await firestore
          .collection('exercises')
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (existingDocs.docs.isNotEmpty) {
        print('⏭️  [$i+1/${exercisesData.length}] Ignoré: "$name" (existe déjà)');
        skipped++;
        continue;
      }

      // Créer l'exercice
      // Générer nameSearch (nom en minuscules pour recherche)
      final exerciseData = {
        ...exerciseJson,
        'nameSearch': name.toLowerCase(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await firestore.collection('exercises').add(exerciseData);
      
      print('✅ [$i+1/${exercisesData.length}] Créé: "$name"');
      created++;
    } catch (e) {
      print('❌ [$i+1/${exercisesData.length}] Erreur: "$name" - $e');
      errors++;
    }
  }

  // Afficher statistiques finales
  print('\n${'=' * 50}');
  print('✅ IMPORT TERMINÉ');
  print('✅ Créés:   $created exercices');
  print('⏭️  Ignorés: $skipped exercices (existent déjà)');
  if (errors > 0) {
    print('❌ Erreurs: $errors');
  } else {
    print('✅ Aucune erreur');
  }
  print('=' * 50);

  exit(0);
}
