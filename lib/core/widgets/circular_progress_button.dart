import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Widget personnalisé avec arc de progression circulaire
/// Affiche un bouton central avec un arc qui se remplit selon le temps
/// Enhanced US-4.1: Arc de cercle progressif (0-60 min = 0-100%)
class CircularProgressButton extends StatelessWidget {
  final String text;
  final String? subtitle;
  final double progress; // 0.0 à 1.0 (0% à 100%)
  final VoidCallback? onPressed;
  final IconData icon;
  final bool isActive;

  const CircularProgressButton({
    super.key,
    required this.text,
    this.subtitle,
    required this.progress,
    this.onPressed,
    this.icon = Icons.add_circle_outline,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size.width * 0.65; // 65% de la largeur

    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Arc de progression en arrière-plan
            CustomPaint(
              size: Size(size, size),
              painter: _CircularProgressPainter(
                progress: progress,
                backgroundColor: colorScheme.surfaceVariant,
                progressColor: colorScheme.primary,
                strokeWidth: 14,
              ),
            ),
            
            // Container central avec le contenu
            Container(
              width: size * 0.75,
              height: size * 0.75,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.15),
                  width: 3,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPressed,
                  borderRadius: BorderRadius.circular(size),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 64,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          subtitle!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            
            // Indicateur de progression (petit badge en haut)
            if (isActive && progress > 0)
              Positioned(
                top: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// CustomPainter pour dessiner l'arc de progression
class _CircularProgressPainter extends CustomPainter {
  final double progress; // 0.0 à 1.0
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    // Paint pour le background (cercle complet gris)
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    // Paint pour la progression (arc coloré)
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    // Dessiner le cercle de fond complet
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Dessiner l'arc de progression
    // Commence en haut (90° dans le sens horaire = -π/2 radians)
    // Va jusqu'à progress * 2π (tour complet)
    if (progress > 0) {
      final startAngle = -math.pi / 2; // Commence en haut
      final sweepAngle = 2 * math.pi * progress; // Angle proportionnel au progrès
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.backgroundColor != backgroundColor ||
           oldDelegate.progressColor != progressColor ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}
