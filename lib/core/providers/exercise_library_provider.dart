import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise_library.dart';
import '../services/exercise_library_repository.dart';
import '../utils/string_normalization.dart';

/// Provider pour gérer l'état du catalogue d'exercices
///
/// Responsabilités:
/// - Charger et maintenir la liste d'exercices
/// - Gérer les filtres (recherche, muscle, catégorie, type)
/// - Persister les filtres actifs (shared_preferences) entre les sessions
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
  //
  // Pourquoi des listes uniquement (pas de champ mono-code en plus) : avoir
  // deux sources de vérité (un code unique ET une liste) pour le même filtre
  // est une source classique de bugs de désynchronisation (ex: hasActiveFilters
  // qui oublie l'une des deux). Les listes sont la source unique de vérité ;
  // les méthodes historiques mono-valeur (filterByMuscle, filterByType) restent
  // exposées comme des raccourcis pratiques qui délèguent vers les listes.
  String _searchQuery = '';
  List<String> _selectedMuscleCodes = [];
  List<String> _selectedCategoryCodes = [];
  List<String> _selectedTypeCodes = [];

  // Indique si la restauration depuis shared_preferences a déjà été tentée,
  // pour ne la faire qu'une seule fois (au premier chargement) et ne pas
  // écraser les filtres en mémoire lors d'un simple pull-to-refresh.
  bool _filtersRestored = false;

  // Cache des noms de muscles, catégories et types
  final Map<String, String> _muscleNames = {};
  final Map<String, String> _categoryNames = {};
  final Map<String, String> _typeNames = {};

  // Clés de persistance shared_preferences, préfixées pour éviter toute
  // collision avec d'autres features utilisant shared_preferences (ex:
  // ThemeProvider utilise déjà la clé 'app_theme_mode').
  static const String _prefsKeySearch = 'exercise_library_filters_v1_search';
  static const String _prefsKeyMuscles = 'exercise_library_filters_v1_muscles';
  static const String _prefsKeyCategories =
      'exercise_library_filters_v1_categories';
  static const String _prefsKeyTypes = 'exercise_library_filters_v1_types';

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

  /// Codes des muscles sélectionnés (primaires et/ou secondaires)
  List<String> get selectedMuscleCodes => _selectedMuscleCodes;

  /// Codes des catégories d'équipement sélectionnées (multi-sélection)
  List<String> get selectedCategoryCodes => _selectedCategoryCodes;

  /// Codes des types d'exercice sélectionnés (multi-sélection)
  List<String> get selectedTypeCodes => _selectedTypeCodes;

  /// Nombre total d'exercices
  int get totalCount => _allExercises.length;

  /// Nombre d'exercices filtrés
  int get filteredCount => _filteredExercises.length;

  /// Indique si des filtres sont actifs
  ///
  /// Source unique de vérité : dérivée uniquement des listes de codes actives
  /// (plus de champ mono-code legacy à maintenir en parallèle).
  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedMuscleCodes.isNotEmpty ||
      _selectedCategoryCodes.isNotEmpty ||
      _selectedTypeCodes.isNotEmpty;

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
      // Restaurer les filtres persistés une seule fois, au tout premier
      // chargement, pour reprendre l'état de recherche/filtres de la
      // session précédente (l'utilisateur retrouve son contexte).
      if (!_filtersRestored) {
        await _restoreFilters();
        _filtersRestored = true;
      }

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
  /// Cherche dans le nom, la description, le code technique, et les noms de
  /// muscles primaires. Insensible à la casse et aux accents.
  Future<void> search(String query) async {
    _searchQuery = query.trim();
    _applyFilters();
    await _persistFilters();
  }

  /// Filtrer par muscle primaire (code unique)
  /// Raccourci pratique qui délègue vers la liste (filterByMuscleGroup).
  Future<void> filterByMuscle(String? muscleCode) async {
    _selectedMuscleCodes = muscleCode != null ? [muscleCode] : [];
    _applyFilters();
    await _persistFilters();
  }

  /// Filtrer par groupe musculaire (liste de codes, muscles primaires ET secondaires)
  Future<void> filterByMuscleGroup(List<String> muscleCodes) async {
    _selectedMuscleCodes = List.of(muscleCodes);
    _applyFilters();
    await _persistFilters();
  }

  /// Filtrer par catégorie d'équipement (code unique)
  /// Paramètre: categoryCode (ex: 'FREE_WEIGHT', 'MACHINE', null pour tous)
  /// Raccourci pratique qui délègue vers la liste (filterByCategoryGroup).
  Future<void> filterByCategory(String? categoryCode) async {
    _selectedCategoryCodes = categoryCode != null ? [categoryCode] : [];
    _applyFilters();
    await _persistFilters();
  }

  /// Filtrer par catégories d'équipement en multi-sélection
  /// Paramètre: categoryCodes (ex: ['FREE_WEIGHT', 'MACHINE'], [] pour tous)
  Future<void> filterByCategoryGroup(List<String> categoryCodes) async {
    _selectedCategoryCodes = List.of(categoryCodes);
    _applyFilters();
    await _persistFilters();
  }

  /// Filtrer par type d'exercice (code unique)
  /// Paramètre: typeCode (ex: 'ISOLATION', 'COMPOUND', null pour tous)
  /// Raccourci pratique qui délègue vers la liste (filterByTypeGroup).
  Future<void> filterByType(String? typeCode) async {
    _selectedTypeCodes = typeCode != null ? [typeCode] : [];
    _applyFilters();
    await _persistFilters();
  }

  /// Filtrer par types d'exercice en multi-sélection
  /// Paramètre: typeCodes (ex: ['ISOLATION', 'COMPOUND'], [] pour tous)
  Future<void> filterByTypeGroup(List<String> typeCodes) async {
    _selectedTypeCodes = List.of(typeCodes);
    _applyFilters();
    await _persistFilters();
  }

  /// Réinitialiser tous les filtres
  /// Purge à la fois l'état en mémoire ET la persistance shared_preferences,
  /// pour qu'un reset soit un reset complet (pas de filtre "fantôme" qui
  /// reviendrait au prochain démarrage de l'app).
  Future<void> clearFilters() async {
    _searchQuery = '';
    _selectedMuscleCodes = [];
    _selectedCategoryCodes = [];
    _selectedTypeCodes = [];
    _applyFilters();
    await _purgePersistedFilters();
  }

  /// Appliquer tous les filtres actifs
  /// Performance: O(n) avec n = nombre d'exercices
  void _applyFilters() {
    _filteredExercises = _allExercises;

    // Filtre recherche (nom, description, code, + muscles primaires)
    if (_searchQuery.isNotEmpty) {
      final normalizedQuery = normalizeString(_searchQuery);
      _filteredExercises = _filteredExercises.where((ex) {
        final matchesText =
            normalizeString(ex.name).contains(normalizedQuery) ||
                normalizeString(ex.description).contains(normalizedQuery) ||
                normalizeString(ex.code).contains(normalizedQuery);
        if (matchesText) return true;

        // Étendre la recherche aux noms de muscles primaires : un utilisateur
        // qui tape "pectoraux" doit retrouver tous les exercices ciblant ce
        // muscle, même si le mot n'apparaît ni dans le nom ni la description.
        // Volontairement limité aux muscles primaires (pas secondaires) pour
        // rester pertinent : un exercice a souvent de nombreux muscles
        // secondaires accessoires qui ne le définissent pas.
        return ex.primaryMuscles
            .any((m) => normalizeString(m.name).contains(normalizedQuery));
      }).toList();
    }

    // Filtre muscle (multi-codes : muscles primaires ET secondaires)
    if (_selectedMuscleCodes.isNotEmpty) {
      _filteredExercises = _filteredExercises.where((ex) {
        return ex.primaryMuscles.any((m) => _selectedMuscleCodes.contains(m.code)) ||
               ex.secondaryMuscles.any((m) => _selectedMuscleCodes.contains(m.code));
      }).toList();
    }

    // Filtre catégorie (multi-sélection : union des catégories choisies)
    if (_selectedCategoryCodes.isNotEmpty) {
      _filteredExercises = _filteredExercises.where((ex) {
        return ex.categories.any((c) => _selectedCategoryCodes.contains(c.code));
      }).toList();
    }

    // Filtre type (multi-sélection : union des types choisis)
    if (_selectedTypeCodes.isNotEmpty) {
      _filteredExercises = _filteredExercises.where((ex) {
        return ex.types.any((t) => _selectedTypeCodes.contains(t.code));
      }).toList();
    }

    notifyListeners();
  }

  // ==========================================
  // PERSISTANCE (shared_preferences)
  // ==========================================

  /// Restaurer les filtres depuis shared_preferences
  /// Appelé une seule fois, au premier loadExercises().
  Future<void> _restoreFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _searchQuery = prefs.getString(_prefsKeySearch) ?? '';
      _selectedMuscleCodes = prefs.getStringList(_prefsKeyMuscles) ?? [];
      _selectedCategoryCodes = prefs.getStringList(_prefsKeyCategories) ?? [];
      _selectedTypeCodes = prefs.getStringList(_prefsKeyTypes) ?? [];
    } catch (_) {
      // La persistance est une amélioration de confort (UX) : si elle échoue
      // (environnement sans plugin disponible, etc.), on dégrade silencieusement
      // vers l'absence de filtre plutôt que de faire planter le chargement.
    }
  }

  /// Sauvegarder les filtres actifs dans shared_preferences
  /// Appelé après chaque changement de filtre.
  Future<void> _persistFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKeySearch, _searchQuery);
      await prefs.setStringList(_prefsKeyMuscles, _selectedMuscleCodes);
      await prefs.setStringList(_prefsKeyCategories, _selectedCategoryCodes);
      await prefs.setStringList(_prefsKeyTypes, _selectedTypeCodes);
    } catch (_) {
      // Idem : le filtrage en mémoire reste la source de vérité immédiate,
      // un échec de sauvegarde ne doit pas remonter comme une erreur utilisateur.
    }
  }

  /// Purger les filtres persistés (utilisé par clearFilters)
  Future<void> _purgePersistedFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKeySearch);
      await prefs.remove(_prefsKeyMuscles);
      await prefs.remove(_prefsKeyCategories);
      await prefs.remove(_prefsKeyTypes);
    } catch (_) {
      // Voir commentaires ci-dessus : dégradation silencieuse.
    }
  }

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

  /// Obtenir la liste des types d'exercice disponibles
  /// Utile pour construire les filtres
  List<String> getAvailableTypes() {
    _typeNames.clear(); // Réinitialiser le cache

    for (final exercise in _allExercises) {
      for (final type in exercise.types) {
        _typeNames[type.code] = type.name;
      }
    }

    return _typeNames.keys.toList()..sort();
  }

  /// Obtenir le nom d'un muscle par son code
  String? getMuscleName(String code) {
    return _muscleNames[code];
  }

  /// Obtenir le nom d'une catégorie par son code
  String? getCategoryName(String code) {
    return _categoryNames[code];
  }

  /// Obtenir le nom d'un type par son code
  String? getTypeName(String code) {
    return _typeNames[code];
  }
}
