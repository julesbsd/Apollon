import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import 'pr_celebration_overlay.dart';
import '../../app.dart';

/// Widget flottant affichant le chronomètre de séance et le bouton stop
/// 
/// Fonctionnalités :
/// - Affichage global sur toute l'application pendant une séance active
/// - Design compact style "Dynamic Island" avec effet de flou
/// - Chronomètre en temps réel
/// - Bouton stop avec confirmation avant de terminer
class FloatingWorkoutTimer extends StatefulWidget {
  const FloatingWorkoutTimer({super.key});

  @override
  State<FloatingWorkoutTimer> createState() => _FloatingWorkoutTimerState();
}

class _FloatingWorkoutTimerState extends State<FloatingWorkoutTimer> {
  bool _isDialogShowing = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    // Afficher uniquement si une séance est active
    if (!workoutProvider.hasActiveWorkout) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 60,
      right: 60,
      bottom: 16,
      child: _buildTimerCard(context, colorScheme, workoutProvider),
    );
  }

  /// Construit la carte du chronomètre avec effet de flou
  Widget _buildTimerCard(
    BuildContext context,
    ColorScheme colorScheme,
    WorkoutProvider workoutProvider,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: _buildTimerText(colorScheme, workoutProvider),
              ),
              _buildStopButton(context, colorScheme, workoutProvider),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit le texte du chronomètre
  Widget _buildTimerText(
    ColorScheme colorScheme,
    WorkoutProvider workoutProvider,
  ) {
    return Text(
      workoutProvider.elapsedTimeFormatted,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colorScheme.primary,
        letterSpacing: 0.5,
        decoration: TextDecoration.none,
      ),
    );
  }

  /// Construit le bouton stop
  Widget _buildStopButton(
    BuildContext context,
    ColorScheme colorScheme,
    WorkoutProvider workoutProvider,
  ) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => _showCompleteDialog(context, workoutProvider),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: colorScheme.error,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.stop_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  /// Affiche le dialog de confirmation pour terminer/abandonner la séance
  Future<void> _showCompleteDialog(
    BuildContext context,
    WorkoutProvider workoutProvider,
  ) async {
    if (_isDialogShowing) return;

    setState(() => _isDialogShowing = true);

    // Utiliser le contexte du Navigator global pour éviter le problème
    // du widget étant dans le builder() de MaterialApp (au-dessus du Navigator)
    final navContext = navigatorKey.currentContext ?? context;
    final colorScheme = Theme.of(navContext).colorScheme;
    final workout = workoutProvider.currentWorkout;

    if (workout == null) {
      setState(() => _isDialogShowing = false);
      return;
    }

    final hasExercises = workout.exercises.any((ex) => ex.sets.isNotEmpty);

    if (!hasExercises) {
      await _showEmptyWorkoutDialog(navContext, colorScheme, workoutProvider);
    } else {
      await _showCompleteWorkoutDialog(navContext, colorScheme, workoutProvider, workout);
    }

    setState(() => _isDialogShowing = false);
  }

  /// Dialog pour séance vide (abandon)
  Future<void> _showEmptyWorkoutDialog(
    BuildContext context,
    ColorScheme colorScheme,
    WorkoutProvider workoutProvider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: colorScheme.primary),
            const SizedBox(width: 12),
            const Text('Séance vide'),
          ],
        ),
        content: const Text(
          'Vous n\'avez enregistré aucun exercice. La séance sera abandonnée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continuer'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
            ),
            child: const Text('Abandonner'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      workoutProvider.cancelWorkout();
      if (context.mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Séance abandonnée')),
        );
      }
    }
  }

  /// Dialog pour séance avec exercices (terminer)
  Future<void> _showCompleteWorkoutDialog(
    BuildContext context,
    ColorScheme colorScheme,
    WorkoutProvider workoutProvider,
    dynamic workout,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: colorScheme.primary),
            const SizedBox(width: 12),
            const Text('Terminer la séance ?'),
          ],
        ),
        content: Text(
          'Vous avez enregistré ${workout.exercises.length} exercice(s)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continuer'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Terminer'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final newPRs = await workoutProvider.completeWorkout();

        if (context.mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);

          // Afficher la célébration PR si de nouveaux records ont été battus
          if (newPRs.isNotEmpty && context.mounted) {
            await showPrCelebration(context, newPRs);
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('✅ Séance terminée avec succès !'),
                backgroundColor: colorScheme.primary,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      }
    }
  }
}
