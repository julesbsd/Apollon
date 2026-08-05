import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design System Apollon - "Marbre & Lumiere"
/// Direction artistique finale produite par Claude design (session du
/// 2026-08-05) a partir du brief docs/DIRECTION-ARTISTIQUE-BRIEF.md et de la
/// Phase 1 "Temple Digital" (_byan-output/bmb-creations/DA-Premium-Apollon.md).
/// Remplace le "Design Moderne Epure Bleu" V2 (seed 0xFF4A90E2, Inter partout).
///
/// Position sur les trois frictions du brief (voir _byan-output/design-directions/) :
/// - couleur d'Apollon : plus un bleu generique, un couple matiere (marbre
///   chaud clair / nuit minerale sombre) + un filet d'or. Le bleu redevient
///   une couleur d'ACTION (boutons, liens, selection), plus l'identite.
/// - typographie : Cinzel retrograde au registre identitaire (jamais sous
///   20px, jamais en corps de texte) ; Manrope remplace Inter partout
///   ailleurs ; JetBrains Mono garde le monopole des chiffres.
/// - moment signature : "Le Rayon" (RayonSweep), un reflet lumineux qui
///   traverse une surface UNE SEULE FOIS (jamais en boucle).
class AppTheme {
  // ============================================
  // COULEURS D'ACTION (bleu) - constantes bare
  // ============================================
  // NB architecture : ces constantes bare sont consommees SANS branchement
  // sur la luminosite par ~14 fichiers preexistants (graphiques de
  // statistiques, calendrier d'assiduite, home page) qui ne font pas partie
  // du perimetre "couche visuelle" de cette DA (portee trop large pour ce
  // lot). Elles recoivent donc la valeur SOMBRE du design (plus saturee,
  // plus lisible sur les deux types de fond) pour rester correctes sur les
  // deux themes a defaut d'etre optimales sur les deux. Le ColorScheme
  // Material (boutons, champs, etc.) et les composants entierement reecrits
  // dans ce lot (RayonSweep, PictogramPlinth, EmptyStateCard, CriticalCta,
  // FloatingWorkoutTimer, PRCelebrationOverlay) utilisent en plus les
  // variantes `light*` ci-dessous pour un rendu fidele en mode clair.
  static const Color primaryBlue = Color(0xFF4E92CF);
  static const Color primaryBlueDark = Color(0xFF255F97);
  static const Color primaryBlueLight = Color(0xFF7FB6E8);

  /// Variantes mode clair (couple avec [primaryBlue]/[primaryBlueDark]/
  /// [primaryBlueLight] ci-dessus qui portent la valeur sombre).
  static const Color lightPrimaryBlue = Color(0xFF17568C);
  static const Color lightPrimaryBlueDark = Color(0xFF0E3A62);
  static const Color lightPrimaryBlueLight = Color(0xFF4E92CF);

  // ============================================
  // COULEURS SEMANTIQUES
  // ============================================

  static const Color successGreen = Color(0xFF35D9A6);
  static const Color lightSuccessGreen = Color(0xFF0E7A5F);

  static const Color errorRed = Color(0xFFFF6B5A);
  static const Color lightErrorRed = Color(0xFFC0392B);

  static const Color warningOrange = Color(0xFFF2A93B);
  static const Color lightWarningOrange = Color(0xFF9A6410);

  // ============================================
  // OR APOLLON - reserve au merite, jamais decoratif seul
  // ============================================
  // accentGold : TEXTE or (compteurs de records, libelles d'achievement).
  // accentGoldLine : traits 1-2px (serie validee, onglet actif, arete du
  // CTA critique, arc de l'orbe). accentGoldGlow : Le Rayon et le halo de
  // la celebration de record - decoratif uniquement, jamais porteur de sens.
  static const Color accentGold = Color(0xFFD9B978);
  static const Color lightAccentGold = Color(0xFF8A6A2F);

  static const Color accentGoldLine = Color(0xFFD9B978);
  static const Color lightAccentGoldLine = Color(0xFFB08D57);

  static const Color accentGoldGlowDark = Color(0xFFF0D9A2);
  static const Color accentGoldGlowLight = Color(0xFFC7A96B);

