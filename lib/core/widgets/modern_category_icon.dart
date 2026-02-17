import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// ModernCategoryIcon - Icône catégorie simplifiée avec label
///
/// Composant épuré pour afficher des catégories/types avec icône et label.
/// Style moderne avec container arrondi et états actif/inactif.
///
/// Features:
/// - Container 64x64 avec icon 28x28
/// - Border radius 16px
/// - État actif (bleu) / inactif (gris)
/// - Label en dessous (12px Medium)
/// - Transition animée 200ms
/// - Touch feedback
///
/// Usage:
/// ```dart
/// ModernCategoryIcon(
///   icon: Icons.fitness_center,
///   label: 'Yoga',
///   isActive: selectedCategory == 'yoga',
///   onTap: () => setState(() => selectedCategory = 'yoga'),
/// )
/// ```
class ModernCategoryIcon extends StatelessWidget {
  /// Icône Material ou custom
  final IconData icon;

  /// Label affiché sous l'icône
  final String label;

  /// État actif/inactif
  final bool isActive;

  /// Callback au tap
  final VoidCallback? onTap;

  /// Taille du container (défaut: 64)
  final double size;

  /// Taille de l'icône (défaut: 28)
  final double iconSize;

  /// Couleur active (défaut: primaryBlue)
  final Color? activeColor;

  /// Couleur inactive background (défaut: neutralGray100)
  final Color? inactiveColor;

  const ModernCategoryIcon({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
    this.size = 64,
    this.iconSize = 28,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isActive
        ? (activeColor ?? AppTheme.primaryBlue)
        : (inactiveColor ?? (isDark ? AppTheme.darkSurfaceVariant : AppTheme.neutralGray100));

    final iconColor = isActive
        ? Colors.white
        : (isDark ? AppTheme.darkOnSurface : AppTheme.neutralGray800);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Container icône
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              boxShadow: [
                // Neumorphism - Ombre claire en haut à gauche
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.white.withOpacity(0.9),
                  blurRadius: 8,
                  offset: const Offset(-4, -4),
                ),
                // Neumorphism - Ombre sombre en bas à droite
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withOpacity(0.6)
                      : bgColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(4, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor,
            ),
          ),

          const SizedBox(height: 8),

          // Label
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: isDark ? AppTheme.darkOnSurface : AppTheme.neutralGray800,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
