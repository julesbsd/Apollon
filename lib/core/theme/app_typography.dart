import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typographie pour le Design System Apollon Premium
///
/// Utilise Google Fonts :
/// - Cinzel pour les titres (noblesse grecque, style temple)
/// - Raleway pour le texte courant (moderne, lisible)
/// - JetBrains Mono pour les nombres (poids, reps)
///
/// Convention de nommage:
/// - display*: Très grands titres (hero sections) - Cinzel
/// - headline*: Titres de sections - Cinzel
/// - title*: Titres de cards/widgets - Cinzel
/// - body*: Texte courant - Raleway
/// - label*: Labels de boutons, chips - Raleway
class AppTypography {
  AppTypography._(); // Private constructor

  // ==========================================
  // FAMILLE DE POLICE
  // ==========================================

  /// Police titres: Cinzel (Google Fonts) - Style grec noble
  /// - Serif élégante avec influence antique
  /// - Pour headlines, titles, et éléments premium
  static const String headingFontFamily = 'Cinzel';

  /// Police texte: Raleway (Google Fonts)
  /// - Élégante, moderne, excellente lisibilité
  /// - Support poids 100-900
  /// - Pour body text et labels
  static const String bodyFontFamily = 'Raleway';

  /// Police secondaire pour les chiffres
  /// - JetBrains Mono pour affichage poids/reps (lisibilité chiffres)
  static const String monoFontFamily = 'JetBrains Mono';

  // ==========================================
  // TEXT THEME COMPLET
  // ==========================================

  /// Génère TextTheme complet pour mode clair
  static TextTheme lightTextTheme = TextTheme(
    // DISPLAY (Hero, splash screens) - Cinzel pour impact premium
    displayLarge: GoogleFonts.cinzel(
      fontSize: 57,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.25,
      color: Colors.black87,
    ),
    displayMedium: GoogleFonts.cinzel(
      fontSize: 45,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: Colors.black87,
    ),
    displaySmall: GoogleFonts.cinzel(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: Colors.black87,
    ),

    // HEADLINE (Titres de sections majeures) - Cinzel pour noblesse
    headlineLarge: GoogleFonts.cinzel(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: Colors.black87,
    ),
    headlineMedium: GoogleFonts.cinzel(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: Colors.black87,
    ),
    headlineSmall: GoogleFonts.cinzel(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: Colors.black87,
    ),

    // TITLE (Titres de cards, app bars) - Cinzel pour identité
    titleLarge: GoogleFonts.cinzel(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: Colors.black87,
    ),
    titleMedium: GoogleFonts.cinzel(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      color: Colors.black87,
    ),
    titleSmall: GoogleFonts.cinzel(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: Colors.black87,
    ),

    // BODY (Texte courant) - Raleway pour lisibilité
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

    // LABEL (Boutons, chips, badges) - Raleway pour clarté
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
    // DISPLAY - Cinzel pour impact premium
    displayLarge: GoogleFonts.cinzel(
      fontSize: 57,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.25,
      color: Colors.white,
    ),
    displayMedium: GoogleFonts.cinzel(
      fontSize: 45,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: Colors.white,
    ),
    displaySmall: GoogleFonts.cinzel(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: Colors.white,
    ),

    // HEADLINE - Cinzel pour noblesse
    headlineLarge: GoogleFonts.cinzel(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: Colors.white,
    ),
    headlineMedium: GoogleFonts.cinzel(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: Colors.white,
    ),
    headlineSmall: GoogleFonts.cinzel(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: Colors.white,
    ),

    // TITLE - Cinzel pour identité
    titleLarge: GoogleFonts.cinzel(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: Colors.white,
    ),
    titleMedium: GoogleFonts.cinzel(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      color: Colors.white,
    ),
    titleSmall: GoogleFonts.cinzel(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: Colors.white,
    ),

    // BODY - Raleway pour lisibilité
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

    // LABEL - Raleway pour clarté
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
    return const TextStyle(fontSize: 20, fontFamily: 'Apple Color Emoji');
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
    return Theme.of(context).textTheme.titleMedium ??
        lightTextTheme.titleMedium!;
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
    return Theme.of(context).textTheme.labelMedium ??
        lightTextTheme.labelMedium!;
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