  // ============================================
  // SOCLE PICTOGRAMME - degrade ardoise (identique dans les 2 modes
  // a un ton pres : les silhouettes SVG #EEEEEE/#CCCCCC du catalogue sont
  // illisibles posees directement sur une surface claire - defaut reel
  // corrige par ce socle, cf. section 07 de la DA)
  // ============================================
  static const Color pictogramPlinthTopLight = Color(0xFF2A3949);
  static const Color pictogramPlinthTopDark = Color(0xFF26313F);
  static const Color pictogramPlinthBottomLight = Color(0xFF141B2B);
  static const Color pictogramPlinthBottomDark = Color(0xFF0F151F);

  // ============================================
  // COULEURS GROUPES MUSCULAIRES (pastilles) - cle = code muscle API
  // ============================================
  // Teinte par groupe musculaire, utilisee UNIQUEMENT pour la petite pastille
  // carree (7px, radius 2) qui identifie le groupe - jamais en aplat de fond.
  // Valeurs alignees sur muscleGroupColorsDark (bare, meme raisonnement que
  // les couleurs d'action ci-dessus : consommee sans branchement de
  // luminosite par les ecrans existants).
  static const Map<String, Color> muscleGroupColors = {
    'CHEST': Color(0xFFFF98A1), // Pectoraux
    'BACK': Color(0xFF5FC7FF), // Dorsaux
    'LATS': Color(0xFF5FC7FF),
    'RHOMBOIDS': Color(0xFF5FC7FF),
    'TRAPEZIUS': Color(0xFF82BEFF), // Trapezes
    'LEGS': Color(0xFF8ECE80), // Quadriceps
    'QUADRICEPS': Color(0xFF8ECE80),
    'HAMSTRINGS': Color(0xFF60D4A7), // Ischio-jambiers
    'GLUTES': Color(0xFFDEA0EC), // Fessiers
    'CALVES': Color(0xFF34D1E0), // Mollets
    'SHOULDERS': Color(0xFFFDA075), // Epaules
    'DELTOIDS': Color(0xFFFDA075),
    'BICEPS': Color(0xFFC7A8FF),
    'TRICEPS': Color(0xFF3ED4C5),
    'FOREARMS': Color(0xFFA3B4FF), // Avant-bras
    'ABS': Color(0xFFE9AE57), // Abdominaux
    'OBLIQUES': Color(0xFFE9AE57),
    'CORE': Color(0xFFE9AE57),
  };

  /// Couleur de pastille pour un code muscle, avec repli sur [primaryBlue]
  /// pour tout code non reference dans [muscleGroupColors].
  static Color colorForMuscleCode(String? code) {
    if (code == null) return primaryBlue;
    return muscleGroupColors[code.toUpperCase()] ?? primaryBlue;
  }

  // ============================================
  // 14 GROUPES MUSCULAIRES (nom FR) - CLAIR / SOMBRE
  // ============================================
  // Meme luminosite/chroma percus par groupe (methode du design : la teinte
  // tourne du rouge au magenta en suivant le corps de l'avant vers l'arriere,
  // du haut vers le bas). Chaque paire clair/sombre est verifiee >= 4.5:1
  // de contraste sur son fond de reference (voir test/core/theme/
  // contrast_test.dart) - critere CS-DA-04.
  static const Map<String, Color> muscleGroupColorsLight = {
    'Pectoraux': Color(0xFFAC3D4D),
    'Epaules': Color(0xFFA94608),
    'Abdominaux': Color(0xFF985800),
    'Lombaires': Color(0xFF6F6E00),
    'Quadriceps': Color(0xFF337C20),
    'Ischio-jambiers': Color(0xFF008153),
    'Triceps': Color(0xFF008274),
    'Mollets': Color(0xFF007E90),
    'Dorsaux': Color(0xFF0073AF),
    'Trapezes': Color(0xFF2369BA),
    'Avant-bras': Color(0xFF535EBB),
    'Biceps': Color(0xFF7751AF),
    'Fessiers': Color(0xFF8C489C),
    'Cardio': Color(0xFF9D4183),
  };

  static const Map<String, Color> muscleGroupColorsDark = {
    'Pectoraux': Color(0xFFFF98A1),
    'Epaules': Color(0xFFFDA075),
    'Abdominaux': Color(0xFFE9AE57),
    'Lombaires': Color(0xFFBFC15C),
    'Quadriceps': Color(0xFF8ECE80),
    'Ischio-jambiers': Color(0xFF60D4A7),
    'Triceps': Color(0xFF3ED4C5),
    'Mollets': Color(0xFF34D1E0),
    'Dorsaux': Color(0xFF5FC7FF),
    'Trapezes': Color(0xFF82BEFF),
    'Avant-bras': Color(0xFFA3B4FF),
    'Biceps': Color(0xFFC7A8FF),
    'Fessiers': Color(0xFFDEA0EC),
    'Cardio': Color(0xFFF09AD4),
  };

