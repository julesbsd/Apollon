import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Décorations et styles pour effets Liquid Glass (glassmorphism)
///
/// Caractéristiques du style Liquid Glass:
/// - Arrondis prononcés (16-32px)
/// - Effets de flou (backdrop filter)
/// - Transparence (60-90%)
/// - Borders subtiles avec opacité
/// - Ombres douces
class AppDecorations {
  AppDecorations._(); // Private constructor

  // ==========================================
  // BORDER RADIUS
  // ==========================================

  /// Border radius par défaut
  static const BorderRadius defaultRadius = BorderRadius.all(
    Radius.circular(16),
  );

  /// Petits arrondis (chips, badges)
  static const BorderRadius smallRadius = BorderRadius.all(Radius.circular(8));

  /// Moyens arrondis (cards, buttons)
  static const BorderRadius mediumRadius = BorderRadius.all(
    Radius.circular(16),
  );

  /// Grands arrondis (modals, sheets)
  static const BorderRadius largeRadius = BorderRadius.all(Radius.circular(24));

  /// Très grands arrondis (effet pill)
  static const BorderRadius extraLargeRadius = BorderRadius.all(
    Radius.circular(32),
  );

  /// Radius circulaire complet (avatars, FAB)
  static const BorderRadius circularRadius = BorderRadius.all(
    Radius.circular(999),
  );

  // Aliases pour compatibilité
  static const BorderRadius borderRadiusMedium = mediumRadius;
  static const BorderRadius borderRadiusLarge = largeRadius;

  // ==========================================
  // OMBRES (Box Shadows)
  // ==========================================

