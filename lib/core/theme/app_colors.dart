import 'package:flutter/material.dart';

/// Palette de couleurs pour le Design System Apollon
///
/// Génère automatiquement une palette complète à partir de couleurs de base,
/// en utilisant ColorScheme.fromSeed() de Material 3 pour cohérence.
///
/// Supporte:
/// - Mode sombre (dark)
/// - Mode clair (light)
/// - Couleurs glassmorphism avec opacité
class AppColors {
  AppColors._(); // Private constructor pour empêcher instanciation

  // ==========================================
  // COULEURS DE BASE
  // ==========================================

  /// Couleur primaire - Bleu Égée pour thème grec premium
  static const Color primarySeed = Color(0xFF1E88E5); // Bleu Égée
  static const Color primaryLight = Color(0xFF64B5F6); // Bleu clair
  static const Color primaryDark = Color(0xFF1565C0); // Bleu profond

  /// Couleur secondaire - Orange accent pour actions
  static const Color secondarySeed = Color(0xFFFF6B35); // Orange énergique

  // ==========================================
  // COULEURS PREMIUM APOLLON
  // ==========================================

  /// Accent doré - Pour highlights et éléments premium
  static const Color accentGold = Color(0xFFFFD700); // Or pur
  static const Color accentGoldLight = Color(0xFFFFE57F); // Or clair
  static const Color accentGoldDark = Color(0xFFFFA000); // Or brûlé

  /// Couleurs marbre - Pour backgrounds premium
  static const Color marbleWhite = Color(0xFFF8F9FA); // Marbre blanc
  static const Color marbleGray = Color(0xFFECEFF1); // Marbre gris
  static const Color marbleDark = Color(
    0xFF263238,
  ); // Marbre sombre (dark mode)

  /// Couleurs glassmorphism premium
  static Color glassWhite = const Color(0xFFFFFFFF).withOpacity(0.1);
  static Color glassBorder = const Color(0xFFFFFFFF).withOpacity(0.2);
  static Color glassBlur = const Color(0xFFFFFFFF).withOpacity(0.05);

  /// Couleur d'erreur - Rouge pour alertes
  static const Color errorSeed = Color(0xFFDC3545);

  /// Couleur de succès - Vert pour validations
  static const Color successSeed = Color(0xFF28A745);

  // ==========================================
  // COLOR SCHEMES (Material 3)
  // ==========================================

  /// Schéma de couleurs MODE CLAIR
  static final ColorScheme lightColorScheme = ColorScheme.fromSeed(
    seedColor: primarySeed,
    brightness: Brightness.light,
    secondary: secondarySeed,
    error: errorSeed,
  );

