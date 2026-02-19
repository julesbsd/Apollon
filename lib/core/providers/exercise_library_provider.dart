import 'package:flutter/foundation.dart';
import '../models/exercise_library.dart';
import '../services/exercise_library_repository.dart';

/// Provider pour gérer l'état du catalogue d'exercices
/// 
/// Responsabilités:
/// - Charger et maintenir la liste d'exercices
/// - Gérer les filtres (recherche, muscle, catégorie)
/// - Optimiser les performances avec cache
/// - Gérer les états de chargement et d'erreur
class ExerciseLibraryProvider extends ChangeNotifier {
  final ExerciseLibraryRepository _repository;

  // État des données
  List<ExerciseLibrary> _allExercises = [];
  List<ExerciseLibrary> _filteredExercises = [];
  bool _isLoading = false;
  String? _error;

  // Filtres actifs
  String _searchQuery = '';
  String? _selectedMuscleCode;
  String? _selectedCategoryCode;
  String? _selectedTypeCode;

  // Cache des noms de muscles et catégories
  final Map<String, String> _muscleNames = {};
  final Map<String, String> _categoryNames = {};

  ExerciseLibraryProvider(this._repository);

  // ==========================================
  // GETTERS
  // ==========================================

  /// Liste des exercices filtrés à afficher
  List<ExerciseLibrary> get exercises => _filteredExercises;

  /// Liste complète des exercices (non filtrée)
  List<ExerciseLibrary> get allExercises => _allExercises;

  /// Indique si le chargement est en cours
  bool get isLoading => _isLoading;

  /// Message d'erreur si applicable
  String? get error => _error;

  /// Requête de recherche active
  String get searchQuery => _searchQuery;

  /// Code du muscle sélectionné
  String? get selectedMuscleCode => _selectedMuscleCode;

  /// Code de la catégorie sélectionnée
  String? get selectedCategoryCode => _selectedCategoryCode;

  /// Code du type sélectionné
  String? get selectedTypeCode => _selectedTypeCode;

  /// Nombre total d'exercices
  int get totalCount => _allExercises.length;

  /// Nombre d'exercices filtrés
  int get filteredCount => _filteredExercises.length;

  /// Indique si des filtres sont actifs
  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedMuscleCodes.isNotEmpty ||
      _selectedMuscleCode != null ||
      _selectedCategoryCode != null ||
      _selectedTypeCode != null;

  // ==========================================
  // CHARGEMENT DONNÉES
  // ==========================================

  /// Charger tous les exercices depuis Firestore
  /// À appeler au démarrage de l'écran
  Future<void> loadExercises() async {
    if (_isLoading) return; // Éviter les chargements multiples

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allExercises = await _repository.getAll();
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = 'Erreur lors du chargement des exercices: $e';
      _allExercises = [];
      _filteredExercises = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rafraîchir les exercices (force reload)
  Future<void> refresh() async {
    _repository.invalidateCache();
    await loadExercises();
  }

  // ==========================================
  // FILTRES
  // ==========================================

  /// Rechercher par texte
  /// Cherche dans le nom et la description
  void search(String query) {
    _searchQuery = query.trim();
    _applyFilters();
  }

  /// Filtrer par muscle primaire
  // Codes de muscles actifs pour le filtre par groupe
  List<String> _selectedMuscleCodes = [];

  /// Filtrer par muscle primaire (code unique)
  void filterByMuscle(String? muscleCode) {
    _selectedMuscleCode = muscleCode;
    _selectedMuscleCodes = muscleCode != null ? [muscleCode] : [];
    _applyFilters();
  }

  /// Filtrer par groupe musculaire (liste de codes, muscles primaires ET secondaires)
  void filterByMuscleGroup(List<String> muscleCodes) {
    _selectedMuscleCode = muscleCodes.isNotEmpty ? muscleCodes.first : null;
    _selectedMuscleCodes = muscleCodes;
    _applyFilters();
  }

  /// Filtrer par catégorie d'équipement
  /// Paramètre: categoryCode (ex: 'FREE_WEIGHT', 'MACHINE', null pour tous)
  void filterByCategory(String? categoryCode) {
    _selectedCategoryCode = categoryCode;
    _applyFilters();
  }

  /// Filtrer par type d'exercice
  /// Paramètre: typeCode (ex: 'ISOLATION', 'COMPOUND', null pour tous)
  void filterByType(String? typeCode) {
    _selectedTypeCode = typeCode;
    _applyFilters();
  }

  /// Réinitialiser tous les filtres
  void clearFilters() {
    _searchQuery = '';
    _selectedMuscleCode = null;
    _selectedMuscleCodes = [];
    _selectedCategoryCode = null;
    _selectedTypeCode = null;
    _applyFilters();
  }

  /// Appliquer tous les filtres actifs
  /// Performance: O(n) avec n = nombre d'exercices
  void _applyFilters() {
    _filteredExercises = _allExercises;

    // Filtre recherche
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      _filteredExercises = _filteredExercises.where((ex) {
        return ex.name.toLowerCase().contains(lowerQuery) ||
            ex.description.toLowerCase().contains(lowerQuery) ||
            ex.code.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    // Filtre muscle (multi-codes : muscles primaires ET secondaires)
    if (_selectedMuscleCodes.isNotEmpty) {
      _filteredExercises = _filteredExercises.where((ex) {
        return ex.primaryMuscles.any((m) => _selectedMuscleCodes.contains(m.code)) ||
               ex.secondaryMuscles.any((m) => _selectedMuscleCodes.contains(m.code));
      }).toList();
    }

    // Filtre catégorie
    if (_selectedCategoryCode != null) {
      _filteredExercises = _filteredExercises.where((ex) {
        return ex.categories.any((c) => c.code == _selectedCategoryCode);
      }).toList();
    }

    // Filtre type
    if (_selectedTypeCode != null) {
      _filteredExercises = _filteredExercises.where((ex) {
        return ex.types.any((t) => t.code == _selectedTypeCode);
      }).toList();
    }

    notifyListeners();
  }

  // ==========================================
  // IMAGES
  // ==========================================

  // ==========================================
  // STATISTIQUES
  // ==========================================

  /// Obtenir les statistiques du catalogue
  Future<Map<String, dynamic>> getStats() async {
    return await _repository.getStats();
  }

  /// Obtenir la liste des muscles primaires disponibles
  /// Utile pour construire les filtres
  List<String> getAvailableMuscles() {
    _muscleNames.clear(); // Réinitialiser le cache

    for (final exercise in _allExercises) {
      for (final muscle in exercise.primaryMuscles) {
        _muscleNames[muscle.code] = muscle.name;
      }
    }

    return _muscleNames.keys.toList()..sort();
  }

  /// Obtenir la liste des catégories disponibles
  /// Utile pour construire les filtres
  List<String> getAvailableCategories() {
    _categoryNames.clear(); // Réinitialiser le cache

    for (final exercise in _allExercises) {
      for (final category in exercise.categories) {
        _categoryNames[category.code] = category.name;
      }
    }

    return _categoryNames.keys.toList()..sort();
  }

  /// Obtenir le nom d'un muscle par son code
  String? getMuscleName(String code) {
    return _muscleNames[code];
  }

  /// Obtenir le nom d'une catégorie par son code
  String? getCategoryName(String code) {
    return _categoryNames[code];
  }
}