  // ============================================
  // DESIGN TOKENS - SPACING (inchange)
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
  // Resserres par rapport a la V2 (24px generalise) : l'arrondi genereux
  // etait le marqueur visuel du "propre generique" identifie par le brief.

  static const double radiusS = 6.0; // Badges, pastilles, puces carrees
  static const double radiusM = 10.0; // Champs de saisie, petits boutons
  static const double radiusL = 12.0; // Boutons principaux, pods de stats
  static const double radiusXL = 14.0; // Toutes les cartes, tuiles, minuteur, CTA critique
  static const double radiusXXL = 20.0; // Bottom sheets et dialogs uniquement
  static const double radiusPill = 999.0; // Puces de filtre exclusivement

  // ============================================
  // COULEURS DARK MODE - "Nuit minerale"
  // ============================================

  static const Color darkBackground = Color(0xFF0A0E16);
  static const Color darkSurface = Color(0xFF121826);
  static const Color darkSurfaceVariant = Color(0xFF1C2432);
  static const Color darkOnBackground = Color(0xFFF2EFE9);
  static const Color darkOnSurface = Color(0xFFDCD8D0);
  static const Color darkOnSurfaceMuted = Color(0xFF98A1B0);

  // ============================================
  // COULEURS LIGHT MODE - "Marbre chaud"
  // ============================================

  static const Color lightBackground = Color(0xFFF6F3EC);
  static const Color lightSurface = Color(0xFFFDFBF7);
  static const Color lightSurfaceVariant = Color(0xFFEDE8DE);
  static const Color lightOnBackground = Color(0xFF141B2B);
  static const Color lightOnSurface = Color(0xFF2B3444);
  static const Color lightOnSurfaceMuted = Color(0xFF5C6577);

  // Neutres conserves pour compatibilite des call sites existants
  // (snackbar clair sur fond fonce, etc.) - alias vers les tons du systeme.
  static const Color neutralGray50 = lightBackground;
  static const Color neutralGray100 = lightSurfaceVariant;
  static const Color neutralGray200 = Color(0x17141B2B); // = outlineSubtleLight
  static const Color neutralGray800 = lightOnSurface;
  static const Color neutralGray900 = lightOnBackground;

  /// Bordure unique de toutes les cartes (1px). Encre a 9% en clair, blanc a
  /// 8% en sombre - une seule opacite par mode, pas de degrade de bordures.
  static const Color outlineSubtleLight = Color(0x17141B2B); // #141B2B a 9%
  static const Color outlineSubtleDark = Color(0x14FFFFFF); // blanc a 8%

  // ============================================
  // OMBRES - 2 niveaux maximum, declines clair/sombre
  // ============================================
  // En sombre, l'elevation ne passe pas par l'ombre seule mais par une
  // surface plus claire + un filet de lumiere haut 1px (implemente au niveau
  // des composants via une Border top blanche a faible opacite, pas via
  // BoxShadow qui ne supporte pas l'inset en Flutter).

