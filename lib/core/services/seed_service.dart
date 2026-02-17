import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

/// Service pour importer les exercices seed data dans Firestore
///
/// Utilisation: SeedService().importExercises()
/// A executer une seule fois lors de l'initialisation du projet
class SeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Importe les exercices depuis assets/seed_data/exercises.json
  /// Respecte RG-002: Unicite des noms (skip si exercice existe deja)
  Future<Map<String, int>> importExercises() async {
    int created = 0;
    int skipped = 0;
    int errors = 0;

    try {
      print('Demarrage import exercices...');

      // Charger JSON depuis assets
      final jsonString = await rootBundle.loadString(
        'assets/seed_data/exercises.json',
      );
      final List<dynamic> exercisesJson = jsonDecode(jsonString);

      print('Fichier charge: ${exercisesJson.length} exercices');

      // Importer dans Firestore
      for (var exerciseData in exercisesJson) {
        try {
          final name = exerciseData['name'] as String;

          // Verifier si exercice existe deja (RG-002: Unicite noms)
          final existing = await _firestore
              .collection('exercises')
              .where('name', isEqualTo: name)
              .limit(1)
              .get();

          if (existing.docs.isEmpty) {
            // Creer nouvel exercice
            await _firestore.collection('exercises').add({
              'name': name,
              'nameSearch': name
                  .toLowerCase(), // Pour recherche textuelle (lowercase)
              'muscleGroups': exerciseData['muscleGroups'] as List<dynamic>,
              'type': exerciseData['type'] as String,
              'emoji': exerciseData['emoji'] as String,
              'description': exerciseData['description'] as String?,
              'createdAt': FieldValue.serverTimestamp(),
            });
            print('Cree: "$name" (${exerciseData['type']})');
            created++;
          } else {
            print('Ignore: "$name" (existe deja)');
            skipped++;
          }
        } catch (e) {
          print('Erreur: ${exerciseData['name']} - $e');
          errors++;
        }
      }

      print('\n===================================');
      print('IMPORT TERMINE');
      print('===================================');
      print('Crees:   $created exercices');
      print('Ignores: $skipped exercices');
      print('Erreurs: $errors');
      print('===================================\n');

      return {'created': created, 'skipped': skipped, 'errors': errors};
    } catch (e) {
      print('Erreur lors du chargement du fichier JSON: $e');
      rethrow;
    }
  }
}