  /// Ombre légère (hover, cards surélevées)
  static List<BoxShadow> get lightShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  /// Ombre moyenne (cards, modals)
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.10),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  /// Ombre forte (dialogs, FAB)
  static List<BoxShadow> get strongShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 30,
      offset: const Offset(0, 8),
    ),
  ];

  /// Ombre de glow (accent, primary actions)
  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.4),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  // Alias pour compatibilité
  static List<BoxShadow> shadowGlow(
    BuildContext context, {
    required Color color,
  }) {
    return glowShadow(color);
  }

  // Méthodes avec context (pour compatibilité avec widgets)
  static List<BoxShadow>? shadowLight(BuildContext context) {
    return lightShadow;
  }

  static List<BoxShadow>? shadowMedium(BuildContext context) {
    return mediumShadow;
  }

  static List<BoxShadow>? shadowStrong(BuildContext context) {
    return strongShadow;
  }

  // ==========================================
  // GLASS DECORATIONS (Glassmorphism)
  // ==========================================

  /// Décoration glassmorphism LIGHT mode
  static BoxDecoration glassLight({
    Color? backgroundColor,
    BorderRadius? borderRadius,
    Border? border,
  }) {
    return BoxDecoration(
      color: (backgroundColor ?? AppColors.glassLightSurface).withOpacity(
        AppColors.glassOpacityLight,
      ),
      borderRadius: borderRadius ?? defaultRadius,
      border:
          border ??
          Border.all(
            color: Colors.white.withOpacity(AppColors.glassBorderOpacity),
            width: 1.5,
          ),
      boxShadow: mediumShadow,
    );
  }

  /// Décoration glassmorphism DARK mode
  static BoxDecoration glassDark({
    Color? backgroundColor,
    BorderRadius? borderRadius,
    Border? border,
  }) {
    return BoxDecoration(
      color: (backgroundColor ?? AppColors.glassDarkSurface).withOpacity(
        AppColors.glassOpacityDark,
      ),
      borderRadius: borderRadius ?? defaultRadius,
      border:
          border ??
          Border.all(
            color: Colors.white.withOpacity(AppColors.glassBorderOpacity),
            width: 1.5,
          ),
      boxShadow: mediumShadow,
    );
  }

  /// Retourne la décoration glass adaptée au mode
  static BoxDecoration glass(
    BuildContext context, {
    Color? backgroundColor,
    BorderRadius? borderRadius,
    Border? border,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? glassDark(
            backgroundColor: backgroundColor,
            borderRadius: borderRadius,
            border: border,
          )
        : glassLight(
            backgroundColor: backgroundColor,
            borderRadius: borderRadius,
            border: border,
          );
  }

  // ==========================================
  // CARD DECORATIONS
  // ==========================================

  /// Card standard (avec ombre)
  static BoxDecoration card(
    BuildContext context, {
    BorderRadius? borderRadius,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: borderRadius ?? mediumRadius,
      boxShadow: isDark ? lightShadow : mediumShadow,
    );
  }

  /// Card avec effet hover (interactive)
  static BoxDecoration cardHover(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: mediumRadius,
      boxShadow: strongShadow,
    );
  }

  // ==========================================
  // INPUT DECORATIONS
  // ==========================================

  /// InputDecoration pour TextField glassmorphism
  static InputDecoration glassInput({
    required BuildContext context,
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark
          ? AppColors.glassDarkSurface.withOpacity(0.5)
          : AppColors.glassLightSurface.withOpacity(0.8),
      border: OutlineInputBorder(
        borderRadius: mediumRadius,
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: mediumRadius,
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: mediumRadius,
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: mediumRadius,
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.error,
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  // ==========================================
  // BUTTON DECORATIONS
  // ==========================================

  /// Décoration pour bouton glassmorphism
  static BoxDecoration glassButton(
    BuildContext context, {
    Color? color,
    BorderRadius? borderRadius,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = color ?? Theme.of(context).colorScheme.primary;

    return BoxDecoration(
      color: buttonColor.withOpacity(isDark ? 0.7 : 0.8),
      borderRadius: borderRadius ?? mediumRadius,
      border: Border.all(color: buttonColor.withOpacity(0.5), width: 1.5),
      boxShadow: glowShadow(buttonColor),
    );
  }

  // ==========================================
  // GRADIENT DECORATIONS
  // ==========================================

  /// Gradient linéaire pour arrière-plans
  static BoxDecoration linearGradient(
    BuildContext context, {
    required List<Color> colors,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(colors: colors, begin: begin, end: end),
      borderRadius: borderRadius,
    );
  }

  /// Gradient radial pour effets de focus
  static BoxDecoration radialGradient(
    BuildContext context, {
    required List<Color> colors,
    AlignmentGeometry center = Alignment.center,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      gradient: RadialGradient(colors: colors, center: center),
      borderRadius: borderRadius,
    );
  }

  // ==========================================
  // BACKDROP FILTER (Effet de flou)
  // ==========================================

  /// Crée un ImageFilter pour effet glassmorphism
  ///
  /// Usage:
  /// ```dart
  /// BackdropFilter(
  ///   filter: AppDecorations.blurFilter,
  ///   child: Container(...),
  /// )
  /// ```
  static ImageFilter get blurFilter =>
      ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0);

  /// Blur fort (modals, overlays)
  static ImageFilter get strongBlurFilter =>
      ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0);

  /// Blur léger (cards, surfaces)
  static ImageFilter get lightBlurFilter =>
      ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0);

  // ==========================================
  // DIVIDERS
  // ==========================================

  /// Divider glassmorphism avec gradient
  static Widget glassDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            isDark
                ? Colors.white.withOpacity(0.2)
                : Colors.black.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SPACING & PADDING
  // ==========================================

  /// Padding par défaut pour containers
  static const EdgeInsets defaultPadding = EdgeInsets.all(16);

  /// Padding petit
  static const EdgeInsets smallPadding = EdgeInsets.all(8);

  /// Padding moyen
  static const EdgeInsets mediumPadding = EdgeInsets.all(16);

  /// Padding grand
  static const EdgeInsets largePadding = EdgeInsets.all(24);

  /// Padding très grand
  static const EdgeInsets extraLargePadding = EdgeInsets.all(32);

  /// Padding horizontal
  static const EdgeInsets horizontalPadding = EdgeInsets.symmetric(
    horizontal: 16,
  );

  /// Padding vertical
  static const EdgeInsets verticalPadding = EdgeInsets.symmetric(vertical: 16);

  // ==========================================
  // SPACING CONSTANTS
  // ==========================================

  static const double spaceXS = 4;
  static const double spaceS = 8;
  static const double spaceM = 16;
  static const double spaceL = 24;
  static const double spaceXL = 32;
  static const double spaceXXL = 48;
}
