import 'dart:ui';
import 'package:flutter/material.dart';

/// GlassOrbButton - Bouton premium avec glassmorphism pour action principale
///
/// Design "Temple Digital" :
/// - Glassmorphism avec backdrop blur
/// - Progression horizontale (remplissage gauche → droite sur 2H)
/// - Bordure bleu pure quand actif (pas de gold)
/// - Animation glow/pulse bleu
/// - Cinzel typography
/// - Gradient depth effect
class GlassOrbButton extends StatefulWidget {
  final String text;
  final String? subtitle;
  final double progress; // 0.0 à 1.0
  final VoidCallback? onPressed;
  final IconData icon;
  final bool isActive;

  const GlassOrbButton({
    super.key,
    required this.text,
    this.subtitle,
    this.progress = 0.0,
    this.onPressed,
    this.icon = Icons.add_circle_outline,
    this.isActive = false,
  });

  @override
  State<GlassOrbButton> createState() => _GlassOrbButtonState();
}

class _GlassOrbButtonState extends State<GlassOrbButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GlassOrbButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final pulseValue = _pulseAnimation.value;

        return Container(
          // height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
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
                    : colorScheme.primary.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(8, 8),
              ),
              // Shadow principale pour la profondeur
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.4)
                    : colorScheme.primary.withOpacity(0.2),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
              // Shadow secondaire pour plus de profondeur en mode clair
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              // Glow animé si actif
              if (widget.isActive)
                BoxShadow(
                  color: colorScheme.primary.withOpacity(
                    0.2 + pulseValue * 0.1,
                  ),
                  blurRadius: 24 + pulseValue * 8,
                  spreadRadius: 0 + pulseValue * 2,
                ),
            ],
          ),
          child: Stack(
            children: [
              // Glassmorphism container
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Stack(
                    children: [
                      // Barre de progression horizontale (remplissage de gauche à droite)
                      if (widget.progress > 0)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: widget.progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32),
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: widget.isActive
                                          ? [
                                              colorScheme.primary.withOpacity(
                                                0.5,
                                              ),
                                              colorScheme.primary.withOpacity(
                                                0.3,
                                              ),
                                              colorScheme.primaryContainer
                                                  .withOpacity(0.2),
                                            ]
                                          : [
                                              colorScheme.primary.withOpacity(
                                                0.3,
                                              ),
                                              colorScheme.primary.withOpacity(
                                                0.15,
                                              ),
                                            ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Container glassmorphism avec bordure bleu pure (pas de gold)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        padding: EdgeInsets.all(widget.isActive ? 2.5 : 2),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(29.5),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [
                                      colorScheme.surface.withOpacity(0.5),
                                      colorScheme.surface.withOpacity(0.25),
                                    ]
                                  : [
                                      const Color(0xFFFFFFFF),
                                      const Color(0xFFFAFAFA),
                                    ],
                            ),
                            border: widget.isActive
                                ? Border.all(
                                    color: colorScheme.primary.withOpacity(0.7),
                                    width: 2.5,
                                  )
                                : Border.all(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.15)
                                        : colorScheme.primary.withOpacity(0.2),
                                    width: 2,
                                  ),
                          ),
                          child: Stack(
                            children: [
                              // Inner shadow effect (effet 3D creux)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(29.5),
                                    gradient: RadialGradient(
                                      center: Alignment.topLeft,
                                      radius: 1.5,
                                      colors: [
                                        Colors.white.withOpacity(
                                          isDark ? 0.05 : 0.15,
                                        ),
                                        Colors.transparent,
                                        Colors.black.withOpacity(
                                          isDark ? 0.15 : 0.05,
                                        ),
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                    ),
                                  ),
                                ),
                              ),

                              // Contenu principal
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: widget.onPressed,
                                  borderRadius: BorderRadius.circular(29.5),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    child: widget.isActive
                                        ? _buildActiveLayout(
                                            theme,
                                            colorScheme,
                                            isDark,
                                          )
                                        : _buildInactiveLayout(
                                            theme,
                                            colorScheme,
                                            isDark,
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Layout pour séance inactive (avec icône)
  Widget _buildInactiveLayout(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Row(
      children: [
        // Icône + avec background circulaire
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withOpacity(0.25),
                colorScheme.primary.withOpacity(0.15),
              ],
            ),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.3),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.add_circle_outline,
            size: 32,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 20),

        // Texte à droite uniquement
        Expanded(
          child: Text(
            'Commencer une nouvelle séance',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Layout pour séance active (sans icône, avec cercle de progression)
  Widget _buildActiveLayout(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Row(
      children: [
        // Texte à gauche
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Titre en haut (réduit)
              Text(
                widget.text,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 6),
                // Sous-titre en dessous
                Text(
                  widget.subtitle!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontFamily: 'JetBrains Mono',
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(width: 20),

        // Cercle de progression à droite (taille fixe)
        SizedBox(
          width: 72,
          height: 72,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // CircularProgressIndicator
              SizedBox(
                width: 72,
                height: 72,
                child: CircularProgressIndicator(
                  value: widget.progress,
                  strokeWidth: 5,
                  backgroundColor: colorScheme.primary.withOpacity(0.2),
                  color: colorScheme.primary,
                ),
              ),
              // Pourcentage au centre
              Text(
                '${(widget.progress * 100).toInt()}%',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: 'JetBrains Mono',
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
