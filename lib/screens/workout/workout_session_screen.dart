import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/models/workout_set.dart';
import '../../core/providers/workout_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/statistics_service.dart';
import '../../core/widgets/widgets.dart';
import '../../core/models/exercise_library.dart';
import '../exercise_library/widgets/exercise_image_widget.dart';
import '../exercise_library/widgets/exercise_history_graph_panel.dart';

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
  final ExerciseLibrary exercise;

  const WorkoutSessionScreen({super.key, required this.exercise});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  final StatisticsService _statisticsService = StatisticsService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    // Récupérer l'exercice actuel de la séance
    final currentExercise = workoutProvider.getExercise(widget.exercise.id);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image de l'exercice en haut (système hybride asset/local/remote)
            _buildExerciseImage(context),

            // Contenu avec padding
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Nom de l'exercice + chips (catégorie, muscles)
                  _buildExerciseInfo(context, colorScheme),

                  const SizedBox(height: 16),

                  // Description technique (expandable, sans titre)
                  if (widget.exercise.description.isNotEmpty)
                    _buildDescriptionSection(context, colorScheme),

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

                  // Espace pour la barre flottante globale en bas
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Infos de l'exercice : nom + chips (catégorie, muscles)
  Widget _buildExerciseInfo(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nom de l'exercice
        Text(
          widget.exercise.name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        // Chips: catégorie + groupes musculaires
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Chips types d'exercice
            ...widget.exercise.types.map(
              (type) => Chip(
                label: Text(
                  type.name,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
                labelStyle: TextStyle(color: colorScheme.primary),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            
            // Chips muscles primaires
            ...widget.exercise.primaryMuscles.map(
              (muscle) => Chip(
                label: Text(
                  muscle.name,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: colorScheme.surface,
                labelStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.8)),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Section historique & progression avec sélecteur glissant
  Widget _buildHistorySection(BuildContext context, ColorScheme colorScheme) {
    final userId = context.read<AuthProvider>().user?.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historique & Progression',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        if (userId == null)
          Text(
            'Connecte-toi pour voir ton historique',
            style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
          )
        else
          ExerciseHistoryGraphPanel(
            exerciseId: widget.exercise.id,
            exerciseName: widget.exercise.name,
            userId: userId,
            statisticsService: _statisticsService,
          ),
      ],
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
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  // Neumorphism - Ombre claire en haut à gauche
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.white.withValues(alpha: 0.8),
                    blurRadius: 6,
                    offset: const Offset(-3, -3),
                  ),
                  // Neumorphism - Ombre sombre en bas à droite
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withValues(alpha: 0.5)
                        : colorScheme.primary.withValues(alpha: 0.15),
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

  /// Image de l'exercice avec système hybride (full width, en haut)
  Widget _buildExerciseImage(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: ExerciseImageWidget(
        exerciseId: widget.exercise.id,
        size: double.infinity,
        fit: BoxFit.contain,
        borderRadius: BorderRadius.zero,
      ),
    );
  }

  /// Section description technique (expandable, sans titre)
  Widget _buildDescriptionSection(BuildContext context, ColorScheme colorScheme) {
    return _ExpandableDescription(description: widget.exercise.description);
  }

  /// Bouton "Terminer l'exercice"
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
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          // Neumorphism - Ombre claire en haut à gauche
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.9),
            blurRadius: 10,
            offset: const Offset(-5, -5),
          ),
          // Neumorphism - Ombre sombre en bas à droite
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.5)
                : colorScheme.primary.withValues(alpha: 0.2),
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
                  color: Colors.white.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(-2, -2),
                ),
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.8),
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

/// Widget de description expandable
/// 
/// Affiche 2 lignes par défaut avec un bouton "Voir plus"
/// Clic sur le texte ou le bouton pour expand/collapse
class _ExpandableDescription extends StatefulWidget {
  final String description;

  const _ExpandableDescription({
    required this.description,
  });

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Texte avec limitation de lignes
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: AnimatedCrossFade(
            firstChild: Text(
              widget.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            secondChild: Text(
              widget.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ),
        const SizedBox(height: 8),
        
        // Bouton Voir plus / Voir moins
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isExpanded ? 'Voir moins' : 'Voir plus',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
