import 'dart:ui';
import 'package:flutter/material.dart';

/// MarbleCard - Card premium avec texture marbre subtile + glassmorphism
///
/// Design "Temple Digital" :
/// - Fond avec texture marbre très subtile
/// - Glassmorphism overlay
/// - Bordure gradient délicate
/// - Hover/tap effects
/// - Shadow douce
class MarbleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool showBorder;
  final double? width;
  final double? height;

  const MarbleCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.showBorder = true,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final cardContent = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          // Neumorphism - Ombre claire (highlight) en haut à gauche - LÉGER
          BoxShadow(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.9),
            blurRadius: 15,
            offset: const Offset(-8, -8),
          ),
          // Neumorphism - Ombre sombre en bas à droite - LÉGER
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.6)
                : Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(8, 8),
          ),
          // Shadow principale pour la profondeur
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : colorScheme.primary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          // Shadow secondaire pour plus de profondeur en mode clair
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              // Texture marbre très subtile via gradient
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        colorScheme.surface.withOpacity(0.6),
                        colorScheme.surface.withOpacity(0.4),
                        colorScheme.surface.withOpacity(0.5),
                      ]
                    : [
                        const Color(0xFFFFFFFF), // Blanc opaque
                        const Color(0xFFF8F9FA), // Blanc cassé
                        const Color(0xFFFDFDFD), // Blanc très léger
                      ],
                stops: const [0.0, 0.5, 1.0],
              ),
              border: showBorder
                  ? Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : colorScheme.primary.withOpacity(0.12),
                      width: 1.5,
                    )
                  : null,
            ),
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
