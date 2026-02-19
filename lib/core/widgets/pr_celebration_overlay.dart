import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../models/personal_record.dart';

/// Affiche la célébration des nouveaux Records Personnels (PR)
/// avec confettis et une popup animée.
///
/// Usage :
/// ```dart
/// await showPrCelebration(context, newPRs);
/// ```
Future<void> showPrCelebration(
  BuildContext context,
  List<PersonalRecord> newPRs,
) async {
  if (newPRs.isEmpty) return;

  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'PR Celebration',
    barrierColor: Colors.black.withValues(alpha: 0.6),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _PrCelebrationDialog(newPRs: newPRs);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.elasticOut,
      );
      return ScaleTransition(scale: curved, child: child);
    },
  );
}

class _PrCelebrationDialog extends StatefulWidget {
  final List<PersonalRecord> newPRs;

  const _PrCelebrationDialog({required this.newPRs});

  @override
  State<_PrCelebrationDialog> createState() => _PrCelebrationDialogState();
}

class _PrCelebrationDialogState extends State<_PrCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _cardAnimController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    )..play();

    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = CurvedAnimation(
      parent: _cardAnimController,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _cardAnimController,
        curve: Curves.easeOut,
      ),
    );

    _cardAnimController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _cardAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // ── Confettis depuis le haut ──────────────────────────────
        _buildConfettiCannon(
          const Alignment(0, -1),
          0,
          _confettiController,
        ),
        _buildConfettiCannon(
          const Alignment(-0.6, -1),
          -pi / 8,
          _confettiController,
        ),
        _buildConfettiCannon(
          const Alignment(0.6, -1),
          pi / 8,
          _confettiController,
        ),

        // ── Dialog principal ──────────────────────────────────────
        Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: _buildCard(context, theme, colorScheme),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfettiCannon(
    Alignment alignment,
    double blastDirection,
    ConfettiController controller,
  ) {
    return Align(
      alignment: alignment,
      child: ConfettiWidget(
        confettiController: controller,
        blastDirectionality: BlastDirectionality.explosive,
        blastDirection: pi / 2 + blastDirection,
        emissionFrequency: 0.08,
        numberOfParticles: 15,
        maxBlastForce: 40,
        minBlastForce: 15,
        gravity: 0.2,
        colors: const [
          Color(0xFFFFD700),
          Color(0xFFFF6B6B),
          Color(0xFF4ECDC4),
          Color(0xFF45B7D1),
          Color(0xFF96CEB4),
          Color(0xFFDDA0DD),
          Color(0xFFFF8C00),
        ],
        createParticlePath: _drawStar,
      ),
    );
  }

  Path _drawStar(Size size) {
    final path = Path();
    const numberOfPoints = 5;
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.4;
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < numberOfPoints * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * pi) / numberOfPoints - pi / 2;
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    path.close();
    return path;
  }

  Widget _buildCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── En-tête doré ───────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFAA00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const Text(
                    '🏆',
                    style: TextStyle(fontSize: 52),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.newPRs.length == 1
                        ? 'Nouveau Record Personnel !'
                        : '${widget.newPRs.length} Nouveaux Records !',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Liste des PRs ──────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final pr in widget.newPRs) ...[
                      _buildPrItem(pr, colorScheme, theme),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),

            // ── Bouton Fermer ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: const Color(0xFFFFAA00),
                ),
                child: const Text(
                  'Incroyable ! 💪',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrItem(
    PersonalRecord pr,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    final weightStr = pr.weight == pr.weight.truncateToDouble()
        ? '${pr.weight.toInt()} kg'
        : '${pr.weight.toStringAsFixed(1)} kg';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFAA00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pr.exerciseName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${pr.reps} rép. • $weightStr',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              weightStr,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

