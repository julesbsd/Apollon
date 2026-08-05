import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/workout_set.dart';
import '../../core/models/workout_exercise.dart';
import '../../core/providers/workout_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/workout_service.dart';
import '../../core/widgets/widgets.dart';
import '../../core/models/exercise_library.dart';
import '../exercise_library/widgets/exercise_image_widget.dart';

/// Écran d'enregistrement de séance pour un exercice - fidele a la
/// maquette "Marbre & Lumiere" (_byan-output/design-directions), Ecran C.
///
/// Implémente US-4.3: Affichage historique + ajout de séries
///
/// Features:
/// - Header avec infos exercice (badge équipement, filet d'or, indicateur
///   d'enregistrement)
/// - Encart "Dernière séance" (RG-005, texte simple V1 - pas de graphique)
/// - Section séries actuelles (liste dynamique)
/// - Formulaire d'ajout de série (validation RG-003)
/// - CTA "Terminer la séance"
/// - Auto-save toutes les 10s (RG-004) géré par WorkoutProvider
class WorkoutSessionScreen extends StatefulWidget {
  final ExerciseLibrary exercise;

  /// Injectable pour les tests.
  final WorkoutService? workoutService;

  const WorkoutSessionScreen({
    super.key,
    required this.exercise,
    this.workoutService,
  });

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  late final WorkoutService _workoutService = widget.workoutService ?? WorkoutService();
  late Future<WorkoutExercise?> _lastWorkoutFuture;

  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthProvider>().user?.uid;
    _lastWorkoutFuture = userId == null
        ? Future.value(null)
        : _workoutService.getLastWorkoutForExercise(userId, widget.exercise.id);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onBackground = isDark ? AppTheme.darkOnBackground : AppTheme.lightOnBackground;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        // Indicateur d'enregistrement (RG-004 : sauvegarde auto continue -
        // un brouillon est toujours actif quand cet ecran est affiche).
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.successGreen),
                ),
                const SizedBox(width: 6),
                Text('ENREGISTRÉ', style: AppTheme.labelSecondary(AppTheme.successGreen).copyWith(fontSize: 10.5)),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildExerciseImage(context),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildExerciseInfo(context, colorScheme),
                  const SizedBox(height: 16),
                  if (widget.exercise.description.isNotEmpty) ...[
                    _buildDescriptionSection(context, colorScheme),
                    const SizedBox(height: 20),
                    _buildScrollDivider(context),
                    const SizedBox(height: 20),
                  ],
                  FutureBuilder<WorkoutExercise?>(
                    future: _lastWorkoutFuture,
                    builder: (context, snapshot) => _buildLastWorkoutRecap(context, snapshot.data),
                  ),
                  const SizedBox(height: 24),
                  // Section séries actuelles - Selector ciblé: ne se reconstruit que sur
                  // changement des séries, pas à chaque tick du chrono.
                  Selector<WorkoutProvider, List<WorkoutSet>>(
                    selector: (_, p) => p.getExercise(widget.exercise.id)?.sets ?? const [],
                    builder: (context, sets, _) => FutureBuilder<WorkoutExercise?>(
                      future: _lastWorkoutFuture,
                      builder: (context, snapshot) => _buildCurrentSetsSection(
                        context,
                        colorScheme,
                        context.read<WorkoutProvider>(),
                        sets,
                        snapshot.data,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildActionButtons(context, context.read<WorkoutProvider>()),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Puces muscles/type (spec maquette) : pastille pleine teintee de
  /// l'accent du groupe pour le muscle primaire, contour neutre pour le
  /// type d'exercice - jamais un simple texte colore sans support visuel.
  Widget _buildExerciseInfo(BuildContext context, ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onBackground = isDark ? AppTheme.darkOnBackground : AppTheme.lightOnBackground;
    final outline = isDark ? AppTheme.outlineSubtleDark : AppTheme.outlineSubtleLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.exercise.name, style: AppTheme.screenTitle(onBackground)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Puces muscles primaires : pastille pleine teintee, bordure et
            // texte dans l'accent du groupe.
            ...widget.exercise.primaryMuscles.map((muscle) {
              final accent = AppTheme.colorForMuscleCode(muscle.code);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.16 : 0.10),
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  border: Border.all(color: accent.withValues(alpha: 0.5)),
                ),
                child: Text(muscle.name, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: accent)),
              );
            }),
            // Puces type d'exercice : contour neutre, pas d'aplat.
            ...widget.exercise.types.map(
              (type) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  border: Border.all(color: outline.withValues(alpha: outline.a * 2)),
                ),
                child: Text(
                  type.name,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: onBackground.withValues(alpha: 0.7)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Separateur "DÉFILEMENT" (spec maquette) : filet pointille de part et
  /// d'autre d'un libelle centre, entre la description et le rappel de la
  /// derniere seance.
  Widget _buildScrollDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onBackground = isDark ? AppTheme.darkOnBackground : AppTheme.lightOnBackground;
    final dashColor = onBackground.withValues(alpha: 0.22);

    Widget dashedLine() => Expanded(
          child: CustomPaint(
            size: const Size(double.infinity, 1),
            painter: _DashedLinePainter(color: dashColor),
          ),
        );

    return Row(
      children: [
        dashedLine(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('DÉFILEMENT', style: AppTheme.labelSecondary(onBackground.withValues(alpha: 0.4)).copyWith(fontSize: 9)),
        ),
        dashedLine(),
      ],
    );
  }

  /// Encart "Dernière séance" (RG-005 : texte simple en V1, pas de
  /// graphique) - fidele a la maquette : cartouche surfaceVariant, libelle
  /// + date, une ligne Mono par serie (numero a gauche, reps x poids a
  /// droite).
  Widget _buildLastWorkoutRecap(BuildContext context, WorkoutExercise? lastExercise) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkOnSurfaceMuted : AppTheme.lightOnSurfaceMuted;
    final onBackground = isDark ? AppTheme.darkOnBackground : AppTheme.lightOnBackground;
    final bg = isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightSurfaceVariant;

    if (lastExercise == null || lastExercise.sets.isEmpty) {
      return EmptyStateCard(
        title: 'Pas de séance pour l\'instant',
        message: 'Cet exercice attend sa première charge.',
      );
    }

    final date = lastExercise.createdAt;
    final displayDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppTheme.radiusXL)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DERNIÈRE SÉANCE · $displayDate', style: AppTheme.labelSecondary(muted)),
          const SizedBox(height: 10),
          for (final entry in lastExercise.sets.asMap().entries) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Text('Série ${entry.key + 1}', style: TextStyle(fontSize: 13, color: onBackground, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Text(
                    '${entry.value.reps} × ${_formatWeight(entry.value.weight)} kg',
                    style: AppTheme.timerNumber(onBackground).copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatWeight(double weight) => weight.toStringAsFixed(1).replaceAll('.', ',');

  /// Section séries actuelles avec formulaire d'ajout.
  Widget _buildCurrentSetsSection(
    BuildContext context,
    ColorScheme colorScheme,
    WorkoutProvider workoutProvider,
    List<WorkoutSet> sets,
    WorkoutExercise? lastExercise,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkOnSurfaceMuted : AppTheme.lightOnSurfaceMuted;

    // Objectif indicatif pour la prochaine serie : la serie de meme rang
    // lors de la derniere seance, sinon la derniere serie enregistree.
    WorkoutSet? target;
    if (lastExercise != null && lastExercise.sets.isNotEmpty) {
      target = sets.length < lastExercise.sets.length
          ? lastExercise.sets[sets.length]
          : lastExercise.sets.last;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SÉRIES DU JOUR', style: AppTheme.labelSecondary(muted)),
        const SizedBox(height: 10),
        ...sets.asMap().entries.map((entry) {
          final index = entry.key;
          final set = entry.value;
          return _buildSetRow(context, colorScheme, workoutProvider, index, set);
        }),
        _InlineAddSetForm(
          setNumber: sets.length + 1,
          exerciseId: widget.exercise.id,
          exerciseName: widget.exercise.name,
          targetSet: target,
        ),
      ],
    );
  }

  /// Ligne d'une série validée (spec maquette "Serie") : filet d'or 2px
  /// trace via RayonSweep + entree en scaleX 300ms, chiffres reps/poids en
  /// grand format Mono, sans aplat colore derriere le chiffre.
  Widget _buildSetRow(
    BuildContext context,
    ColorScheme colorScheme,
    WorkoutProvider workoutProvider,
    int index,
    WorkoutSet set,
  ) {
    return _ValidatedSetRow(
      // Cle sur le contenu de la serie : une nouvelle serie validee joue son
      // entree (scaleX + balayage or) une seule fois.
      key: ValueKey('set-$index-${set.reps}-${set.weight}'),
      index: index + 1,
      reps: set.reps,
      weight: set.weight,
      onDelete: () => workoutProvider.removeSet(widget.exercise.id, index),
    );
  }

  /// Image de l'exercice sur le bandeau large d'en-tete (spec maquette) :
  /// socle ardoise, hauteur 186px, radius 16, degrade incline a 168deg,
  /// badge du type d'equipement en haut a droite, filet d'or en arete
  /// basse. Le pictogramme n'est jamais pose directement sur
  /// surface/surfaceVariant.
  Widget _buildExerciseImage(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldLine = isDark ? AppTheme.accentGoldLine : AppTheme.lightAccentGoldLine;
    final equipmentLabel = widget.exercise.types.isNotEmpty ? widget.exercise.types.first.name.toUpperCase() : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PictogramPlinth(
              height: 186,
              radius: 16,
              angleDegrees: 168,
              padding: const EdgeInsets.all(16),
              child: ExerciseImageWidget(
                exerciseId: widget.exercise.id,
                size: double.infinity,
                fit: BoxFit.contain,
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
          if (equipmentLabel != null)
            Positioned(
              top: 13,
              right: 15,
              child: Text(
                equipmentLabel,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 1.6, color: Colors.white.withValues(alpha: 0.45)),
              ),
            ),
          // Filet d'or en arete basse du bandeau.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [goldLine.withValues(alpha: 0), goldLine, goldLine.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, ColorScheme colorScheme) {
    return _ExpandableDescription(description: widget.exercise.description);
  }

  /// Zone d'actions : CTA critique "Terminer la séance" (spec maquette : un
  /// seul CTA en bas d'ecran, le retour se fait par la fleche de l'AppBar).
  Widget _buildActionButtons(
    BuildContext context,
    WorkoutProvider workoutProvider,
  ) {
    return Column(
      children: [
        Selector<WorkoutProvider, int>(
          selector: (_, p) => p.currentWorkout?.exercises.fold<int>(0, (sum, ex) => sum + ex.sets.length) ?? 0,
          builder: (context, totalSets, _) => CriticalCta(
            enabled: totalSets > 0,
            title: 'Terminer la séance',
            subtitle: 'Enregistrement définitif',
            disabledLabel: 'Ajoute une série pour terminer',
            onPressed: () => _confirmAndCompleteSession(context, workoutProvider),
          ),
        ),
      ],
    );
  }

  /// Dialogue de confirmation puis finalisation de la seance.
  Future<void> _confirmAndCompleteSession(
    BuildContext context,
    WorkoutProvider workoutProvider,
  ) async {
    final colorScheme = Theme.of(context).colorScheme;
    final workout = workoutProvider.currentWorkout;
    if (workout == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Terminer la séance ?'),
        content: Text(
          'Vous avez enregistré ${workout.exercises.length} exercice(s)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Continuer'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Terminer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final newPRs = await workoutProvider.completeWorkout();
      if (!context.mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
      if (newPRs.isNotEmpty && context.mounted) {
        await showPrCelebration(context, newPRs);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Séance terminée avec succès'),
            backgroundColor: colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    }
  }
}

/// Trace un filet horizontal pointille (spec "DÉFILEMENT").
class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 4.0;
    const dashSpace = 5.0;
    final paint = Paint()..color = color..strokeWidth = 1;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) => oldDelegate.color != color;
}

/// Ligne d'une série validée avec entree animee (scaleX 300ms) et filet d'or
/// balaye une fois via RayonSweep. Stateful pour ne jouer l'entree qu'a
/// l'apparition (nouvelle Key = nouvelle serie).
class _ValidatedSetRow extends StatefulWidget {
  final int index;
  final int reps;
  final double weight;
  final VoidCallback onDelete;

  const _ValidatedSetRow({
    super.key,
    required this.index,
    required this.reps,
    required this.weight,
    required this.onDelete,
  });

  @override
  State<_ValidatedSetRow> createState() => _ValidatedSetRowState();
}

class _ValidatedSetRowState extends State<_ValidatedSetRow> {
  double _scaleX = 0.0;

  @override
  void initState() {
    super.initState();
    // Entree scaleX 0 -> 1 sur 300ms au montage (serie tout juste validee).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _scaleX = 1.0);
    });
  }

  /// Formate le poids avec une decimale et une virgule (convention FR de la
  /// maquette : "30,0", pas "30.0").
  String _formatWeight(double weight) => weight.toStringAsFixed(1).replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onBackground = isDark ? AppTheme.darkOnBackground : AppTheme.lightOnBackground;
    final muted = isDark ? AppTheme.darkOnSurfaceMuted : AppTheme.lightOnSurfaceMuted;
    final goldLine = isDark ? AppTheme.accentGoldLine : AppTheme.lightAccentGoldLine;
    final surface = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      // scaleX 0 -> 1 : le filet d'or se "trace" horizontalement a l'entree.
      child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: _scaleX),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) => Transform(
            alignment: Alignment.centerLeft,
            transform: Matrix4.identity()..scaleByDouble(value, 1.0, 1.0, 1.0),
            child: child,
          ),
          // Ligne serie validee (spec maquette) : index a gauche, chiffres
          // reps/poids en grand Mono, filet d'or 2px en pied de ligne trace
          // par le balayage - jamais d'aplat colore derriere le chiffre.
          child: RayonSweep(
            color: AppTheme.accentGold.withValues(alpha: 0.4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                border: Border(
                  bottom: BorderSide(color: goldLine.withValues(alpha: 0.85), width: 2),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    child: Text('${widget.index}', style: AppTheme.timerNumber(muted).copyWith(fontSize: 12)),
                  ),
                  Text('${widget.reps}', style: AppTheme.seriesNumber(onBackground)),
                  Text(' reps', style: TextStyle(fontSize: 12, color: muted, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Text(_formatWeight(widget.weight), style: AppTheme.seriesNumber(onBackground)),
                  Text(' kg', style: TextStyle(fontSize: 12, color: muted, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: widget.onDelete,
                    color: muted,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}

/// Formulaire d'ajout de série : encart "SÉRIE N - EN COURS" avec objectif
/// indicatif, champs REPETITIONS/CHARGE(KG) en grand format, puis bouton
/// pleine largeur a bordure pointillee "+ AJOUTER UNE SÉRIE" (spec
/// maquette : distinct du picto "+" - c'est le CTA de soumission).
class _InlineAddSetForm extends StatefulWidget {
  final int setNumber;
  final String exerciseId;
  final String exerciseName;
  final WorkoutSet? targetSet;

  const _InlineAddSetForm({
    required this.setNumber,
    required this.exerciseId,
    required this.exerciseName,
    this.targetSet,
  });

  @override
  State<_InlineAddSetForm> createState() => _InlineAddSetFormState();
}

class _InlineAddSetFormState extends State<_InlineAddSetForm> {
  late final TextEditingController _repsController;
  late final TextEditingController _weightController;
  late final FocusNode _repsFocusNode;

  @override
  void initState() {
    super.initState();
    _repsController = TextEditingController();
    _weightController = TextEditingController();
    _repsFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    _repsFocusNode.dispose();
    super.dispose();
  }

  /// Champ de saisie grand format : libelle secondaire en capitales +
  /// nombre en JetBrains Mono 800/34 dans un cadre surfaceVariant (spec
  /// maquette "Serie 3 - EN COURS" : REPETITIONS / CHARGE (KG)).
  Widget _bigNumberField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required FocusNode? focusNode,
    required TextInputType keyboardType,
    required List<TextInputFormatter> inputFormatters,
    required String hint,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkOnSurfaceMuted : AppTheme.lightOnSurfaceMuted;
    final onBackground = isDark ? AppTheme.darkOnBackground : AppTheme.lightOnBackground;
    final fieldBg = isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.labelSecondary(muted)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(color: fieldBg, borderRadius: BorderRadius.circular(AppTheme.radiusL)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            textAlign: TextAlign.left,
            style: AppTheme.seriesNumber(onBackground, active: true),
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: AppTheme.seriesNumber(muted.withValues(alpha: 0.5), active: true),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 6),
            ),
          ),
        ),
      ],
    );
  }

  void _submit(BuildContext context, WorkoutProvider workoutProvider) {
    final reps = int.tryParse(_repsController.text);
    // Normalise la virgule décimale FR (12,5 -> 12.5) avant parsing
    final weight = double.tryParse(_weightController.text.replaceAll(',', '.')) ?? 0;

    if (reps == null || reps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les répétitions doivent être > 0'), duration: Duration(seconds: 2)),
      );
      return;
    }
    if (weight < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le poids doit être ≥ 0'), duration: Duration(seconds: 2)),
      );
      return;
    }

    try {
      workoutProvider.addSet(widget.exerciseId, reps, weight, exerciseName: widget.exerciseName);
      _repsController.clear();
      _weightController.clear();
      // Refocus sur le champ reps (FocusNode réutilisé du State, pas de fuite)
      _repsFocusNode.requestFocus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  static String _formatWeight(double weight) => weight.toStringAsFixed(1).replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onPrimaryLine = isDark ? AppTheme.primaryBlue : AppTheme.lightPrimaryBlue;
    final muted = isDark ? AppTheme.darkOnSurfaceMuted : AppTheme.lightOnSurfaceMuted;
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    final target = widget.targetSet;

    return Column(
      children: [
        RayonSweep(
          // Un unique passage a l'ouverture de la serie active (trigger cle
          // sur le numero de serie : change => nouvelle serie ouverte =>
          // un balayage).
          key: ValueKey('active-set-${widget.setNumber}'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
              border: Border.all(color: onPrimaryLine, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('SÉRIE ${widget.setNumber} · EN COURS', style: AppTheme.labelSecondary(onPrimaryLine)),
                    const Spacer(),
                    if (target != null)
                      Text(
                        'objectif ${target.reps} × ${_formatWeight(target.weight)}',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: muted),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _bigNumberField(
                        context: context,
                        label: 'RÉPÉTITIONS',
                        controller: _repsController,
                        focusNode: _repsFocusNode,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        hint: '12',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 6,
                      child: _bigNumberField(
                        context: context,
                        label: 'CHARGE (KG)',
                        controller: _weightController,
                        focusNode: null,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        // Accepte le point ET la virgule (claviers FR).
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*'))],
                        hint: '50',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // CTA de soumission pleine largeur, bordure pointillee (spec
        // maquette "+ AJOUTER UNE SÉRIE" - distinct de l'encart de saisie).
        InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          onTap: () => _submit(context, workoutProvider),
          child: CustomPaint(
            painter: _DashedBorderPainter(color: onPrimaryLine.withValues(alpha: 0.5), radius: AppTheme.radiusXL),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              child: Text(
                '+ AJOUTER UNE SÉRIE',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.06 * 13, color: onPrimaryLine),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Trace une bordure rectangulaire pointillee a coins arrondis (spec CTA
/// "+ AJOUTER UNE SÉRIE").
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dashWidth), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

/// Widget de description expandable.
///
/// Repliee : 3 lignes (max-height ~68px) terminees par un fondu vertical de
/// 22px, suivi du lien "Voir plus". Depliee : texte integral + "Voir moins".
/// Clic sur le texte ou le lien pour basculer.
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
            // Repliee : 3 lignes avec un fondu de 22px en bas (ShaderMask qui
            // rend le bas du texte transparent), indiquant qu'il reste du
            // contenu sans couper net.
            firstChild: ShaderMask(
              shaderCallback: (rect) => LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [
                  1 - (22 / rect.height).clamp(0.0, 1.0),
                  1.0,
                ],
                colors: const [Colors.black, Colors.transparent],
              ).createShader(rect),
              blendMode: BlendMode.dstIn,
              child: Text(
                widget.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
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