  /// Schéma de couleurs MODE SOMBRE
  static final ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: primarySeed,
    brightness: Brightness.dark,
    secondary: secondarySeed,
    error: errorSeed,
  );

  // ==========================================
  // COULEURS GLASSMORPHISM
  // ==========================================

  // Mode clair - Effets de verre
  static const Color glassLightBackground = Color(
    0xFFF5F5F7,
  ); // Gris très clair
  static const Color glassLightSurface = Color(0xFFFFFFFF); // Blanc pur
  static const Color glassLightOverlay = Color(0x1A000000); // Noir 10% opacité

  // Mode sombre - Effets de verre
  static const Color glassDarkBackground = Color(0xFF0A0A0D); // Noir profond
  static const Color glassDarkSurface = Color(0xFF1C1C1E); // Gris très sombre
  static const Color glassDarkOverlay = Color(0x1AFFFFFF); // Blanc 10% opacité

  // États disabled
  static const Color glassDisabledBackgroundLight = Color(
    0xFFF0F0F0,
  ); // Gris très clair
  static const Color glassDisabledBackgroundDark = Color(
    0xFF2C2C2E,
  ); // Gris sombre
  static const Color glassDisabledTextLight = Color(0xFFBDBDBD); // Gris moyen
  static const Color glassDisabledTextDark = Color(0xFF4D4D4D); // Gris foncé

  // ==========================================
  // COULEURS GRADIENT MESH (Arrière-plans animés premium)
  // ==========================================

  /// Mesh gradient mode clair - Bleu Égée + Violet + Blanc marbre
  static const List<Color> lightMeshGradient = [
    Color(0xFFE3F2FD), // Bleu très clair
    Color(0xFFF3E5F5), // Mauve très clair
    Color(0xFFF8F9FA), // Blanc marbre
    Color(0xFFE1F5FE), // Cyan très clair
  ];

  /// Mesh gradient mode sombre - Bleu nuit + Violet + Gris profond
  static const List<Color> darkMeshGradient = [
    Color(0xFF0D1B2A), // Bleu nuit profond
    Color(0xFF1B263B), // Bleu gris sombre
    Color(0xFF263238), // Marbre sombre
    Color(0xFF1565C0), // Bleu Égée sombre
  ];

  /// Gradient classique mode clair (fallback)
  static const List<Color> lightGradient = [
    Color(0xFFE3F2FD), // Bleu très clair
    Color(0xFFF3E5F5), // Mauve très clair
    Color(0xFFFFF3E0), // Orange très clair
  ];

  /// Gradient classique mode sombre (fallback)
  static const List<Color> darkGradient = [
    Color(0xFF0D1B2A), // Bleu nuit
    Color(0xFF1B263B), // Bleu gris sombre
    Color(0xFF415A77), // Bleu gris
  ];

  // ==========================================
  // COULEURS SÉMANTIQUES
  // ==========================================

  /// Couleur succès (utilisée pour validations, boutons positifs)
  static const Color success = successSeed;
  static const Color successLight = Color(0xFF5CB85C);
  static const Color successDark = Color(0xFF28A745);

  /// Couleur alerte (utilisée pour avertissements)
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFD54F);
  static const Color warningDark = Color(0xFFF57C00);

  /// Couleur info (utilisée pour informations)
  static const Color info = Color(0xFF17A2B8);
  static const Color infoLight = Color(0xFF5DADE2);
  static const Color infoDark = Color(0xFF117A8B);

  // ==========================================
  // COULEURS PAR GROUPE MUSCULAIRE (Emojis mapping)
  // ==========================================

  /// Mapping des groupes musculaires avec couleurs d'accent
  static const Map<String, Color> muscleGroupColors = {
    'pectoraux': Color(0xFFE74C3C), // Rouge
    'dorsaux': Color(0xFF3498DB), // Bleu
    'epaules': Color(0xFFF39C12), // Orange
    'biceps': Color(0xFF9B59B6), // Violet
    'triceps': Color(0xFF1ABC9C), // Turquoise
    'abdominaux': Color(0xFFE67E22), // Orange foncé
    'obliques': Color(0xFFD35400), // Orange brûlé
    'lombaires': Color(0xFF8E44AD), // Violet foncé
    'quadriceps': Color(0xFF27AE60), // Vert
    'ischio_jambiers': Color(0xFF16A085), // Vert foncé
    'fessiers': Color(0xFFC0392B), // Rouge foncé
    'mollets': Color(0xFF2ECC71), // Vert clair
    'cardio': Color(0xFFE91E63), // Rose
    'avant_bras': Color(0xFF607D8B), // Gris bleu
  };

  // ==========================================
  // COULEURS PAR TYPE D'EXERCICE
  // ==========================================

  static const Map<String, Color> exerciseTypeColors = {
    'free_weights': Color(0xFF34495E), // Gris bleu foncé
    'machine': Color(0xFF7F8C8D), // Gris
    'bodyweight': Color(0xFF16A085), // Turquoise
    'cardio': Color(0xFFE74C3C), // Rouge
  };

  // ==========================================
  // OPACITÉS GLASSMORPHISM
  // ==========================================

  /// Opacité pour effets glassmorphism
  static const double glassOpacityLight = 0.70; // 70%
  static const double glassOpacityDark = 0.60; // 60%

  /// Opacité pour overlays de blur
  static const double blurOverlayOpacity = 0.10; // 10%

  /// Opacité pour borders glassmorphism
  static const double glassBorderOpacity = 0.20; // 20%

  // ==========================================
  // HELPERS
  // ==========================================

  /// Retourne la couleur d'un groupe musculaire
  static Color getMuscleGroupColor(String muscleGroup) {
    return muscleGroupColors[muscleGroup.toLowerCase()] ?? primarySeed;
  }

  /// Retourne la couleur d'un type d'exercice
  static Color getExerciseTypeColor(String type) {
    return exerciseTypeColors[type.toLowerCase()] ?? primarySeed;
  }

  /// Crée une couleur avec opacité glassmorphism
  static Color withGlassOpacity(Color color, bool isDark) {
    final opacity = isDark ? glassOpacityDark : glassOpacityLight;
    return color.withOpacity(opacity);
  }
}