  static List<BoxShadow> shadowElev1(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [BoxShadow(color: Colors.black.withValues(alpha: 0.50), blurRadius: 6, offset: const Offset(0, 2))];
    }
    return [
      BoxShadow(color: lightOnBackground.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1)),
      BoxShadow(color: lightOnBackground.withValues(alpha: 0.045), blurRadius: 8, offset: const Offset(0, 2)),
    ];
  }

  static List<BoxShadow> shadowElev2(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [BoxShadow(color: Colors.black.withValues(alpha: 0.60), blurRadius: 30, offset: const Offset(0, 10))];
    }
    return [
      BoxShadow(color: lightOnBackground.withValues(alpha: 0.07), blurRadius: 4, offset: const Offset(0, 2)),
      BoxShadow(color: lightOnBackground.withValues(alpha: 0.10), blurRadius: 28, offset: const Offset(0, 12)),
    ];
  }

  // ============================================
  // GRADIENT MESH - ARRIERE-PLANS ANIMES
  // ============================================
  // Amplitude volontairement faible (marbre chaud en clair, ecart sous 8%
  // de luminosite en sombre) : le mesh ne doit jamais concurrencer le
  // contenu, seulement respirer en arriere-plan (18s de cycle).

  static const List<Color> lightMeshGradient = [
    Color(0xFFF8F5EF),
    Color(0xFFEDF0F4),
    Color(0xFFF2ECE0),
    Color(0xFFFBF9F5),
  ];

  static const List<Color> darkMeshGradient = [
    Color(0xFF0A0E16),
    Color(0xFF101A2A),
    Color(0xFF16202E),
    Color(0xFF0C1119),
  ];

  // ============================================
  // TYPOGRAPHIE - Manrope (interface) / Cinzel (identite) / JetBrains Mono (chiffres)
  // ============================================
  // Regle dure du design : Cinzel est INTERDIT sous 20px et en corps de
  // texte - il n'apparait donc jamais dans ce TextTheme Material generique
  // (roles display/headline/title/body/label), uniquement via les helpers
  // nommes ci-dessous, appeles explicitement par les ecrans qui portent
  // l'identite (wordmark, titre d'ecran, nom d'exercice).

  static TextTheme _textTheme(Color textColor) {
    return TextTheme(
      displayLarge: GoogleFonts.manrope(fontSize: 57, fontWeight: FontWeight.w800, letterSpacing: -0.25, color: textColor),
      displayMedium: GoogleFonts.manrope(fontSize: 45, fontWeight: FontWeight.w800, color: textColor),
      displaySmall: GoogleFonts.manrope(fontSize: 36, fontWeight: FontWeight.w700, color: textColor),
      headlineLarge: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w700, color: textColor),
      headlineMedium: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w700, color: textColor),
      headlineSmall: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w600, color: textColor),
      titleLarge: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w700, color: textColor),
      titleMedium: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15, color: textColor),
      titleSmall: GoogleFonts.manrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: textColor),
      bodyLarge: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: textColor),
      bodyMedium: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w500, height: 1.55, color: textColor),
      bodySmall: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4, color: textColor),
      labelLarge: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: textColor),
      labelMedium: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: textColor),
      labelSmall: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.76, color: textColor),
    );
  }

  /// Titre d'ecran (nom d'exercice, titre de section principale). Cinzel,
  /// 27px, w500, hauteur de ligne 1.12. Usage : quand un titre porte
  /// l'identite du contenu, pas la marque elle-meme (voir [wordmark]).
  static TextStyle screenTitle(Color color) =>
      GoogleFonts.cinzel(fontSize: 27, fontWeight: FontWeight.w500, height: 1.12, color: color);

  /// Wordmark "APOLLON". Cinzel, w600, capitales, filet d'or associe -
  /// SEULE exception au plancher de 20px car il s'agit de la marque
  /// elle-meme. 17px/+0.30em par defaut (bandeaux compacts) ; le login
  /// utilise une variante plus grande (30px/+0.28em, spec maquette) via les
  /// parametres optionnels plutot qu'un second helper duplique.
  static TextStyle wordmark(Color color, {double fontSize = 17, double trackingEm = 0.30}) =>
      GoogleFonts.cinzel(fontSize: fontSize, fontWeight: FontWeight.w600, letterSpacing: fontSize * trackingEm, color: color);

  /// Glyphe du symbole de marque (le "A" barre du filet d'or, ecran de
  /// login) - Cinzel 106px w600, hauteur de ligne resserree a 1 pour ne pas
  /// decaler le filet horizontal positionne par-dessus.
  static TextStyle markGlyph(Color color) =>
      GoogleFonts.cinzel(fontSize: 106, fontWeight: FontWeight.w600, height: 1, color: color);

  /// Chiffres de series - sommet de la hierarchie visuelle (critere
  /// CS-DA-02). JAMAIS pose sur un fond colore : toujours sur [lightSurface]
  /// / [darkSurface] pour garantir le contraste maximal.
  static TextStyle seriesNumber(Color color, {bool active = false}) =>
      GoogleFonts.jetBrainsMono(fontSize: active ? 34 : 30, fontWeight: FontWeight.w800, color: color);

  /// Minuteur - chasse fixe (les chiffres ne bougent pas d'un pixel entre
  /// deux secondes).
  static TextStyle timerNumber(Color color) =>
      GoogleFonts.jetBrainsMono(fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: 19 * 0.04, color: color);

  /// Libelle secondaire en capitales (DERNIERE SEANCE, unites reps/kg...).
  static TextStyle labelSecondary(Color color) =>
      GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 11 * 0.16, color: color);

  /// Libelle de bouton - capitales pour le CTA critique, casse normale
  /// ailleurs (a la charge de l'appelant).
  static TextStyle buttonLabel(Color color) =>
      GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 15 * 0.04, color: color);

  // ============================================
  // THEME DARK MODE
  // ============================================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

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
        onPrimary: const Color(0xFF08101B),
        onSecondary: const Color(0xFF08101B),
        onError: const Color(0xFF08101B),
        onSurface: darkOnSurface,
        outline: outlineSubtleDark,
      ),

      scaffoldBackgroundColor: darkBackground,
      textTheme: _textTheme(darkOnBackground),

      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: darkSurface.withValues(alpha: 0.8),
        foregroundColor: darkOnBackground,
        titleTextStyle: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: darkOnBackground, letterSpacing: 0.15),
        iconTheme: IconThemeData(color: darkOnBackground),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXL),
          side: BorderSide(color: outlineSubtleDark, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryBlue,
          foregroundColor: const Color(0xFF08101B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusL)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: buttonLabel(const Color(0xFF08101B)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
          side: BorderSide(color: primaryBlue, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: buttonLabel(primaryBlue),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: const Color(0xFF08101B),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusL)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusL), borderSide: BorderSide(color: outlineSubtleDark, width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusL), borderSide: BorderSide(color: outlineSubtleDark, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusL), borderSide: const BorderSide(color: primaryBlue, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusL), borderSide: const BorderSide(color: errorRed, width: 2)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusL), borderSide: const BorderSide(color: errorRed, width: 2)),
        labelStyle: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w500, color: darkOnSurfaceMuted),
        hintStyle: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w400, color: darkOnSurfaceMuted),
      ),

      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXXL), side: BorderSide(color: outlineSubtleDark, width: 1)),
        titleTextStyle: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w700, color: darkOnBackground),
        contentTextStyle: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w500, color: darkOnSurface),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurfaceVariant,
        contentTextStyle: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w500, color: darkOnSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
        behavior: SnackBarBehavior.floating,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXXL))),
        elevation: 0,
      ),

      dividerTheme: DividerThemeData(color: outlineSubtleDark, thickness: 1, space: 1),
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

      colorScheme: ColorScheme.light(
        primary: lightPrimaryBlue,
        primaryContainer: lightPrimaryBlueLight.withValues(alpha: 0.1),
        secondary: lightPrimaryBlueDark,
        secondaryContainer: lightPrimaryBlueDark.withValues(alpha: 0.1),
        tertiary: lightSuccessGreen,
        tertiaryContainer: lightSuccessGreen.withValues(alpha: 0.1),
        error: lightErrorRed,
        errorContainer: lightErrorRed.withValues(alpha: 0.1),
        surface: lightSurface,
        surfaceContainerHighest: lightSurfaceVariant,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onSurface: lightOnSurface,
        outline: outlineSubtleLight,
      ),

      scaffoldBackgroundColor: lightBackground,
      textTheme: _textTheme(lightOnBackground),

      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: lightSurface.withValues(alpha: 0.8),
        foregroundColor: lightOnBackground,
        titleTextStyle: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: lightOnBackground, letterSpacing: 0.15),
        iconTheme: IconThemeData(color: lightOnBackground),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXL),
          side: BorderSide(color: outlineSubtleLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: lightPrimaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusL)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: buttonLabel(Colors.white),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightPrimaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
          side: BorderSide(color: lightPrimaryBlue, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: buttonLabel(lightPrimaryBlue),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightPrimaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightPrimaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusL)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusL), borderSide: BorderSide(color: outlineSubtleLight, width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusL), borderSide: BorderSide(color: outlineSubtleLight, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusL), borderSide: const BorderSide(color: lightPrimaryBlue, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusL), borderSide: const BorderSide(color: lightErrorRed, width: 2)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusL), borderSide: const BorderSide(color: lightErrorRed, width: 2)),
        labelStyle: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w500, color: lightOnSurfaceMuted),
        hintStyle: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w400, color: lightOnSurfaceMuted),
      ),

      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXXL), side: BorderSide(color: outlineSubtleLight, width: 1)),
        titleTextStyle: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w700, color: lightOnBackground),
        contentTextStyle: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w500, color: lightOnSurface),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: lightOnBackground,
        contentTextStyle: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
        behavior: SnackBarBehavior.floating,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXXL))),
        elevation: 0,
      ),

      dividerTheme: DividerThemeData(color: outlineSubtleLight, thickness: 1, space: 1),
      iconTheme: IconThemeData(color: lightOnSurface, size: 24),
    );
  }
}
