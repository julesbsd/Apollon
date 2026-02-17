import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'pulse_icon.dart';

/// FloatingGlassAppBar - AppBar premium avec glassmorphism flottante
///
/// Caractéristiques :
/// - Glassmorphism avec backdrop blur
/// - Flotte (détachée du haut de l'écran)
/// - Shadow douce
/// - Bordure gradient subtile en bas
/// - S'adapte automatiquement au mode sombre/clair
/// - Support du chronomètre workout (optionnel)
class FloatingGlassAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showTimer;
  final String? timerText;
  final VoidCallback? onTimerTap;
  final PreferredSizeWidget? bottom;

  const FloatingGlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showTimer = false,
    this.timerText,
    this.onTimerTap,
    this.bottom,
  });

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0.0) + 10.0,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              // Neumorphism - Ombre claire (highlight) en haut à gauche - LÉGER
              BoxShadow(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.white.withOpacity(0.8),
                blurRadius: 12,
                offset: const Offset(-6, -6),
              ),
              // Neumorphism - Ombre sombre en bas à droite - LÉGER
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.5)
                    : Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(6, 6),
              ),
              // Shadow principale
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.glassDarkSurface.withOpacity(0.8)
                      : AppColors.glassLightSurface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                  // Gradient subtile en bas
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      isDark
                          ? AppColors.glassDarkSurface.withOpacity(0.8)
                          : AppColors.glassLightSurface.withOpacity(0.8),
                      isDark
                          ? AppColors.glassDarkSurface.withOpacity(0.6)
                          : AppColors.glassLightSurface.withOpacity(0.6),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: kToolbarHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          // Leading
                          if (leading != null)
                            leading!
                          else
                            const SizedBox(width: 8),

                          // Title avec Cinzel
                          Expanded(
                            child: Text(
                              title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Timer (si actif)
                          if (showTimer && timerText != null) ...[
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: onTimerTap,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer
                                      .withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    PulseIcon(
                                      icon: Icons.timer_outlined,
                                      size: 16,
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                      isActive: true,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      timerText!,
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            fontFamily: 'JetBrains Mono',
                                            fontWeight: FontWeight.w600,
                                            color: theme
                                                .colorScheme
                                                .onPrimaryContainer,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          // Actions
                          if (actions != null) ...actions!,
                        ],
                      ),
                    ),
                    ?bottom,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// FloatingGlassAppBarSimple - Version simplifiée sans timer
class FloatingGlassAppBarSimple extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const FloatingGlassAppBarSimple({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8.0);

  @override
  Widget build(BuildContext context) {
    return FloatingGlassAppBar(
      title: title,
      actions: actions,
      leading: leading,
      showTimer: false,
    );
  }
}
