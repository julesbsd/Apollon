import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typographie pour le Design System Apollon
/// 
/// Utilise Google Fonts (Raleway) pour une typographie moderne et lisible.
/// Définit tous les styles de texte utilisés dans l'application.
/// 
/// Convention de nommage:
/// - display*: Très grands titres (hero sections)
/// - headline*: Titres de sections
/// - title*: Titres de cards/widgets
/// - body*: Texte courant
/// - label*: Labels de boutons, chips
class AppTypography {
  AppTypography._(); // Private constructor

  // ==========================================
  // FAMILLE DE POLICE
  // ==========================================

  /// Police principale: Raleway (Google Fonts)
  /// - Élégante, moderne, excellente lisibilité
  /// - Support poids 100-900
  static const String primaryFontFamily = 'Raleway';

  /// Police secondaire pour les chiffres (optionnel)
  /// - Jetbrains Mono pour affichage poids/reps (lisibilité chiffres)
  static const String monoFontFamily = 'JetBrains Mono';

  // ==========================================
  // TEXT THEME COMPLET
  // ==========================================

  /// Génère TextTheme complet pour mode clair
  static TextTheme lightTextTheme = TextTheme(
    // DISPLAY (Hero, splash screens)
    displayLarge: GoogleFonts.raleway(
      fontSize: 57,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.25,
      color: Colors.black87,
    ),
    displayMedium: GoogleFonts.raleway(
      fontSize: 45,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: Colors.black87,
    ),
    displaySmall: GoogleFonts.raleway(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: Colors.black87,
    ),

    // HEADLINE (Titres de sections majeures)
    headlineLarge: GoogleFonts.raleway(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: Colors.black87,
    ),
    headlineMedium: GoogleFonts.raleway(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: Colors.black87,
    ),
    headlineSmall: GoogleFonts.raleway(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: Colors.black87,
    ),

    // TITLE (Titres de cards, app bars)
    titleLarge: GoogleFonts.raleway(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: Colors.black87,
    ),
    titleMedium: GoogleFonts.raleway(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      color: Colors.black87,
    ),
    titleSmall: GoogleFonts.raleway(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: Colors.black87,
    ),

    // BODY (Texte courant)
    bodyLarge: GoogleFonts.raleway(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: Colors.black87,
    ),
    bodyMedium: GoogleFonts.raleway(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: Colors.black87,
    ),
    bodySmall: GoogleFonts.raleway(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: Colors.black54,
    ),

    // LABEL (Boutons, chips, badges)
    labelLarge: GoogleFonts.raleway(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: Colors.black87,
    ),
    labelMedium: GoogleFonts.raleway(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: Colors.black87,
    ),
    labelSmall: GoogleFonts.raleway(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: Colors.black87,
    ),
  );

  /// Génère TextTheme complet pour mode sombre
  static TextTheme darkTextTheme = TextTheme(
    // DISPLAY
    displayLarge: GoogleFonts.raleway(
      fontSize: 57,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.25,
      color: Colors.white,
    ),
    displayMedium: GoogleFonts.raleway(
      fontSize: 45,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: Colors.white,
    ),
    displaySmall: GoogleFonts.raleway(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: Colors.white,
    ),

    // HEADLINE
    headlineLarge: GoogleFonts.raleway(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: Colors.white,
    ),
    headlineMedium: GoogleFonts.raleway(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: Colors.white,
    ),
    headlineSmall: GoogleFonts.raleway(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: Colors.white,
    ),

    // TITLE
    titleLarge: GoogleFonts.raleway(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: Colors.white,
    ),
    titleMedium: GoogleFonts.raleway(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      color: Colors.white,
    ),
    titleSmall: GoogleFonts.raleway(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: Colors.white,
    ),

    // BODY
    bodyLarge: GoogleFonts.raleway(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: Colors.white,
    ),
    bodyMedium: GoogleFonts.raleway(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: Colors.white,
    ),
    bodySmall: GoogleFonts.raleway(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: Colors.white70,
    ),

    // LABEL
    labelLarge: GoogleFonts.raleway(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: Colors.white,
    ),
    labelMedium: GoogleFonts.raleway(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: Colors.white,
    ),
    labelSmall: GoogleFonts.raleway(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: Colors.white,
    ),
  );

  // ==========================================
  // STYLES PERSONNALISÉS (Non Material 3)
  // ==========================================

  /// Style pour affichage de chiffres (poids, reps)
  static TextStyle numberStyle(BuildContext context, {bool isDark = false}) {
    return GoogleFonts.jetBrainsMono(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: isDark ? Colors.white : Colors.black87,
    );
  }

  /// Style pour affichage de grands chiffres (stats, dashboard)
  static TextStyle bigNumberStyle(BuildContext context, {bool isDark = false}) {
    return GoogleFonts.jetBrainsMono(
      fontSize: 48,
      fontWeight: FontWeight.w800,
      letterSpacing: -2,
      color: isDark ? Colors.white : Colors.black87,
    );
  }

  /// Style pour emojis (taille uniforme)
  static TextStyle emojiStyle(BuildContext context) {
    return const TextStyle(
      fontSize: 32,
      fontFamily: 'Apple Color Emoji', // Utilise police système pour emojis
    );
  }

  /// Style pour emojis petits (chips, badges)
  static TextStyle emojiSmallStyle(BuildContext context) {
    return const TextStyle(
      fontSize: 20,
      fontFamily: 'Apple Color Emoji',
    );
  }

  // ==========================================
  // HELPERS
  // ==========================================

  /// Retourne le TextTheme approprié selon luminosité
  static TextTheme getTextTheme(Brightness brightness) {
    return brightness == Brightness.dark ? darkTextTheme : lightTextTheme;
  }

  /// Méthodes avec context pour accéder aux styles du thème
  static TextStyle titleLarge(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge ?? lightTextTheme.titleLarge!;
  }

  static TextStyle titleMedium(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium ?? lightTextTheme.titleMedium!;
  }

  static TextStyle titleSmall(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall ?? lightTextTheme.titleSmall!;
  }

  static TextStyle bodyLarge(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge ?? lightTextTheme.bodyLarge!;
  }

  static TextStyle bodyMedium(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium ?? lightTextTheme.bodyMedium!;
  }

  static TextStyle bodySmall(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall ?? lightTextTheme.bodySmall!;
  }

  static TextStyle labelLarge(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge ?? lightTextTheme.labelLarge!;
  }

  static TextStyle labelMedium(BuildContext context) {
    return Theme.of(context).textTheme.labelMedium ?? lightTextTheme.labelMedium!;
  }

  static TextStyle labelSmall(BuildContext context) {
    return Theme.of(context).textTheme.labelSmall ?? lightTextTheme.labelSmall!;
  }

  /// Font weight mapping sémantique
  static const FontWeight thin = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
}
