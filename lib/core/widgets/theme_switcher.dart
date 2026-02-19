import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'app_card.dart';

/// Widget pour changer le thème de l'app (Dark/Light/System)
/// Avec effet moderne et animations fluides
class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              Row(
                children: [
                  Icon(
                    Icons.palette_outlined,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Thème',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Options de thème
              _ThemeOption(
                title: 'Sombre',
                icon: Icons.dark_mode,
                isSelected: themeProvider.isDarkMode,
                onTap: () => themeProvider.setDarkMode(),
              ),
              const SizedBox(height: 12),

              _ThemeOption(
                title: 'Clair',
                icon: Icons.light_mode,
                isSelected: themeProvider.isLightMode,
                onTap: () => themeProvider.setLightMode(),
              ),
              const SizedBox(height: 12),

              _ThemeOption(
                title: 'Système',
                icon: Icons.brightness_auto,
                isSelected: themeProvider.isSystemMode,
                onTap: () => themeProvider.setSystemMode(),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Option de thème individuelle avec animation de sélection
class _ThemeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  // Neumorphism - Effet sélectionné
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.white.withValues(alpha: 0.8),
                    blurRadius: 8,
                    offset: const Offset(-3, -3),
                  ),
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withValues(alpha: 0.5)
                        : colorScheme.primary.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(3, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colorScheme.primary, size: 24),
          ],
        ),
      ),
    );
  }
}

/// Widget compact pour switcher rapidement entre Dark/Light
/// Pour utilisation dans AppBar ou menu
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          onPressed: () => themeProvider.toggleTheme(),
          tooltip: isDark ? 'Mode clair' : 'Mode sombre',
        );
      },
    );
  }
}
