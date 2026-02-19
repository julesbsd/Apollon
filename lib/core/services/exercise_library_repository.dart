
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exercise_library.dart';
import '../models/exercise_image_manifest.dart';
import 'exercise_image_downloader.dart';

/// Types de source d'image pour un exercice
enum ImageSourceType {
  /// Image pré-téléchargée dans les assets (top 20)
  asset,
  /// Image téléchargée et sauvegardée localement (permanent)
  local,
  /// Image à charger depuis l'API Workout (lazy loading)
  remote,
}

/// Informations sur la source d'une image d'exercice
class ImageSource {
  final ImageSourceType type;
  final String path; // Asset path, local file path, ou URL API
  
  const ImageSource.asset(this.path) : type = ImageSourceType.asset;
  const ImageSource.local(this.path) : type = ImageSourceType.local;
  const ImageSource.remote(this.path) : type = ImageSourceType.remote;
  
  bool get isAsset => type == ImageSourceType.asset;
  bool get isLocal => type == ImageSourceType.local;
  bool get isRemote => type == ImageSourceType.remote;
}

/// Repository pour gérer les exercices du catalogue Workout API
/// Collection Firestore: 'exercises_library'
/// 
/// Features:
/// - Cache en mémoire pour performance
/// - Stratégie triple images: 
///   1. Top 20 dans assets (instantané)
///   2. Téléchargés localement (permanent)
///   3. API lazy loading (télécharge et sauvegarde au clic)
class ExerciseLibraryRepository {
  final FirebaseFirestore _firestore;
  final ExerciseImageManifest _manifest;
  final ExerciseImageDownloader _downloader;
  final String _apiKey;

  // Cache en mémoire pour performance (éviter requêtes répétées)
  List<ExerciseLibrary>? _cachedExercises;
  DateTime? _cacheTimestamp;
  static const _cacheDuration = Duration(minutes: 30);

