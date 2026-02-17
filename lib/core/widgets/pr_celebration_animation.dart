import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../theme/app_theme.dart';

/// Widget d'animation de célébration pour un nouveau record personnel
class PrCelebrationAnimation extends StatefulWidget {
  final String exerciseName;
  final double weight;
  final int reps;
  final VoidCallback? onComplete;

  const PrCelebrationAnimation({
    super.key,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    this.onComplete,
  });

  @override
  State<PrCelebrationAnimation> createState() => _PrCelebrationAnimationState();
}

class _PrCelebrationAnimationState extends State<PrCelebrationAnimation>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Controller confettis
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Controller animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Animation d'échelle (zoom in + bounce)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_animationController);

    // Animation d'opacité
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Démarrer les animations
    _confettiController.play();
    _animationController.forward();

    // Auto-fermeture après 4 secondes
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        widget.onComplete?.call();
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.black54,
      child: Stack(
        children: [
          // Overlay semi-transparent cliquable
          GestureDetector(
            onTap: () {
              widget.onComplete?.call();
              Navigator.of(context).pop();
            },
            child: Container(
              color: Colors.transparent,
            ),
          ),

          // Confettis gauche
          Align(
            alignment: Alignment.topLeft,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 4, // 45 degrés
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              maxBlastForce: 30,
              minBlastForce: 15,
              gravity: 0.3,
              colors: const [
                Color(0xFFFFD700), // Or
                Color(0xFF4A90E2), // Bleu
                Color(0xFFFFAA00), // Orange
                Colors.white,
                AppTheme.successGreen,
              ],
            ),
          ),

          // Confettis droite
          Align(
            alignment: Alignment.topRight,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3 * pi / 4, // 135 degrés
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              maxBlastForce: 30,
              minBlastForce: 15,
              gravity: 0.3,
              colors: const [
                Color(0xFFFFD700),
                Color(0xFF4A90E2),
                Color(0xFFFFAA00),
                Colors.white,
                AppTheme.successGreen,
              ],
            ),
          ),

          // Message célébration centré
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.all(AppTheme.spacingXL),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFD700),
                            Color(0xFFFFAA00),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icône trophée
                          const Icon(
                            Icons.emoji_events,
                            size: 80,
                            color: Colors.white,
                          ),
                          const SizedBox(height: AppTheme.spacingM),

                          // Titre
                          Text(
                            '🎉 NOUVEAU RECORD ! 🎉',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppTheme.spacingM),

                          // Nom exercice
                          Text(
                            widget.exerciseName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppTheme.spacingS),

                          // Performance
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingM,
                              vertical: AppTheme.spacingS,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppTheme.radiusM),
                            ),
                            child: Text(
                              '${widget.weight.toStringAsFixed(1)} kg × ${widget.reps} reps',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingL),

                          // Message
                          Text(
                            'Félicitations ! 💪',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Fonction helper pour afficher l'animation
void showPrCelebration(
  BuildContext context, {
  required String exerciseName,
  required double weight,
  required int reps,
  VoidCallback? onComplete,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    builder: (context) => PrCelebrationAnimation(
      exerciseName: exerciseName,
      weight: weight,
      reps: reps,
      onComplete: onComplete,
    ),
  );
}
