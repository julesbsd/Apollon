import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// CircularProgressCard - Cercle de progression avec pourcentage
///
/// Composant épuré pour afficher un progress circulaire avec label centré.
/// Utilise CircularProgressIndicator customisé.
///
/// Features:
/// - Progress de 0.0 à 1.0
/// - Label principal (ex: "25%")
/// - Sous-titre optionnel (ex: "Complete")
/// - Couleur configurable
/// - Stroke width configurable
/// - Pas de Card wrapper (composant réutilisable)
///
/// Usage:
/// ```dart
/// CircularProgressCard(
///   percentage: 0.25,
///   label: '25%',
///   subtitle: 'Complete',
///   size: 100,
///   strokeWidth: 10,
///   progressColor: Colors.blue,
/// )
/// ```
class CircularProgressCard extends StatelessWidget {
  /// Pourcentage de progression (0.0 à 1.0)
  final double percentage;

  /// Label principal affiché au centre
  final String label;

  /// Sous-titre optionnel sous le label
  final String? subtitle;

  /// Taille du cercle
  final double size;

  /// Épaisseur de la barre de progression
  final double strokeWidth;

  /// Couleur de progression (défaut: primaryBlue)
  final Color? progressColor;

  /// Couleur du background (défaut: neutralGray200)
  final Color? backgroundColor;

  const CircularProgressCard({
    super.key,
    required this.percentage,
    required this.label,
    this.subtitle,
    this.size = 100,
    this.strokeWidth = 8,
    this.progressColor,
    this.backgroundColor,
  }) : assert(percentage >= 0.0 && percentage <= 1.0, 'Percentage must be between 0.0 and 1.0');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final actualProgressColor = progressColor ?? AppTheme.primaryBlue;
    final actualBackgroundColor = backgroundColor ?? 
        (isDark ? AppTheme.darkSurfaceVariant : AppTheme.neutralGray200);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // CircularProgressIndicator
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: percentage,
              strokeWidth: strokeWidth,
              backgroundColor: actualBackgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(actualProgressColor),
              strokeCap: StrokeCap.round,
            ),
          ),

          // Label centré
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.darkOnBackground : AppTheme.neutralGray900,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark 
                        ? AppTheme.darkOnSurface.withOpacity(0.7)
                        : AppTheme.neutralGray800.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
