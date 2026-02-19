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
/// - FilterChips par catégorie d'équipement (sous-tabs)
/// - Liste optimisée avec ListView.builder
/// - Pull-to-refresh
/// - Performance < 1s (CS-002)
/// 
/// Architecture:
/// - Utilise ExerciseLibraryProvider pour state management
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

  String? _selectedMuscleGroup;
  String? _selectedCategory; // Stocke le code de catégorie (ex: 'BARBELL')

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _muscleGroups.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    
    // Charger les exercices au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ExerciseLibraryProvider>();
      if (provider.exercises.isEmpty) {
        provider.loadExercises();
      }
    });
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
      setState(() {
        _selectedMuscleGroup = selectedTab == 'Tous' ? null : selectedTab;
      });
      _applyFilters();
    }
  }

  void _onCategorySelected(String categoryCode, String categoryName) {
    setState(() {
      if (_selectedCategory == categoryCode || categoryCode.isEmpty) {
        _selectedCategory = null;
      } else {
        _selectedCategory = categoryCode;
      }
    });
    _applyFilters();
  }

  void _onSearchChanged(String query) {
    _applyFilters();
  }

  void _applyFilters() {
    final provider = context.read<ExerciseLibraryProvider>();

    // Appliquer recherche
    provider.search(_searchController.text);

    // Appliquer filtre muscle : passer tous les codes du groupe sélectionné
    if (_selectedMuscleGroup != null && _selectedMuscleGroup != 'Tous') {
      final codes = _muscleGroupToCodes[_selectedMuscleGroup] ?? [];
      provider.filterByMuscleGroup(codes);
    } else {
      provider.filterByMuscle(null);
    }

    // Appliquer filtre catégorie : passer le code réel
    provider.filterByCategory(_selectedCategory);
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

            // Sous-tabs par catégorie (FilterChips)
            _buildCategoryFilters(colorScheme),

            // Liste des exercices
            Expanded(
              child: _buildExerciseList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Filtres de catégories (sous-tabs avec FilterChips)
  Widget _buildCategoryFilters(ColorScheme colorScheme) {
    return Consumer<ExerciseLibraryProvider>(
      builder: (context, provider, _) {
        final categoryCodes = provider.getAvailableCategories();

        return SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: categoryCodes.length + 1, // +1 pour "Tous"
            itemBuilder: (context, index) {
              if (index == 0) {
                // Chip "Tous"
                final isSelected = _selectedCategory == null;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Tous'),
                    selected: isSelected,
                    onSelected: (_) => _onCategorySelected('', 'Tous'),
                    backgroundColor: colorScheme.surface,
                    selectedColor: colorScheme.primary.withValues(alpha: 0.2),
                    checkmarkColor: colorScheme.primary,
                  ),
                );
              }

              final code = categoryCodes[index - 1];
              final name = provider.getCategoryName(code) ?? code;
              final isSelected = _selectedCategory == code;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(name),
                  selected: isSelected,
                  onSelected: (_) => _onCategorySelected(code, name),
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

        // Liste vide
        if (provider.exercises.isEmpty) {
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
                  'Aucun exercice trouvé',
                  style: TextStyle(
                    fontSize: 18,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Essayez de modifier vos filtres',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
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
    
    return Padding(
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
        muscleName.contains('mollet')) return '🦵';
    if (muscleName.contains('épaule') || muscleName.contains('shoulder') ||
        muscleName.contains('trapèze')) return '💪';
    if (muscleName.contains('bras') || muscleName.contains('bicep') ||
        muscleName.contains('tricep')) return '💪';
    if (muscleName.contains('abdomi') || muscleName.contains('abs') ||
        muscleName.contains('oblique')) return '🏋️';
    
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


// /// Écran de sélection d'exercice avec catalogue Workout API
// /// 
// /// Features:
// /// - Barre de recherche en temps réel
// /// - TabBar par groupe musculaire (design original)
// /// - FilterChips par catégorie d'équipement (sous-tabs)
// /// - Liste optimisée avec ListView.builder
// /// - Pull-to-refresh
// /// - Performance < 1s (CS-002)
// /// 
// /// Architecture:
// /// - Utilise ExerciseLibraryProvider pour state management
// /// - Lazy loading des images via ExerciseLibraryRepository
// /// - Cache en mémoire pour performance
// class ExerciseLibrarySelectionScreen extends StatefulWidget {
//   const ExerciseLibrarySelectionScreen({super.key});

//   @override
//   State<ExerciseLibrarySelectionScreen> createState() =>
//       _ExerciseLibrarySelectionScreenState();
// }

// class _ExerciseLibrarySelectionScreenState
//     extends State<ExerciseLibrarySelectionScreen>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController _searchController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
  
//   late TabController _tabController;

//   // Liste des groupes musculaires pour les tabs
//   final List<String> _muscleGroups = [
//     'Tous',
//     'Pectoraux',
//     'Dorsaux',
//     'Jambes',
//     'Épaules',
//     'Bras',
//     'Abdominaux',
//   ];

//   // Mapping tab musculaire → liste de codes muscles (primaires ET secondaires)
//   final Map<String, List<String>> _muscleGroupToCodes = {
//     'Pectoraux': ['CHEST'],
//     'Dorsaux': ['BACK', 'LATS', 'RHOMBOIDS', 'TRAPEZIUS'],
//     'Jambes': ['LEGS', 'QUADRICEPS', 'HAMSTRINGS', 'GLUTES', 'CALVES'],
//     'Épaules': ['SHOULDERS', 'DELTOIDS', 'TRAPEZIUS'],
//     'Bras': ['BICEPS', 'TRICEPS', 'FOREARMS'],
//     'Abdominaux': ['ABS', 'OBLIQUES', 'CORE'],
//   };

//   String? _selectedMuscleGroup;
//   String? _selectedCategory; // Stocke le code de catégorie (ex: 'BARBELL')
//   String? _selectedCategoryName; // Stocke le nom affiché (ex: 'Barre')

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: _muscleGroups.length, vsync: this);
//     _tabController.addListener(_onTabChanged);
    
//     // Charger les exercices au démarrage
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = context.read<ExerciseLibraryProvider>();
//       if (provider.exercises.isEmpty) {
//         provider.loadExercises();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _searchController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _onTabChanged() {
//     if (!_tabController.indexIsChanging) {
//       final selectedTab = _muscleGroups[_tabController.index];
//       setState(() {
//         _selectedMuscleGroup = selectedTab == 'Tous' ? null : selectedTab;
//       });
//       _applyFilters();
//     }
//   }

//   void _onCategorySelected(String categoryCode, String categoryName) {
//     setState(() {
//       // Désélectionner si déjà sélectionné ou si "Tous"
//       if (_selectedCategory == categoryCode || categoryCode.isEmpty) {
//         _selectedCategory = null;
//         _selectedCategoryName = null;
//       } else {
//         _selectedCategory = categoryCode;
//         _selectedCategoryName = categoryName;
//       }
//     });
//     _applyFilters();
//   }

//   void _onSearchChanged(String query) {
//     _applyFilters();
//   }

//   void _applyFilters() {
//     final provider = context.read<ExerciseLibraryProvider>();

//     // Appliquer recherche
//     provider.search(_searchController.text);

//     // Appliquer filtre muscle : passer tous les codes du groupe sélectionné
//     if (_selectedMuscleGroup != null && _selectedMuscleGroup != 'Tous') {
//       final codes = _muscleGroupToCodes[_selectedMuscleGroup] ?? [];
//       provider.filterByMuscleGroup(codes);
//     } else {
//       provider.filterByMuscle(null);
//     }

//     // Appliquer filtre catégorie : passer le code réel
//     provider.filterByCategory(_selectedCategory);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return Scaffold(
//       appBar: AppBar(
//         // title: const Text('Sélection d\'exercice'),
//         backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
//         elevation: 0,
//       ),
//       body: AppBackground(
//         child: Column(
//           children: [
//             // Barre de recherche
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: AppTextField(
//                 controller: _searchController,
//                 hintText: 'Rechercher un exercice...',
//                 prefixIcon: const Icon(Icons.search),
//                 onChanged: _onSearchChanged,
//               ),
//             ),

//             // Tabs par groupe musculaire
//             TabBar(
//               controller: _tabController,
//               isScrollable: true,
//               tabAlignment: TabAlignment.start,
//               labelColor: colorScheme.primary,
//               unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
//               indicatorColor: colorScheme.primary,
//               tabs: _muscleGroups.map((group) => Tab(text: group)).toList(),
//             ),

//             // Sous-tabs par catégorie (FilterChips)
//             _buildCategoryFilters(colorScheme),

//             // Liste des exercices
//             Expanded(
//               child: _buildExerciseList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Filtres de catégories (sous-tabs avec FilterChips)
//   Widget _buildCategoryFilters(ColorScheme colorScheme) {
//     return Consumer<ExerciseLibraryProvider>(
//       builder: (context, provider, _) {
//         final categoryCodes = provider.getAvailableCategories();

//         return SizedBox(
//           height: 50,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             itemCount: categoryCodes.length + 1, // +1 pour "Tous"
//             itemBuilder: (context, index) {
//               if (index == 0) {
//                 // Chip "Tous"
//                 final isSelected = _selectedCategory == null;
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 8),
//                   child: FilterChip(
//                     label: const Text('Tous'),
//                     selected: isSelected,
//                     onSelected: (_) => _onCategorySelected('', 'Tous'),
//                     backgroundColor: colorScheme.surface,
//                     selectedColor: colorScheme.primary.withValues(alpha: 0.2),
//                     checkmarkColor: colorScheme.primary,
//                   ),
//                 );
//               }

//               final code = categoryCodes[index - 1];
//               final name = provider.getCategoryName(code) ?? code;
//               final isSelected = _selectedCategory == code;

//               return Padding(
//                 padding: const EdgeInsets.only(right: 8),
//                 child: FilterChip(
//                   label: Text(name),
//                   selected: isSelected,
//                   onSelected: (_) => _onCategorySelected(code, name),
//                   backgroundColor: colorScheme.surface,
//                   selectedColor: colorScheme.primary.withValues(alpha: 0.2),
//                   checkmarkColor: colorScheme.primary,
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   /// Liste des exercices
//   Widget _buildExerciseList() {
//     return Consumer<ExerciseLibraryProvider>(
//       builder: (context, provider, _) {
//         final colorScheme = Theme.of(context).colorScheme;

//         // État de chargement
//         if (provider.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         // État d'erreur
//         if (provider.error != null) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.error_outline,
//                   size: 64,
//                   color: colorScheme.error,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Erreur de chargement',
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: colorScheme.onSurface,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   provider.error!,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: colorScheme.onSurface.withValues(alpha: 0.6),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton.icon(
//                   onPressed: () => provider.loadExercises(),
//                   icon: const Icon(Icons.refresh),
//                   label: const Text('Réessayer'),
//                 ),
//               ],
//             ),
//           );
//         }

//         // Liste vide
//         if (provider.exercises.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.fitness_center,
//                   size: 64,
//                   color: colorScheme.onSurface.withValues(alpha: 0.3),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Aucun exercice trouvé',
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: colorScheme.onSurface,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Essayez de modifier vos filtres',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: colorScheme.onSurface.withValues(alpha: 0.6),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         // Liste des exercices avec RefreshIndicator
//         return RefreshIndicator(
//           onRefresh: () => provider.refresh(),
//           child: ListView.builder(
//             controller: _scrollController,
//             padding: const EdgeInsets.all(16),
//             itemCount: provider.exercises.length,
//             itemBuilder: (context, index) {
//               final exercise = provider.exercises[index];
//               return _buildExerciseCard(context, exercise, colorScheme);
//             },
//           ),
//         );
//       },
//     );
//   }

//   /// Card d'exercice avec le style original
//   Widget _buildExerciseCard(
//     BuildContext context,
//     ExerciseLibrary exercise,
//     ColorScheme colorScheme,
//   ) {
//     // Obtenir emoji basé sur les muscles primaires (fallback)
//     final emoji = _getEmojiForExercise(exercise);
    
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: AppCard(
//         variant: AppCardVariant.elevated,
//         padding: const EdgeInsets.all(16),
//         onTap: () => _onExerciseSelected(exercise),
//         child: Row(
//           children: [
//             // Image avec fallback emoji (affiche image si disponible localement)
//             ExerciseImageThumbnail(
//               exerciseId: exercise.id,
//               fallbackEmoji: emoji,
//               size: 56,
//             ),
//             const SizedBox(width: 16),

//             // Informations exercice
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Nom
//                   Text(
//                     exercise.name,
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                           fontWeight: FontWeight.w600,
//                         ),
//                   ),
//                   const SizedBox(height: 4),

//                   // Muscles primaires
//                   Text(
//                     exercise.primaryMusclesText,
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           color: colorScheme.onSurface.withValues(alpha: 0.7),
//                         ),
//                   ),

//                   // Catégorie
//                   if (exercise.categories.isNotEmpty)
//                     Text(
//                       exercise.categories.first.name,
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                             color: colorScheme.primary.withValues(alpha: 0.8),
//                           ),
//                     ),
//                 ],
//               ),
//             ),

//             // Icône chevron
//             Icon(
//               Icons.chevron_right,
//               color: colorScheme.onSurface.withValues(alpha: 0.3),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Obtenir emoji pour un exercice basé sur les muscles primaires
//   String _getEmojiForExercise(ExerciseLibrary exercise) {
//     if (exercise.primaryMuscles.isEmpty) return '💪';

//     final muscleName = exercise.primaryMuscles.first.name.toLowerCase();
    
//     if (muscleName.contains('pectora') || muscleName.contains('chest')) return '💪';
//     if (muscleName.contains('dorsa') || muscleName.contains('back')) return '🦾';
//     if (muscleName.contains('jambe') || muscleName.contains('leg') ||
//         muscleName.contains('quadri') || muscleName.contains('fessier') ||
//         muscleName.contains('mollet')) return '🦵';
//     if (muscleName.contains('épaule') || muscleName.contains('shoulder') ||
//         muscleName.contains('trapèze')) return '💪';
//     if (muscleName.contains('bras') || muscleName.contains('bicep') ||
//         muscleName.contains('tricep')) return '💪';
//     if (muscleName.contains('abdomi') || muscleName.contains('abs') ||
//         muscleName.contains('oblique')) return '🏋️';
    
//     return '💪';
//   }

//   /// Callback quand un exercice est sélectionné
//   /// Navigue vers WorkoutSessionScreen pour enregistrer les séries
//   void _onExerciseSelected(ExerciseLibrary exerciseLibrary) {
//     Navigator.of(context).push(
//       AppPageRoute.slideRight(
//         builder: (context) => WorkoutSessionScreen(exercise: exerciseLibrary),
//       ),
//     );
//   }
// }
