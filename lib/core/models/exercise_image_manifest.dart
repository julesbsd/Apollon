import 'dart:convert';
import 'package:flutter/services.dart';

/// Manifest des images d'exercices pré-téléchargées (top 20)
/// 
/// Ce manifest contient le mapping ID → filename pour les 20 exercices
/// les plus populaires dont les images SVG sont embarquées dans l'app.
/// 
/// Les autres exercices (74) seront chargés en lazy loading depuis l'API.
class ExerciseImageManifest {
  final Map<String, String> _idToFilename = {};
  
  ExerciseImageManifest._();
  
  /// Charger le manifest depuis les assets
  static Future<ExerciseImageManifest> load() async {
    final manifest = ExerciseImageManifest._();
    
    try {
      final jsonString = await rootBundle.loadString(
        'assets/exercise_images/manifest.json',
      );
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final exercises = data['preseeded_exercises'] as List<dynamic>;
      
      for (var exercise in exercises) {
        final id = exercise['id'] as String;
        final filename = exercise['filename'] as String;
        manifest._idToFilename[id] = filename;
      }
      
    } catch (e) {
    }
    
    return manifest;
  }
  
  /// Vérifier si l'exercice a une image pré-téléchargée
  bool hasPreseededImage(String exerciseId) {
    return _idToFilename.containsKey(exerciseId);
  }
  
  /// Obtenir le chemin de l'asset pour un exercice
  /// Retourne null si l'exercice n'est pas pré-seedé
  String? getAssetPath(String exerciseId) {
    final filename = _idToFilename[exerciseId];
    return filename != null ? 'assets/exercise_images/$filename' : null;
  }
  
  /// Liste de tous les IDs d'exercices pré-seedés
  List<String> get preseededIds => _idToFilename.keys.toList();
  
  /// Nombre d'exercices pré-seedés
  int get count => _idToFilename.length;
  
  /// Statistiques pour debug
  Map<String, dynamic> get stats => {
    'preseeded_count': count,
    'exercise_ids': preseededIds,
  };
}
