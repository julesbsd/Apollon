import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/models/exercise.dart';
import '../../core/models/workout_set.dart';
import '../../core/providers/workout_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/workout_service.dart';
import '../../core/widgets/widgets.dart';

/// Écran d'enregistrement de séance pour un exercice
/// Implémente US-4.3: Affichage historique + ajout de séries
///
/// Features:
/// - Header avec infos exercice
/// - Section historique (dernière séance - RG-005)
/// - Section séries actuelles (liste dynamique)
/// - Dialog pour ajouter une série (validation RG-003)
/// - Boutons "Terminer l'exercice" et "Terminer la séance"
/// - Auto-save toutes les 10s (RG-004) géré par WorkoutProvider
class WorkoutSessionScreen extends StatefulWidget {
  final Exercise exercise;

  const WorkoutSessionScreen({super.key, required this.exercise});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  final WorkoutService _workoutService = WorkoutService();

  // État pour l'historique (chargé une seule fois)
  bool _isLoadingHistory = true;
  dynamic _lastWorkout;
  String? _historyError;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  /// Charger l'historique une seule fois au démarrage
  Future<void> _loadHistory() async {
    final authProvider = context.read<AuthProvider>();
    try {
      final result = await _workoutService.getLastWorkoutForExercise(
        authProvider.user!.uid,
        widget.exercise.id,
      );
      if (mounted) {
        setState(() {
          _lastWorkout = result;
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _historyError = e.toString();
          _isLoadingHistory = false;
        });
      }
    }
  }

  /// Format date DD/MM
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    // Récupérer l'exercice actuel de la séance
    final currentExercise = workoutProvider.getExercise(widget.exercise.id);

    return Scaffold(
      appBar: const WorkoutTimerAppBar(
        title: 'Enregistrement',
        showTimer: true,
      ),
      body: AppBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header exercice
              _buildExerciseHeader(context, colorScheme),

              const SizedBox(height: 24),

              // Section historique
              _buildHistorySection(context, colorScheme),

              const SizedBox(height: 24),

              // Section séries actuelles
              _buildCurrentSetsSection(
                context,
                colorScheme,
                workoutProvider,
                currentExercise?.sets ?? [],
              ),

              const SizedBox(height: 24),

              // Boutons d'action
              _buildActionButtons(context, workoutProvider),
            ],
          ),
        ),
      ),
    );
  }

  /// Header avec infos de l'exercice
  Widget _buildExerciseHeader(BuildContext context, ColorScheme colorScheme) {
    return AppCard(
      variant: AppCardVariant.elevated,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                // Neumorphism - Ombre claire en haut à gauche
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.white.withOpacity(0.9),
                  blurRadius: 10,
                  offset: const Offset(-5, -5),
                ),
                // Neumorphism - Ombre sombre en bas à droite
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withOpacity(0.6)
                      : colorScheme.primary.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(5, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.exercise.emoji,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.exercise.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.exercise.muscleGroups.join(', ')} • ${widget.exercise.type}',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section historique (dernière séance - RG-005)
  Widget _buildHistorySection(BuildContext context, ColorScheme colorScheme) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Historique',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Afficher l'état chargé une seule fois
          if (_isLoadingHistory)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_historyError != null)
            Text(
              'Erreur de chargement',
              style: TextStyle(fontSize: 14, color: colorScheme.error),
            )
          else if (_lastWorkout == null || _lastWorkout.sets.isEmpty)
            Text(
              'Aucune donnée pour cet exercice\nPremière fois ! 💪',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            )
          else
            // Afficher les séries de la dernière séance
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dernière séance (${_formatDate(_lastWorkout.createdAt)}):',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                ..._lastWorkout.sets.asMap().entries.map((entry) {
                  final index = entry.key;
                  final set = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• Série ${index + 1}: ${set.display()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
        ],
      ),
    );
  }

  /// Section séries actuelles avec formulaire inline
  Widget _buildCurrentSetsSection(
    BuildContext context,
    ColorScheme colorScheme,
    WorkoutProvider workoutProvider,
    List<WorkoutSet> sets,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fitness_center, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Séries actuelles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Formulaire d'ajout inline
          _InlineAddSetForm(
            setNumber: sets.length + 1,
            exerciseId: widget.exercise.id,
            exerciseName: widget.exercise.name,
          ),

          // Liste des séries
          if (sets.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ...sets.asMap().entries.map((entry) {
              final index = entry.key;
              final set = entry.value;
              return _buildSetRow(
                context,
                colorScheme,
                workoutProvider,
                index,
                set,
              );
            }),
          ],
        ],
      ),
    );
  }

  /// Ligne pour une série avec bouton supprimer
  Widget _buildSetRow(
    BuildContext context,
    ColorScheme colorScheme,
    WorkoutProvider workoutProvider,
    int index,
    WorkoutSet set,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  // Neumorphism - Ombre claire en haut à gauche
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.white.withOpacity(0.8),
                    blurRadius: 6,
                    offset: const Offset(-3, -3),
                  ),
                  // Neumorphism - Ombre sombre en bas à droite
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.5)
                        : colorScheme.primary.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              child: Text(
                '${index + 1}. ${set.display()}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              workoutProvider.removeSet(widget.exercise.id, index);
            },
            color: colorScheme.error,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// Bouton "Terminer l'exercice"
  /// Note: "Terminer la séance" est maintenant dans WorkoutTimerAppBar
  Widget _buildActionButtons(
    BuildContext context,
    WorkoutProvider workoutProvider,
  ) {
    return AppButton(
      text: 'Terminer l\'exercice',
      icon: Icons.arrow_back,
      variant: AppButtonVariant.secondary,
      onPressed: () {
        Navigator.pop(context);
      },
      width: double.infinity,
    );
  }
}

