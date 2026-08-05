import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/exercise_library.dart';
import '../../core/providers/exercise_library_provider.dart';
import 'widgets/exercise_image_widget.dart';
import '../../core/widgets/widgets.dart';
import '../../core/utils/page_transitions.dart';
import '../workout/workout_session_screen.dart';

/// Écran de sélection d'exercice avec catalogue Workout API
///
/// Features:
/// - Barre de recherche en temps réel
/// - TabBar par groupe musculaire (design original)
/// - FilterChips par catégorie d'équipement et par type, en multi-sélection
/// - Compteur de résultats + réinitialisation des filtres en un clic
/// - Liste optimisée avec ListView.builder
/// - Pull-to-refresh
/// - Performance < 1s (CS-002)
///
/// Architecture:
/// - Utilise ExerciseLibraryProvider pour state management. Les filtres
///   catégorie et type sont lus/écrits directement sur le provider (source
///   unique de vérité) ; seuls la recherche et le groupe musculaire gardent
///   un miroir d'état local, nécessaire pour piloter le TextEditingController
///   et le TabController.
/// - Lazy loading des images via ExerciseLibraryRepository
/// - Cache en mémoire pour performance
class ExerciseLibrarySelectionScreen extends StatefulWidget {
  const ExerciseLibrarySelectionScreen({super.key});

  @override
  State<ExerciseLibrarySelectionScreen> createState() =>
      _ExerciseLibrarySelectionScreenState();
}