  ExerciseLibraryRepository({
    FirebaseFirestore? firestore,
    required ExerciseImageManifest manifest,
    required String apiKey,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _manifest = manifest,
        _apiKey = apiKey,
        _downloader = ExerciseImageDownloader(apiKey: apiKey);

  /// Collection des exercices de la bibliothèque
  CollectionReference get _exercisesCollection =>
      _firestore.collection('exercises_library');

  /// Récupérer tous les exercices (avec cache)
  /// Performance: ~100ms première fois, instantané ensuite
  Future<List<ExerciseLibrary>> getAll() async {
    // Vérifier cache
    if (_cachedExercises != null && _isCacheValid()) {
      return _cachedExercises!;
    }

    // Récupérer depuis Firestore
    final snapshot = await _exercisesCollection.orderBy('name').get();

    _cachedExercises = snapshot.docs
        .map((doc) =>
            ExerciseLibrary.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList();

    _cacheTimestamp = DateTime.now();

    return _cachedExercises!;
  }

  /// Vérifier si le cache est encore valide
  bool _isCacheValid() {
    if (_cacheTimestamp == null) return false;
    return DateTime.now().difference(_cacheTimestamp!) < _cacheDuration;
  }

  /// Invalider le cache (forcer rechargement)
  void invalidateCache() {
    _cachedExercises = null;
    _cacheTimestamp = null;
  }

  /// Recherche textuelle (client-side pour performance)
  /// Cherche dans le nom et la description
  Future<List<ExerciseLibrary>> search(String query) async {
    final allExercises = await getAll();
    
    if (query.isEmpty) return allExercises;

    final lowerQuery = query.toLowerCase();

    return allExercises.where((ex) {
      return ex.name.toLowerCase().contains(lowerQuery) ||
          ex.description.toLowerCase().contains(lowerQuery) ||
          ex.code.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Filtrer par muscle primaire
  /// Paramètre: muscleCode (ex: 'CHEST', 'BICEPS')
  Future<List<ExerciseLibrary>> filterByMuscle(String muscleCode) async {
    final allExercises = await getAll();

    return allExercises
        .where((ex) => ex.primaryMuscles.any((m) => m.code == muscleCode))
        .toList();
  }

  /// Filtrer par catégorie d'équipement
  /// Paramètre: categoryCode (ex: 'FREE_WEIGHT', 'MACHINE')
  Future<List<ExerciseLibrary>> filterByCategory(String categoryCode) async {
    final allExercises = await getAll();

    return allExercises
        .where((ex) => ex.categories.any((c) => c.code == categoryCode))
        .toList();
  }

  /// Filtrer par type d'exercice
  /// Paramètre: typeCode (ex: 'ISOLATION', 'COMPOUND')
  Future<List<ExerciseLibrary>> filterByType(String typeCode) async {
    final allExercises = await getAll();

    return allExercises
        .where((ex) => ex.types.any((t) => t.code == typeCode))
        .toList();
  }

  /// Filtres combinés (muscle + catégorie)
  Future<List<ExerciseLibrary>> filterByCriteria({
    String? muscleCode,
    String? categoryCode,
    String? typeCode,
    String? searchQuery,
  }) async {
    var filtered = await getAll();

    // Filtre muscle
    if (muscleCode != null) {
      filtered = filtered
          .where((ex) => ex.primaryMuscles.any((m) => m.code == muscleCode))
          .toList();
    }

    // Filtre catégorie
    if (categoryCode != null) {
      filtered = filtered
          .where((ex) => ex.categories.any((c) => c.code == categoryCode))
          .toList();
    }

    // Filtre type
    if (typeCode != null) {
      filtered = filtered
          .where((ex) => ex.types.any((t) => t.code == typeCode))
          .toList();
    }

    // Filtre recherche
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final lowerQuery = searchQuery.toLowerCase();
      filtered = filtered.where((ex) {
        return ex.name.toLowerCase().contains(lowerQuery) ||
            ex.description.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    return filtered;
  }

  /// Récupérer la source de l'image d'un exercice (stratégie triple)
  /// 
  /// Workflow:
  /// 1. Check si exercice est dans le top 20 (assets)
  /// 2. Check si exercice est déjà téléchargé localement
  /// 3. Sinon → retourner URL API (sera téléchargé au premier affichage)
  Future<ImageSource> getImageSource(String exerciseId) async {
    // Stratégie 1: Vérifier si image pré-téléchargée (top 20)
    if (_manifest.hasPreseededImage(exerciseId)) {
      final assetPath = _manifest.getAssetPath(exerciseId)!;
      return ImageSource.asset(assetPath);
    }
    
    // Stratégie 2: Vérifier si déjà téléchargée localement
    if (await _downloader.isDownloaded(exerciseId)) {
      final localPath = await _downloader.getLocalPath(exerciseId);
      if (localPath != null) {
        return ImageSource.local(localPath);
      }
    }
    
    // Stratégie 3: URL API (sera téléchargée)
    final apiUrl = 'https://api.workoutapi.com/exercises/$exerciseId/image';
    return ImageSource.remote(apiUrl);
  }
  
  /// Télécharger et sauvegarder une image de façon permanente
  /// À appeler quand on veut télécharger l'image (ex: au clic)
  Future<String?> downloadImage(String exerciseId) async {
    return await _downloader.downloadAndSave(exerciseId);
  }
  
  /// Obtenir les headers HTTP pour appeler l'API Workout
  Map<String, String> get apiHeaders => {
    'x-api-key': _apiKey,
    'Accept': 'image/svg+xml',
  };
  
  /// Vérifier si un exercice a une image disponible
  /// True pour tous les exercices (assets, local ou API)
  bool hasImage(String exerciseId) => true;

  /// Obtenir un exercice par ID
  Future<ExerciseLibrary?> getById(String id) async {
    try {
      final doc = await _exercisesCollection.doc(id).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      return ExerciseLibrary.fromFirestore(data);
    } catch (e) {
      return null;
    }
  }

  /// Obtenir statistiques du catalogue
  Future<Map<String, dynamic>> getStats() async {
    final exercises = await getAll();
    final downloaderStats = await _downloader.getStats();

    // Compter exercices par muscle primaire
    final muscleGroups = <String, int>{};
    for (final exercise in exercises) {
      for (final muscle in exercise.primaryMuscles) {
        muscleGroups[muscle.name] = (muscleGroups[muscle.name] ?? 0) + 1;
      }
    }

    return {
      'total': exercises.length,
      'preseeded_images': _manifest.count,
      'downloaded_images': downloaderStats['downloaded_count'],
      'storage_size': downloaderStats['total_size_kb'],
      'remote_images': exercises.length - _manifest.count - (downloaderStats['downloaded_count'] as int),
      ...muscleGroups,
    };
  }
}
