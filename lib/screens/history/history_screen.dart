import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/models/workout.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/workout_service.dart';
import '../../core/widgets/marble_card.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/page_transitions.dart';
import 'workout_detail_screen.dart';

/// Écran d'historique des séances - Design Moderne V2
/// Implémente US-5.1: Liste des séances avec filtres et recherche
///
/// Features:
/// - Liste paginée des séances (20 par page)
/// - Tri par date décroissante
/// - Pull-to-refresh
/// - Filtres: Semaine, Mois, Tout
/// - Recherche par exercice
/// - Design moderne épuré avec MarbleCard
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final WorkoutService _workoutService = WorkoutService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // État
  List<Workout> _workouts = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;

  // Filtres
  String _selectedPeriod = 'Tout'; // 'Semaine', 'Mois', 'Tout'
  String _searchQuery = '';
  bool _sortAscending = false;

  // Pagination
  static const int _pageSize = 20;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Listener pour pagination au scroll
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  /// Charger les séances
  Future<void> _loadWorkouts({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _workouts = [];
        _hasMore = true;
      });
    }

    final authProvider = context.read<AuthProvider>();
    if (authProvider.user == null) return;

    try {
      // Calculer la date de début selon le filtre
      DateTime? startDate;
      final now = DateTime.now();

      if (_selectedPeriod == 'Semaine') {
        startDate = now.subtract(const Duration(days: 7));
      } else if (_selectedPeriod == 'Mois') {
        startDate = DateTime(now.year, now.month - 1, now.day);
      }

      final workouts = await _workoutService.getUserWorkouts(
        authProvider.user!.uid,
        limit: _pageSize,
        startDate: startDate,
      );

      setState(() {
        _workouts = workouts;
        _isLoading = false;
        _hasMore = workouts.length == _pageSize;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Charger plus de séances (pagination)
  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    final authProvider = context.read<AuthProvider>();
    if (authProvider.user == null) return;

    try {
      final moreWorkouts = await _workoutService.getUserWorkouts(
        authProvider.user!.uid,
        limit: _pageSize,
        startAfter: _workouts.last.createdAt,
      );

      setState(() {
        _workouts.addAll(moreWorkouts);
        _isLoadingMore = false;
        _hasMore = moreWorkouts.length == _pageSize;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  /// Filtrer les workouts selon la recherche
  List<Workout> get _filteredWorkouts {
    var filtered = _workouts;

    // Filtrer par recherche (nom d'exercice)
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((workout) {
        return workout.exercises.any(
          (exercise) => exercise.exerciseName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ),
        );
      }).toList();
    }

    // Trier
    filtered.sort((a, b) {
      final comparison = a.createdAt.compareTo(b.createdAt);
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? AppTheme.neutralGray900
          : const Color(0xFFF0F0F0),
      appBar: AppBar(
        title: const Text(
          'Historique',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          // Bouton tri
          IconButton(
            icon: Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
            ),
            onPressed: () {
              setState(() => _sortAscending = !_sortAscending);
            },
            tooltip: _sortAscending ? 'Plus anciennes' : 'Plus récentes',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filtres et recherche
            _buildFiltersSection(context),

            // Liste des séances
            Expanded(child: _buildWorkoutsList(context)),
          ],
        ),
      ),
    );
  }

  /// Section filtres et recherche
  Widget _buildFiltersSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Barre de recherche
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher par exercice...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
          const SizedBox(height: 12),

          // Filtres par période
          Row(
            children: [
              _buildPeriodChip('Semaine'),
              const SizedBox(width: 8),
              _buildPeriodChip('Mois'),
              const SizedBox(width: 8),
              _buildPeriodChip('Tout'),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Chip de filtre par période
  Widget _buildPeriodChip(String period) {
    final isSelected = _selectedPeriod == period;
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(period),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedPeriod = period);
        _loadWorkouts(refresh: true);
      },
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.5),
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.3),
      checkmarkColor: theme.colorScheme.primary,
    );
  }

  /// Liste des séances
  Widget _buildWorkoutsList(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Erreur: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadWorkouts(refresh: true),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    final workouts = _filteredWorkouts;

    if (workouts.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => _loadWorkouts(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: workouts.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == workouts.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final workout = workouts[index];
          return _buildWorkoutCard(context, workout);
        },
      ),
    );
  }

  /// Card de séance
  Widget _buildWorkoutCard(BuildContext context, Workout workout) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MarbleCard(
        onTap: () async {
          final deleted = await Navigator.push<bool>(
            context,
            AppPageRoute.fadeSlide(
              builder: (context) => WorkoutDetailScreen(workout: workout),
            ),
          );

          // Recharger l'historique si séance supprimée
          if (deleted == true && mounted) {
            _loadWorkouts(refresh: true);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date et durée
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateFormat.format(workout.createdAt),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (workout.duration != null)
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(workout.duration!),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Nombre d'exercices et séries totales
              Row(
                children: [
                  _buildStatChip(
                    context,
                    Icons.fitness_center,
                    '${workout.exercises.length} exercice${workout.exercises.length > 1 ? 's' : ''}',
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    context,
                    Icons.repeat,
                    '${workout.totalSets} série${workout.totalSets > 1 ? 's' : ''}',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Aperçu des exercices
              Text(
                workout.exercises
                        .map((e) => e.exerciseName)
                        .take(3)
                        .join(', ') +
                    (workout.exercises.length > 3 ? '...' : ''),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Chip de statistique
  Widget _buildStatChip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
        boxShadow: [
          // Neumorphism - Ombre claire en haut à gauche
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.8),
            blurRadius: 6,
            offset: const Offset(-3, -3),
          ),
          // Neumorphism - Ombre sombre en bas à droite
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.5)
                : theme.colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// État vide
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune séance',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Aucun résultat pour "$_searchQuery"'
                : 'Commencez une séance pour voir votre historique',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Formater la durée
  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h${minutes.toString().padLeft(2, '0')}';
    }
    return '${minutes}min';
  }
}
