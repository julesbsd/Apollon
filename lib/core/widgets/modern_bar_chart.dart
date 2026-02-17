import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// SimpleBarChart - Graphique en barres minimaliste
///
/// Composant épuré pour afficher un graphique en barres verticales simple.
/// Style moderne sans grille ni axes complexes.
///
/// Features:
/// - Barres verticales normalisées (0.0 à 1.0)
/// - Labels en dessous
/// - Index actif avec couleur distincte
/// - Hauteur et largeur configurables
/// - Design minimaliste
///
/// Usage:
/// ```dart
/// SimpleBarChart(
///   values: [0.3, 0.4, 0.5, 1.0, 0.6, 0.7, 0.8],
///   labels: ['S', 'M', 'T', 'W', 'T', 'F', 'S'],
///   activeIndex: 3,  // Mercredi actif
///   height: 120,
///   barWidth: 28,
///   activeColor: Colors.blue,
///   inactiveColor: Colors.grey,
/// )
/// ```
class SimpleBarChart extends StatelessWidget {
  /// Valeurs normalisées (0.0 à 1.0)
  final List<double> values;

  /// Labels affichés sous les barres
  final List<String> labels;

  /// Index de la barre active (-1 = aucune)
  final int? activeIndex;

  /// Couleur de la barre active (défaut: primaryBlue)
  final Color? activeColor;

  /// Couleur des barres inactives (défaut: neutralGray200)
  final Color? inactiveColor;

  /// Hauteur du graphique
  final double height;

  /// Largeur d'une barre
  final double barWidth;

  /// Border radius des barres
  final double barBorderRadius;

  const SimpleBarChart({
    super.key,
    required this.values,
    required this.labels,
    this.activeIndex,
    this.activeColor,
    this.inactiveColor,
    this.height = 150,
    this.barWidth = 24,
    this.barBorderRadius = 6,
  }) : assert(values.length == labels.length, 'Values and labels must have the same length');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final actualActiveColor = activeColor ?? AppTheme.primaryBlue;
    final actualInactiveColor = inactiveColor ?? 
        (isDark ? AppTheme.darkSurfaceVariant : AppTheme.neutralGray200);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Barres
        SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(values.length, (index) {
              final isActive = activeIndex == index;
              final barColor = isActive ? actualActiveColor : actualInactiveColor;
              final normalizedValue = values[index].clamp(0.0, 1.0);
              final barHeight = height * normalizedValue;

              return Container(
                width: barWidth,
                height: barHeight < 4 ? 4 : barHeight, // Minimum 4px pour visibilité
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(barBorderRadius),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 8),

        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(labels.length, (index) {
            final isActive = activeIndex == index;
            return SizedBox(
              width: barWidth,
              child: Text(
                labels[index],
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isActive
                      ? (isDark ? AppTheme.darkOnBackground : AppTheme.neutralGray900)
                      : (isDark 
                          ? AppTheme.darkOnSurface.withOpacity(0.6) 
                          : AppTheme.neutralGray800.withOpacity(0.6)),
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }),
        ),
      ],
    );
  }
}
