import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service pour télécharger et sauvegarder les images d'exercices
/// 
/// Workflow:
/// 1. Image demandée (au clic sur exercice)
/// 2. Check si déjà téléchargée localement
/// 3. Si non → télécharger depuis API et sauvegarder
/// 4. Mettre à jour manifest local (persistent)
/// 5. Retourner chemin fichier local
class ExerciseImageDownloader {
  final String _apiKey;
  static const String _manifestKey = 'downloaded_exercise_images_manifest';
  
  // Cache en mémoire du manifest des images téléchargées
  Map<String, String>? _downloadedImagesManifest;
  
  ExerciseImageDownloader({required String apiKey}) : _apiKey = apiKey;
  
  /// Obtenir le répertoire de stockage des images téléchargées
  Future<Directory> get _imagesDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/exercise_images');
    
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    
    return imagesDir;
  }
  
  /// Charger le manifest des images déjà téléchargées
  Future<Map<String, String>> _loadDownloadedManifest() async {
    if (_downloadedImagesManifest != null) {
      return _downloadedImagesManifest!;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final manifestJson = prefs.getString(_manifestKey);
    
    if (manifestJson != null) {
      try {
        final decoded = jsonDecode(manifestJson) as Map<String, dynamic>;
        _downloadedImagesManifest = decoded.cast<String, String>();
      } catch (e) {
        _downloadedImagesManifest = {};
      }
    } else {
      _downloadedImagesManifest = {};
    }
    
    return _downloadedImagesManifest!;
  }
  
  /// Sauvegarder le manifest des images téléchargées
  Future<void> _saveDownloadedManifest(Map<String, String> manifest) async {
    final prefs = await SharedPreferences.getInstance();
    final manifestJson = jsonEncode(manifest);
    await prefs.setString(_manifestKey, manifestJson);
    _downloadedImagesManifest = manifest;
  }
  
  /// Vérifier si une image est déjà téléchargée localement
  Future<bool> isDownloaded(String exerciseId) async {
    final manifest = await _loadDownloadedManifest();
    
    if (!manifest.containsKey(exerciseId)) {
      return false;
    }
    
    // Vérifier que le fichier existe toujours
    final filePath = manifest[exerciseId]!;
    final file = File(filePath);
    
    if (!await file.exists()) {
      // Fichier supprimé, retirer du manifest
      manifest.remove(exerciseId);
      await _saveDownloadedManifest(manifest);
      return false;
    }
    
    return true;
  }
  
  /// Obtenir le chemin local d'une image téléchargée
  Future<String?> getLocalPath(String exerciseId) async {
    final manifest = await _loadDownloadedManifest();
    return manifest[exerciseId];
  }
  
  /// Télécharger et sauvegarder une image d'exercice
  /// Retourne le chemin local du fichier sauvegardé
  Future<String?> downloadAndSave(String exerciseId) async {
    try {
      
      // Télécharger depuis API
      final response = await http.get(
        Uri.parse('https://api.workoutapi.com/exercises/$exerciseId/image'),
        headers: {
          'x-api-key': _apiKey,
          'Accept': 'image/svg+xml',
        },
      );
      
      if (response.statusCode != 200) {
        return null;
      }
      
      // Sauvegarder dans le stockage local
      final imagesDir = await _imagesDirectory;
      final filename = '$exerciseId.svg';
      final file = File('${imagesDir.path}/$filename');
      
      await file.writeAsBytes(response.bodyBytes);
      
      // Mettre à jour manifest
      final manifest = await _loadDownloadedManifest();
      manifest[exerciseId] = file.path;
      await _saveDownloadedManifest(manifest);
      
      return file.path;
    } catch (e) {
      return null;
    }
  }
  
  /// Statistiques
  Future<Map<String, dynamic>> getStats() async {
    final manifest = await _loadDownloadedManifest();
    final imagesDir = await _imagesDirectory;
    
    // Calculer taille totale
    int totalSize = 0;
    for (final filePath in manifest.values) {
      final file = File(filePath);
      if (await file.exists()) {
        totalSize += await file.length();
      }
    }
    
    return {
      'downloaded_count': manifest.length,
      'total_size_kb': (totalSize / 1024).toStringAsFixed(1),
      'storage_path': imagesDir.path,
    };
  }
  
  /// Nettoyer toutes les images téléchargées (pour debug/maintenance)
  Future<void> clearAll() async {
    final imagesDir = await _imagesDirectory;
    
    if (await imagesDir.exists()) {
      await imagesDir.delete(recursive: true);
    }
    
    await _saveDownloadedManifest({});
  }
}
