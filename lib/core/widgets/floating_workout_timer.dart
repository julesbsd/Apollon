import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';
import 'pr_celebration_overlay.dart';
import '../../app.dart';

/// Widget flottant affichant le chronomètre de séance et le bouton stop
///
/// Fonctionnalités :
/// - Affichage global sur toute l'application pendant une séance active
/// - Design opaque (aucun flou / BackdropFilter) : fond plein
///   `lightOnBackground` en theme clair, `darkSurfaceVariant` avec filet
///   d'or `accentGoldLine` a 28% en theme sombre.
/// - Chronomètre en temps réel, chiffres JetBrains Mono 800/19
/// - Pastille d'or en respiration continue (boucle assumee, hors regle
///   RayonSweep qui est reservee au passage unique de la celebration PR)
/// - Libelle d'etat a droite (EN SEANCE / REPOS)
/// - Bouton stop avec confirmation avant de terminer
class FloatingWorkoutTimer extends StatefulWidget {
  const FloatingWorkoutTimer({super.key});

  @override
  State<FloatingWorkoutTimer> createState() => _FloatingWorkoutTimerState();
}

class _FloatingWorkoutTimerState extends State<FloatingWorkoutTimer>
    with SingleTickerProviderStateMixin {
  bool _isDialogShowing = false;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();
    // Pastille d'or en respiration continue : boucle assumee et
    // explicitement hors regle RayonSweep (qui n'autorise qu'un seul
    // passage par declenchement, cf. rayon_sweep.dart).
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseOpacity = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Visibilité: ne se reconstruit que quand une séance démarre/s'arrête, pas à chaque tick.
    return Selector<WorkoutProvider, bool>(
      selector: (_, p) => p.hasActiveWorkout,
      builder: (context, hasActiveWorkout, _) {
        if (!hasActiveWorkout) return const SizedBox.shrink();
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Positioned(
          left: 60,
          right: 60,
          bottom: 16,
          child: _buildTimerCard(context, isDark),
        );
      },
    );
  }

  /// Construit la carte du chronomètre - fond opaque, sans flou.
  Widget _buildTimerCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightOnBackground,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(
                color: AppTheme.accentGoldLine.withValues(alpha: 0.28),
                width: 1,
              )
            : null,
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
          _buildPulseDot(isDark),
          const SizedBox(width: 10),
          Flexible(
            child: _buildTimerText(isDark),
          ),
          const SizedBox(width: 10),
          _buildStatusLabel(isDark),
          const SizedBox(width: 10),
          _buildStopButton(context, Theme.of(context).colorScheme),
        ],
      ),
    );
  }

  /// Pastille d'or en respiration continue (opacite 0.5 <-> 1, 2s, ease-in-out).
  Widget _buildPulseDot(bool isDark) {
    final gold = isDark ? AppTheme.accentGold : AppTheme.lightAccentGold;
    return AnimatedBuilder(
      animation: _pulseOpacity,
      builder: (_, _) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: gold.withValues(alpha: _pulseOpacity.value),
        ),
      ),
    );
  }

  /// Construit le texte du chronomètre - JetBrains Mono 800/19.
  Widget _buildTimerText(bool isDark) {
    final textColor = isDark ? AppTheme.darkOnBackground : Colors.white;
    // Seul le texte du chrono se reconstruit chaque seconde (pas toute la carte).
    return Selector<WorkoutProvider, String>(
      selector: (_, p) => p.elapsedTimeFormatted,
      builder: (_, elapsed, _) => Text(
        elapsed,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Libelle d'etat a droite : EN SEANCE / REPOS.
  ///
  /// NB : WorkoutProvider n'expose aucune notion de pause/repos dans le
  /// modele de domaine actuel (RG-004 ne definit qu'un draft actif ou
  /// termine). Ce widget n'est visible que lorsque `hasActiveWorkout` est
  /// vrai, donc le libelle affiche en permanence "EN SEANCE" ; la variante
  /// "REPOS" est cablee mais restera inutilisee tant qu'un etat de pause
  /// n'existera pas cote provider - il s'agit d'une impossibilite reelle
  /// (donnee manquante), pas d'un choix de design.
  Widget _buildStatusLabel(bool isDark) {
    final textColor = isDark ? AppTheme.darkOnBackground : Colors.white;
    return Text(
      'EN SEANCE',
      style: GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.14 * 11,
        color: textColor.withValues(alpha: 0.75),
      ),
    );
  }

  /// Construit le bouton stop
  Widget _buildStopButton(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () =>
            _showCompleteDialog(context, context.read<WorkoutProvider>()),
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
