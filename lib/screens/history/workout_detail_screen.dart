import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/workout.dart';
import '../../core/models/workout_set.dart';
import '../../core/services/workout_service.dart';
import '../../core/widgets/widgets.dart';

/// Écran de détail d'une séance
/// Implémente US-5.2: Affichage complet d'une séance
/// 
/// Features:
/// - Affichage date, durée, nombre d'exercices
/// - Liste de tous les exercices avec leurs séries
/// - Format: reps × poids pour chaque série
/// - Bouton supprimer avec confirmation
/// - Design premium avec MarbleCard
class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutDetailScreen({
    super.key,
    required this.workout,
  });

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  final WorkoutService _workoutService = WorkoutService();
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      body: MeshGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // AppBar custom
              _buildAppBar(context),

              // Contenu scrollable
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête séance
                      _buildWorkoutHeader(context, dateFormat, timeFormat),
                      const SizedBox(height: 24),

                      // Liste des exercices
                      _buildExercisesList(context),
                      const SizedBox(height: 24),

                      // Bouton supprimer
                      _buildDeleteButton(context),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// AppBar personnalisée
  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            'Détail séance',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// En-tête de la séance
  Widget _buildWorkoutHeader(
    BuildContext context,
    DateFormat dateFormat,
    DateFormat timeFormat,
  ) {
    final theme = Theme.of(context);

    return MarbleCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormat.format(widget.workout.createdAt),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'à ${timeFormat.format(widget.workout.createdAt)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Statistiques
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.fitness_center,
                    'Exercices',
                    '${widget.workout.exercises.length}',
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.repeat,
                    'Séries',
                    '${widget.workout.totalSets}',
                  ),
                ),
                if (widget.workout.duration != null)
                  Expanded(
                    child: _buildStatItem(
                      context,
                      Icons.timer_outlined,
                      'Durée',
                      _formatDuration(widget.workout.duration!),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Item de statistique
  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          size: 28,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  /// Liste des exercices
  Widget _buildExercisesList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Exercices',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        ...widget.workout.exercises.asMap().entries.map((entry) {
          final index = entry.key;
          final exercise = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildExerciseCard(context, index + 1, exercise),
          );
        }),
      ],
    );
  }

  /// Card d'un exercice
  Widget _buildExerciseCard(
    BuildContext context,
    int number,
    dynamic exercise,
  ) {
    final theme = Theme.of(context);

    return MarbleCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom de l'exercice avec numéro
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    exercise.exerciseName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Liste des séries
            ...exercise.sets.asMap().entries.map((setEntry) {
              final setNumber = setEntry.key + 1;
              final workoutSet = setEntry.value as WorkoutSet;
              return _buildSetRow(context, setNumber, workoutSet);
            }),
          ],
        ),
      ),
    );
  }

  /// Ligne d'une série
  Widget _buildSetRow(
    BuildContext context,
    int setNumber,
    WorkoutSet workoutSet,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Numéro de série
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Center(
              child: Text(
                '$setNumber',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Reps × Poids
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyLarge,
                children: [
                  TextSpan(
                    text: '${workoutSet.reps}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontFamily: 'JetBrains Mono',
                    ),
                  ),
                  TextSpan(
                    text: ' reps × ',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  TextSpan(
                    text: '${workoutSet.weight}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontFamily: 'JetBrains Mono',
                    ),
                  ),
                  TextSpan(
                    text: ' kg',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bouton supprimer
  Widget _buildDeleteButton(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isDeleting ? null : () => _confirmDelete(context),
        icon: _isDeleting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.delete_outline),
        label: Text(_isDeleting ? 'Suppression...' : 'Supprimer cette séance'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.errorContainer,
          foregroundColor: theme.colorScheme.onErrorContainer,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  /// Confirmation de suppression
  Future<void> _confirmDelete(BuildContext context) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette séance ?'),
        content: const Text(
          'Cette action est irréversible. Toutes les données de cette séance seront perdues.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteWorkout();
    }
  }

  /// Supprimer la séance
  Future<void> _deleteWorkout() async {
    setState(() => _isDeleting = true);

    try {
      await _workoutService.deleteWorkout(
        widget.workout.userId,
        widget.workout.id!,
      );

      if (mounted) {
        Navigator.pop(context); // Retour à l'historique
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Séance supprimée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
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
