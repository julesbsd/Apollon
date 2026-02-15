import 'package:flutter/material.dart';
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
  
  const WorkoutSessionScreen({
    super.key,
    required this.exercise,
  });

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
              _buildHistorySection(
                context,
                colorScheme,
              ),
              
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
  Widget _buildHistorySection(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                size: 20,
                color: colorScheme.primary,
              ),
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
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.error,
              ),
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
  
  /// Section séries actuelles
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
              Icon(
                Icons.fitness_center,
                size: 20,
                color: colorScheme.primary,
              ),
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
          
          // Liste des séries
          if (sets.isEmpty)
            Text(
              'Aucune série enregistrée',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            )
          else
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
            }).toList(),
          
          const SizedBox(height: 16),
          
          // Bouton ajouter série
          AppButton(
            text: 'Ajouter série',
            icon: Icons.add,
            variant: AppButtonVariant.outlined,
            onPressed: () => _showAddSetDialog(context, workoutProvider),
            width: double.infinity,
          ),
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
                color: colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
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
            icon: Icon(Icons.close, size: 20),
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
  
  /// Dialog pour ajouter une série avec validation RG-003
  void _showAddSetDialog(
    BuildContext context,
    WorkoutProvider workoutProvider,
  ) {
    final repsController = TextEditingController();
    final weightController = TextEditingController();
    String? repsError;
    String? weightError;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Ajouter une série'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppNumberField(
                  controller: repsController,
                  labelText: 'Répétitions',
                  hintText: 'Ex: 12',
                  errorText: repsError,
                ),
                
                const SizedBox(height: 16),
                
                AppNumberField(
                  controller: weightController,
                  labelText: 'Poids (kg)',
                  hintText: '0 pour poids de corps',
                  errorText: weightError,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              AppButton(
                text: 'Ajouter',
                variant: AppButtonVariant.primary,
                onPressed: () {
                  // Validation RG-003
                  setState(() {
                    repsError = null;
                    weightError = null;
                  });
                  
                  final reps = int.tryParse(repsController.text);
                  final weight = double.tryParse(weightController.text) ?? 0;
                  
                  if (reps == null || reps <= 0) {
                    setState(() {
                      repsError = 'Les répétitions doivent être > 0';
                    });
                    return;
                  }
                  
                  if (weight < 0) {
                    setState(() {
                      weightError = 'Le poids doit être ≥ 0';
                    });
                    return;
                  }
                  
                  // Ajouter la série (l'exercice sera créé s'il n'existe pas)
                  try {
                    workoutProvider.addSet(
                      widget.exercise.id,
                      reps,
                      weight,
                      exerciseName: widget.exercise.name,
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: $e')),
                    );
                  }
                },
              ),
            ],
          );
        },
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
