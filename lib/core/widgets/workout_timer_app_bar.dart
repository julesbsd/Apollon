import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';

/// AppBar personnalisé avec chronomètre de séance
/// Enhanced US-4.1: Affiche le temps écoulé en temps réel
/// 
/// Features:
/// - Chronomètre visible en permanence (HH:MM:SS)
/// - Bouton "Terminer la séance" avec confirmation
/// - Animation subtle du chrono
class WorkoutTimerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showTimer;

  const WorkoutTimerAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showTimer = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    // Si pas de séance active, afficher AppBar normale
    if (!workoutProvider.hasActiveWorkout || !showTimer) {
      return AppBar(
        title: Text(title),
        leading: leading,
        actions: actions,
        backgroundColor: colorScheme.surface.withOpacity(0.8),
        elevation: 0,
      );
    }

    // AppBar avec chronomètre
    return AppBar(
      backgroundColor: colorScheme.surface.withOpacity(0.8),
      elevation: 0,
      leading: leading,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône timer avec animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Opacity(
                opacity: 0.5 + (value * 0.5),
                child: Icon(
                  Icons.timer,
                  color: colorScheme.primary,
                  size: 20,
                ),
              );
            },
          ),
          
          const SizedBox(width: 8),
          
          // Temps écoulé
          Text(
            workoutProvider.elapsedTimeFormatted,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        // Bouton "Terminer la séance"
        IconButton(
          icon: Icon(
            Icons.stop_circle,
            color: colorScheme.error,
            size: 28,
          ),
          tooltip: 'Terminer la séance',
          onPressed: () => _showCompleteDialog(context, workoutProvider),
        ),
        if (actions != null) ...actions!,
      ],
    );
  }

  /// Affiche le dialog de confirmation pour terminer la séance
  Future<void> _showCompleteDialog(
    BuildContext context,
    WorkoutProvider workoutProvider,
  ) async {
    final colorScheme = Theme.of(context).colorScheme;
    final workout = workoutProvider.currentWorkout;
    
    if (workout == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            const Text('Terminer la séance ?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Résumé de votre séance :',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              context,
              Icons.timer_outlined,
              'Durée',
              workoutProvider.elapsedTimeFormatted,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              context,
              Icons.fitness_center,
              'Exercices',
              '${workout.totalExercises}',
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              context,
              Icons.repeat,
              'Séries',
              '${workout.totalSets}',
            ),
            const SizedBox(height: 16),
            Text(
              'Voulez-vous enregistrer cette séance ?',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Annuler',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
            ),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.check),
            label: const Text('Terminer'),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await workoutProvider.completeWorkout();
        
        if (context.mounted) {
          // Retour à la HomePage
          Navigator.popUntil(context, (route) => route.isFirst);
          
          // Message de confirmation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: colorScheme.onPrimary),
                  const SizedBox(width: 12),
                  const Text('Séance enregistrée ! 💪'),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la sauvegarde: $e'),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Widget _buildSummaryRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
