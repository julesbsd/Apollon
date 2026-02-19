import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design System Apollon V2 - Style Moderne Épuré Bleu
/// Migration du Liquid Glass Violet vers un style moderne minimaliste
/// Inspiré par le brief DESIGN_MODERNE_SPECIFICATION.md
class AppTheme {
  // ============================================
  // COULEURS PRIMAIRES - DESIGN MODERNE BLEU
  // ============================================

  /// Bleu primaire - Modernité et confiance
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color primaryBlueDark = Color(0xFF2E5C8A);
  static const Color primaryBlueLight = Color(0xFF7BB5F0);

  /// Vert succès
  static const Color successGreen = Color(0xFF00D9A3);

  /// Rouge erreur
  static const Color errorRed = Color(0xFFE74C3C);

  /// Orange warning
  static const Color warningOrange = Color(0xFFFF9F43);

  // ============================================
  // NEUTRALS - DESIGN MODERNE
  // ============================================

  static const Color neutralGray50 = Color(0xFFFAFAFA);
  static const Color neutralGray100 = Color(0xFFF5F5F5);
  static const Color neutralGray200 = Color(0xFFEEEEEE);
  static const Color neutralGray800 = Color(0xFF2C2C3A);
  static const Color neutralGray900 = Color(0xFF1A1A24);

  // ============================================
  // DESIGN TOKENS - SPACING
  // ============================================

  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // ============================================
  // DESIGN TOKENS - BORDER RADIUS
  // ============================================

  static const double radiusS = 8.0;   // Badges
  static const double radiusM = 12.0;  // Boutons secondaires
  static const double radiusL = 16.0;  // Boutons principaux, inputs
  static const double radiusXL = 20.0; // Cards
  static const double radiusXXL = 24.0; // Bottom sheets

  // ============================================
  // COULEURS DARK MODE
  // ============================================

  static const Color darkBackground = neutralGray900;
  static const Color darkSurface = Color(0xFF1A1A24);
  static const Color darkSurfaceVariant = Color(0xFF252535);
  static const Color darkOnBackground = Color(0xFFF5F5F7);
  static const Color darkOnSurface = Color(0xFFE8E8EA);

  // ============================================
  // COULEURS LIGHT MODE
  // ============================================

  static const Color lightBackground = neutralGray50;
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = neutralGray100;
  static const Color lightOnBackground = neutralGray900;
  static const Color lightOnSurface = neutralGray800;

  // ============================================
  // TYPOGRAPHIE (Google Fonts - Inter)
  // ============================================

  static TextTheme _textTheme(Color textColor) {
    return TextTheme(
      // Display - Grands titres
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.25,
        color: textColor,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),

      // Headline - Titres de sections
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),

      // Title - Titres de cards/dialogs
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: textColor,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: textColor,
      ),

      // Body - Texte courant
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: textColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: textColor,
      ),

      // Label - Boutons, labels
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: textColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: textColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: textColor,
      ),
    );
  }

  // ============================================
  // THEME DARK MODE
  // ============================================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Palette de couleurs
      colorScheme: ColorScheme.dark(
        primary: primaryBlue,
        primaryContainer: primaryBlueDark,
        secondary: primaryBlueLight,
        secondaryContainer: primaryBlueLight.withValues(alpha: 0.2),
        tertiary: successGreen,
        tertiaryContainer: successGreen.withValues(alpha: 0.2),
        error: errorRed,
        errorContainer: errorRed.withValues(alpha: 0.2),
        surface: darkSurface,
        surfaceContainerHighest: darkSurfaceVariant,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onSurface: darkOnSurface,
        outline: Colors.white.withValues(alpha: 0.1),
      ),

      scaffoldBackgroundColor: darkBackground,

      // Typography
      textTheme: _textTheme(darkOnBackground),

      // AppBar
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: darkSurface.withValues(alpha: 0.8),
        foregroundColor: darkOnBackground,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkOnBackground,
          letterSpacing: 0.15,
        ),
        iconTheme: IconThemeData(color: darkOnBackground),
      ),

      // Card - Design moderne épuré (pas d'ombre)
      cardTheme: CardThemeData(
        elevation: 0,
        color: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXL),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusL),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          side: BorderSide(color: primaryBlue, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusL),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusL),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusL),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusL),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusL),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkOnSurface.withValues(alpha: 0.7),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkOnSurface.withValues(alpha: 0.5),
        ),
      ),

      // Dialogs
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXXL),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: darkOnBackground,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkOnSurface,
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurfaceVariant,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkOnSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
        behavior: SnackBarBehavior.floating,
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXXL)),
        ),
        elevation: 0,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.1),
        thickness: 1,
        space: 1,
      ),

      // Icon
      iconTheme: IconThemeData(color: darkOnSurface, size: 24),
    );
  }

  // ============================================
  // THEME LIGHT MODE
  // ============================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Palette de couleurs
      colorScheme: ColorScheme.light(
        primary: primaryBlue,
        primaryContainer: primaryBlueLight.withValues(alpha: 0.1),
        secondary: primaryBlueDark,
        secondaryContainer: primaryBlueDark.withValues(alpha: 0.1),
        tertiary: successGreen,
        tertiaryContainer: successGreen.withValues(alpha: 0.1),
        error: errorRed,
        errorContainer: errorRed.withValues(alpha: 0.1),
        surface: lightSurface,
        surfaceContainerHighest: lightSurfaceVariant,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onSurface: lightOnSurface,
        outline: neutralGray200,
      ),

      scaffoldBackgroundColor: lightBackground,

      // Typography
      textTheme: _textTheme(lightOnBackground),

      // AppBar
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: lightSurface.withValues(alpha: 0.8),
        foregroundColor: lightOnBackground,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightOnBackground,
          letterSpacing: 0.15,
        ),
        iconTheme: IconThemeData(color: lightOnBackground),
      ),

      // Card - Design moderne épuré (pas d'ombre)
      cardTheme: CardThemeData(
        elevation: 0,
        color: lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXL),
          side: BorderSide(color: neutralGray200, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusL),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          side: BorderSide(color: primaryBlue, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusL),
          borderSide: BorderSide(
            color: neutralGray200,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusL),
          borderSide: BorderSide(
            color: neutralGray200,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusL),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusL),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusL),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: lightOnSurface.withValues(alpha: 0.7),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: lightOnSurface.withValues(alpha: 0.5),
        ),
      ),

      // Dialogs
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXXL),
          side: BorderSide(color: neutralGray200, width: 1),
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: lightOnBackground,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: lightOnSurface,
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: neutralGray800,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
        behavior: SnackBarBehavior.floating,
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXXL)),
        ),
        elevation: 0,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: neutralGray200,
        thickness: 1,
        space: 1,
      ),

      // Icon
      iconTheme: IconThemeData(color: lightOnSurface, size: 24),
    );
  }
}