/// Widget stateful pour le formulaire d'ajout de série inline
class _InlineAddSetForm extends StatefulWidget {
  final int setNumber;
  final String exerciseId;
  final String exerciseName;

  const _InlineAddSetForm({
    required this.setNumber,
    required this.exerciseId,
    required this.exerciseName,
  });

  @override
  State<_InlineAddSetForm> createState() => _InlineAddSetFormState();
}

class _InlineAddSetFormState extends State<_InlineAddSetForm> {
  late final TextEditingController _repsController;
  late final TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _repsController = TextEditingController();
    _weightController = TextEditingController();
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final workoutProvider = Provider.of<WorkoutProvider>(
      context,
      listen: false,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          // Neumorphism - Ombre claire en haut à gauche
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.06)
                : Colors.white.withOpacity(0.9),
            blurRadius: 10,
            offset: const Offset(-5, -5),
          ),
          // Neumorphism - Ombre sombre en bas à droite
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.5)
                : colorScheme.primary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Numéro de série
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                // Neumorphism - Effet primary intense
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(-2, -2),
                ),
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.8),
                  blurRadius: 6,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${widget.setNumber}',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Champ Reps
          Expanded(
            child: TextField(
              controller: _repsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Reps',
                hintText: '12',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Champ Poids
          Expanded(
            child: TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Poids (kg)',
                hintText: '50',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Bouton ajouter
          IconButton(
            icon: const Icon(Icons.add_circle),
            color: colorScheme.primary,
            iconSize: 32,
            onPressed: () {
              final reps = int.tryParse(_repsController.text);
              final weight = double.tryParse(_weightController.text) ?? 0;

              if (reps == null || reps <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Les répétitions doivent être > 0'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              if (weight < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Le poids doit être ≥ 0'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              // Ajouter la série
              try {
                workoutProvider.addSet(
                  widget.exerciseId,
                  reps,
                  weight,
                  exerciseName: widget.exerciseName,
                );

                // Clear les champs
                _repsController.clear();
                _weightController.clear();

                // Optionnel: refocus sur le champ reps
                FocusScope.of(context).requestFocus(FocusNode());
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
              }
            },
          ),
        ],
      ),
    );
  }
}
