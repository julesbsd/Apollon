import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/exercise.dart';
import '../../core/services/exercise_service.dart';
import '../../core/providers/workout_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/widgets.dart';
import '../../core/utils/page_transitions.dart';
import '../workout/workout_session_screen.dart';

/// Écran de sélection d'exercice
/// Implémente US-4.2: Filtres par groupe musculaire, type, et recherche
///
/// Features:
/// - Tabs par groupe musculaire (Pectoraux, Dos, Jambes, etc.)
/// - Sous-tabs par type (Poids libres, Machine, Poids corporel, Cardio)
/// - Barre de recherche en temps réel
/// - Liste optimisée avec ListView.builder
class ExerciseSelectionScreen extends StatefulWidget {
  const ExerciseSelectionScreen({super.key});

  @override
  State<ExerciseSelectionScreen> createState() =>
      _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState extends State<ExerciseSelectionScreen>
    with SingleTickerProviderStateMixin {
  final ExerciseService _exerciseService = ExerciseService();
  final TextEditingController _searchController = TextEditingController();

  late TabController _tabController;

  // Filtres
  String? _selectedMuscleGroup;
  String? _selectedType;
  String _searchQuery = '';

  // Groupes musculaires pour les tabs
  final List<String> _muscleGroups = [
    'Tous',
    'Pectoraux',
    'Dorsaux',
    'Jambes',
    'Épaules',
    'Bras',
    'Abdominaux',
  ];

  // Types d'exercice pour les sous-tabs
  final List<String> _exerciseTypes = [
    'Tous',
    'Poids libres',
    'Machine',
    'Poids corporel',
    'Cardio',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _muscleGroups.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {
      final index = _tabController.index;
      _selectedMuscleGroup = index == 0 ? null : _muscleGroups[index];
    });
  }

  void _onTypeSelected(String type) {
    setState(() {
      _selectedType = type == 'Tous' ? null : type;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  /// Filtre les exercices selon les critères sélectionnés
  List<Exercise> _filterExercises(List<Exercise> exercises) {
    var filtered = exercises;

    // Filtre par groupe musculaire
    if (_selectedMuscleGroup != null) {
      filtered = filtered.where((ex) {
        return ex.muscleGroups.any(
          (group) => group.toLowerCase() == _selectedMuscleGroup!.toLowerCase(),
        );
      }).toList();
    }

    // Filtre par type
    if (_selectedType != null) {
      filtered = filtered.where((ex) {
        return ex.type.toLowerCase() == _selectedType!.toLowerCase();
      }).toList();
    }

    // Filtre par recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((ex) {
        return ex.name.toLowerCase().contains(_searchQuery) ||
            ex.muscleGroups.any(
              (group) => group.toLowerCase().contains(_searchQuery),
            );
      }).toList();
    }

    return filtered;
  }

  /// Navigation vers l'écran d'enregistrement de séance
  void _selectExercise(BuildContext context, Exercise exercise) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final workoutProvider = Provider.of<WorkoutProvider>(
      context,
      listen: false,
    );

    // Démarrer une nouvelle séance si pas déjà démarrée
    if (!workoutProvider.hasActiveWorkout) {
      workoutProvider.startNewWorkout(authProvider.user!.uid);
    }

    // Note: L'exercice sera ajouté à la séance lors du premier enregistrement de série
    // Cela évite d'avoir des exercices vides dans la séance

    // Navigation vers WorkoutSessionScreen
    Navigator.of(context).push(
      AppPageRoute.slideRight(
        builder: (context) => WorkoutSessionScreen(exercise: exercise),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const WorkoutTimerAppBar(
        title: 'Sélection d\'exercice',
        showTimer: true,
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
              unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
              indicatorColor: colorScheme.primary,
              tabs: _muscleGroups.map((group) => Tab(text: group)).toList(),
            ),

            // Sous-tabs par type
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _exerciseTypes.length,
                itemBuilder: (context, index) {
                  final type = _exerciseTypes[index];
                  final isSelected = _selectedType == null
                      ? type == 'Tous'
                      : _selectedType == type;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (_) => _onTypeSelected(type),
                      backgroundColor: colorScheme.surface,
                      selectedColor: colorScheme.primary.withOpacity(0.2),
                      checkmarkColor: colorScheme.primary,
                    ),
                  );
                },
              ),
            ),

            // Liste des exercices
            Expanded(
              child: StreamBuilder<List<Exercise>>(
                stream: _exerciseService.getAllExercises(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
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
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final exercises = _filterExercises(snapshot.data ?? []);

                  if (exercises.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 64,
                            color: colorScheme.onSurface.withOpacity(0.3),
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
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return _buildExerciseCard(context, exercise, colorScheme);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    Exercise exercise,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        variant: AppCardVariant.elevated,
        padding: const EdgeInsets.all(16),
        onTap: () => _selectExercise(context, exercise),
        child: Row(
          children: [
            // Emoji
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  // Neumorphism - Ombre claire en haut à gauche
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.white.withOpacity(0.9),
                    blurRadius: 8,
                    offset: const Offset(-4, -4),
                  ),
                  // Neumorphism - Ombre sombre en bas à droite
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.6)
                        : colorScheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(4, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  exercise.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Infos exercice
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${exercise.muscleGroups.join(', ')} • ${exercise.type}',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Flèche
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}