class _ExerciseLibrarySelectionScreenState
    extends State<ExerciseLibrarySelectionScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late TabController _tabController;

  // Liste des groupes musculaires pour les tabs
  final List<String> _muscleGroups = [
    'Tous',
    'Pectoraux',
    'Dorsaux',
    'Jambes',
    'Épaules',
    'Bras',
    'Abdominaux',
  ];

  // Mapping tab musculaire → liste de codes muscles (primaires ET secondaires)
  final Map<String, List<String>> _muscleGroupToCodes = {
    'Pectoraux': ['CHEST'],
    'Dorsaux': ['BACK', 'LATS', 'RHOMBOIDS', 'TRAPEZIUS'],
    'Jambes': ['LEGS', 'QUADRICEPS', 'HAMSTRINGS', 'GLUTES', 'CALVES'],
    'Épaules': ['SHOULDERS', 'DELTOIDS', 'TRAPEZIUS'],
    'Bras': ['BICEPS', 'TRICEPS', 'FOREARMS'],
    'Abdominaux': ['ABS', 'OBLIQUES', 'CORE'],
  };

  // Miroir local du tab musculaire sélectionné (le TabController pilote la
  // TabBar, ce champ pilote le mapping vers les codes muscles du provider).
  String? _selectedMuscleGroup;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _muscleGroups.length, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Charger les exercices au démarrage, puis synchroniser l'état visuel
    // local (recherche, onglet muscle) sur les filtres persistés restaurés
    // par le provider, pour que l'utilisateur retrouve l'affichage exact de
    // sa session précédente (les FilterChips catégorie/type sont lus
    // directement depuis le provider : pas de synchronisation locale requise
    // pour ceux-là).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndRestoreFilters();
    });
  }

  Future<void> _initializeAndRestoreFilters() async {
    final provider = context.read<ExerciseLibraryProvider>();
    if (provider.exercises.isEmpty) {
      await provider.loadExercises();
    }
    if (!mounted) return;
    _restoreLocalFilterState(provider);
  }

  /// Synchronise le champ de recherche et l'onglet muscle sur l'état restauré
  /// du provider (recherche/muscle persistés depuis la session précédente).
  void _restoreLocalFilterState(ExerciseLibraryProvider provider) {
    _searchController.text = provider.searchQuery;

    final restoredMuscleCodes = provider.selectedMuscleCodes;
    String? restoredGroup;
    if (restoredMuscleCodes.isNotEmpty) {
      for (final entry in _muscleGroupToCodes.entries) {
        if (_sameCodes(entry.value, restoredMuscleCodes)) {
          restoredGroup = entry.key;
          break;
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _selectedMuscleGroup = restoredGroup;
    });

    final tabIndex = restoredGroup == null ? 0 : _muscleGroups.indexOf(restoredGroup);
    if (tabIndex >= 0 && tabIndex != _tabController.index) {
      // Retirer temporairement le listener pour ne pas réappliquer un filtre
      // déjà à jour côté provider (la restauration a déjà été faite par
      // loadExercises -> _restoreFilters cote provider).
      _tabController.removeListener(_onTabChanged);
      _tabController.index = tabIndex;
      _tabController.addListener(_onTabChanged);
    }
  }

  /// Compare deux listes de codes indépendamment de l'ordre.
  bool _sameCodes(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    return a.toSet().containsAll(b) && b.toSet().containsAll(a);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final selectedTab = _muscleGroups[_tabController.index];
      final provider = context.read<ExerciseLibraryProvider>();
      setState(() {
        _selectedMuscleGroup = selectedTab == 'Tous' ? null : selectedTab;
      });
      if (_selectedMuscleGroup != null) {
        final codes = _muscleGroupToCodes[_selectedMuscleGroup] ?? [];
        provider.filterByMuscleGroup(codes);
      } else {
        provider.filterByMuscle(null);
      }
    }
  }

  void _onSearchChanged(String query) {
    context.read<ExerciseLibraryProvider>().search(query);
  }

  /// Bascule une catégorie dans la sélection multiple portée par le provider
  /// (le provider est l'unique source de vérité, pas de miroir local).
  void _onCategoryToggled(ExerciseLibraryProvider provider, String categoryCode) {
    final updated = List<String>.of(provider.selectedCategoryCodes);
    if (updated.contains(categoryCode)) {
      updated.remove(categoryCode);
    } else {
      updated.add(categoryCode);
    }
    provider.filterByCategoryGroup(updated);
  }

  /// Bascule un type dans la sélection multiple portée par le provider.
  void _onTypeToggled(ExerciseLibraryProvider provider, String typeCode) {
    final updated = List<String>.of(provider.selectedTypeCodes);
    if (updated.contains(typeCode)) {
      updated.remove(typeCode);
    } else {
      updated.add(typeCode);
    }
    provider.filterByTypeGroup(updated);
  }

  /// Réinitialise tous les filtres : provider (recherche/muscle/catégorie/
  /// type) ET miroirs locaux (champ de recherche, onglet muscle), pour que
  /// l'UI reste cohérente avec l'état du provider après le reset.
  void _onResetFilters() {
    _searchController.clear();
    setState(() {
      _selectedMuscleGroup = null;
    });
    if (_tabController.index != 0) {
      _tabController.removeListener(_onTabChanged);
      _tabController.index = 0;
      _tabController.addListener(_onTabChanged);
    }
    context.read<ExerciseLibraryProvider>().clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        // title: const Text('Sélection d\'exercice'),
        backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
        elevation: 0,
      ),
      body: AppBackground(
        child: Column(
          children: [
            // Barre de recherche
            Padding(
              padding: const EdgeInsets.all(16),
              child: AppTextField(
                controller: _searchController,
                hintText: 'Rechercher un exercice...',
                prefixIcon: const Icon(Icons.search),
                onChanged: _onSearchChanged,
              ),
            ),

            // Tabs par groupe musculaire
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
              indicatorColor: colorScheme.primary,
              tabs: _muscleGroups.map((group) => Tab(text: group)).toList(),
            ),

            // Sous-tabs par catégorie (FilterChips, multi-sélection)
            _buildCategoryFilters(colorScheme),

            // Sous-tabs par type d'exercice (FilterChips, multi-sélection)
            // Limité aux types réellement présents dans les données chargées.
            _buildTypeFilters(colorScheme),

            // Compteur de résultats + bouton de réinitialisation conditionnel
            _buildResultsHeader(colorScheme),

            // Liste des exercices
            Expanded(
              child: _buildExerciseList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Filtres de catégories (sous-tabs avec FilterChips), en multi-sélection.
  /// Lit et écrit directement sur le provider : pas d'état local dupliqué.
  Widget _buildCategoryFilters(ColorScheme colorScheme) {
    return Consumer<ExerciseLibraryProvider>(
      builder: (context, provider, _) {
        final categoryCodes = provider.getAvailableCategories();
        if (categoryCodes.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: categoryCodes.length + 1, // +1 pour "Tous"
            itemBuilder: (context, index) {
              if (index == 0) {
                // Chip "Tous" : vide la sélection multiple.
                final isSelected = provider.selectedCategoryCodes.isEmpty;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Tous'),
                    selected: isSelected,
                    onSelected: (_) => provider.filterByCategoryGroup(const []),
                    backgroundColor: colorScheme.surface,
                    selectedColor: colorScheme.primary.withValues(alpha: 0.2),
                    checkmarkColor: colorScheme.primary,
                  ),
                );
              }

              final code = categoryCodes[index - 1];
              final name = provider.getCategoryName(code) ?? code;
              final isSelected = provider.selectedCategoryCodes.contains(code);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(name),
                  selected: isSelected,
                  onSelected: (_) => _onCategoryToggled(provider, code),
                  backgroundColor: colorScheme.surface,
                  selectedColor: colorScheme.primary.withValues(alpha: 0.2),
                  checkmarkColor: colorScheme.primary,
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Filtres de type d'exercice (FilterChips, multi-sélection), affichés
  /// uniquement si le catalogue chargé contient au moins un type (évite une
  /// rangée vide inutile avant chargement ou si les données n'en portent pas).
  Widget _buildTypeFilters(ColorScheme colorScheme) {
    return Consumer<ExerciseLibraryProvider>(
      builder: (context, provider, _) {
        final typeCodes = provider.getAvailableTypes();
        if (typeCodes.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: typeCodes.length + 1, // +1 pour "Tous types"
            itemBuilder: (context, index) {
              if (index == 0) {
                final isSelected = provider.selectedTypeCodes.isEmpty;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Tous types'),
                    selected: isSelected,
                    onSelected: (_) => provider.filterByTypeGroup(const []),
                    backgroundColor: colorScheme.surface,
                    selectedColor: colorScheme.primary.withValues(alpha: 0.2),
                    checkmarkColor: colorScheme.primary,
                  ),
                );
              }

              final code = typeCodes[index - 1];
              final name = provider.getTypeName(code) ?? code;
              final isSelected = provider.selectedTypeCodes.contains(code);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(name),
                  selected: isSelected,
                  onSelected: (_) => _onTypeToggled(provider, code),
                  backgroundColor: colorScheme.surface,
                  selectedColor: colorScheme.primary.withValues(alpha: 0.2),
                  checkmarkColor: colorScheme.primary,
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Bandeau résumé : nombre de résultats affiché sous la forme fixe
  /// 'N exercices' (pas de variante singulière : simplicité, format imposé),
  /// et bouton de réinitialisation visible uniquement si un filtre est actif.
  Widget _buildResultsHeader(ColorScheme colorScheme) {
    return Consumer<ExerciseLibraryProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Row(
            children: [
              Text(
                '${provider.filteredCount} exercices',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
              ),
              const Spacer(),
              if (provider.hasActiveFilters)
                TextButton.icon(
                  onPressed: _onResetFilters,
                  icon: const Icon(Icons.filter_alt_off, size: 18),
                  label: const Text('Réinitialiser'),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Liste des exercices
  Widget _buildExerciseList() {
    return Consumer<ExerciseLibraryProvider>(
      builder: (context, provider, _) {
        final colorScheme = Theme.of(context).colorScheme;

        // État de chargement
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // État d'erreur
        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erreur de chargement',
                  style: TextStyle(
                    fontSize: 18,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => provider.loadExercises(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        // Liste vide : distinguer catalogue réellement vide (pas de filtre
        // actif) de "aucun résultat pour ces filtres" (avec action de reset).
        if (provider.exercises.isEmpty) {
          final hasFilters = provider.hasActiveFilters;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 64,
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  hasFilters ? 'Aucun exercice ne correspond' : 'Aucun exercice trouvé',
                  style: TextStyle(
                    fontSize: 18,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hasFilters
                      ? 'Essayez de modifier ou de réinitialiser vos filtres'
                      : 'Le catalogue est vide pour le moment',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if (hasFilters) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _onResetFilters,
                    icon: const Icon(Icons.filter_alt_off),
                    label: const Text('Réinitialiser les filtres'),
                  ),
                ],
              ],
            ),
          );
        }

        // Liste des exercices avec RefreshIndicator
        return RefreshIndicator(
          onRefresh: () => provider.refresh(),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: provider.exercises.length,
            itemBuilder: (context, index) {
              final exercise = provider.exercises[index];
              return _buildExerciseCard(context, exercise, colorScheme);
            },
          ),
        );
      },
    );
  }

  /// Card d'exercice avec le style original
  Widget _buildExerciseCard(
    BuildContext context,
    ExerciseLibrary exercise,
    ColorScheme colorScheme,
  ) {
    // Obtenir emoji basé sur les muscles primaires (fallback)
    final emoji = _getEmojiForExercise(exercise);

    // Clé stable pour éviter que Flutter recycle les widgets par position lors
    // de changements de filtre/onglet : sans cette clé, l'absence d'appairage
    // stable provoque la réutilisation erronée du State des vignettes d'image
    // (didChangeDependencies() ne relance pas _loadImageSource() si l'id change).
    return Padding(
      key: ValueKey(exercise.id),
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        variant: AppCardVariant.elevated,
        padding: const EdgeInsets.all(16),
        onTap: () => _onExerciseSelected(exercise),
        child: Row(
          children: [
            // Image avec fallback emoji (affiche image si disponible localement)
            ExerciseImageThumbnail(
              exerciseId: exercise.id,
              fallbackEmoji: emoji,
              size: 56,
            ),
            const SizedBox(width: 16),

            // Informations exercice
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom
                  Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),

                  // Muscles primaires
                  Text(
                    exercise.primaryMusclesText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                  ),

                  // Catégorie
                  if (exercise.categories.isNotEmpty)
                    Text(
                      exercise.categories.first.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary.withValues(alpha: 0.8),
                          ),
                    ),
                ],
              ),
            ),

            // Icône chevron
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  /// Obtenir emoji pour un exercice basé sur les muscles primaires
  String _getEmojiForExercise(ExerciseLibrary exercise) {
    if (exercise.primaryMuscles.isEmpty) return '💪';

    final muscleName = exercise.primaryMuscles.first.name.toLowerCase();

    if (muscleName.contains('pectora') || muscleName.contains('chest')) return '💪';
    if (muscleName.contains('dorsa') || muscleName.contains('back')) return '🦾';
    if (muscleName.contains('jambe') || muscleName.contains('leg') ||
        muscleName.contains('quadri') || muscleName.contains('fessier') ||
        muscleName.contains('mollet')) {
      return '🦵';
    }
    if (muscleName.contains('épaule') || muscleName.contains('shoulder') ||
        muscleName.contains('trapèze')) {
      return '💪';
    }
    if (muscleName.contains('bras') || muscleName.contains('bicep') ||
        muscleName.contains('tricep')) {
      return '💪';
    }
    if (muscleName.contains('abdomi') || muscleName.contains('abs') ||
        muscleName.contains('oblique')) {
      return '🏋️';
    }

    return '💪';
  }

  /// Callback quand un exercice est sélectionné
  /// Navigue vers WorkoutSessionScreen pour enregistrer les séries
  void _onExerciseSelected(ExerciseLibrary exerciseLibrary) {
    Navigator.of(context).push(
      AppPageRoute.slideRight(
        builder: (context) => WorkoutSessionScreen(exercise: exerciseLibrary),
      ),
    );
  }
}
