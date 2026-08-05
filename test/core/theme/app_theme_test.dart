import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apollon/core/theme/app_theme.dart';

void main() {
  // Les tests de typographie appellent GoogleFonts.cinzel()/.manrope()/
  // .jetBrainsMono() hors testWidgets() (pas de binding Flutter complet) :
  // sans cette ligne, google_fonts tente un telechargement reseau du
  // fichier de police et l'echec est remonte comme une exception de test.
  // On verifie ici uniquement la famille/taille demandee, pas le rendu
  // visuel du glyphe - desactiver le fetch reseau est donc sans impact sur
  // ce qui est teste.
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });


  group('AppTheme - jetons couleur "Marbre & Lumiere"', () {
    test('couleurs d\'action (bare = valeur sombre, light* = valeur claire)', () {
      expect(AppTheme.primaryBlue, const Color(0xFF4E92CF));
      expect(AppTheme.primaryBlueDark, const Color(0xFF255F97));
      expect(AppTheme.primaryBlueLight, const Color(0xFF7FB6E8));
      expect(AppTheme.lightPrimaryBlue, const Color(0xFF17568C));
      expect(AppTheme.lightPrimaryBlueDark, const Color(0xFF0E3A62));
      expect(AppTheme.lightPrimaryBlueLight, const Color(0xFF4E92CF));
    });

    test('or Apollon', () {
      expect(AppTheme.accentGold, const Color(0xFFD9B978));
      expect(AppTheme.lightAccentGold, const Color(0xFF8A6A2F));
      expect(AppTheme.accentGoldLine, const Color(0xFFD9B978));
      expect(AppTheme.lightAccentGoldLine, const Color(0xFFB08D57));
      expect(AppTheme.accentGoldGlowDark, const Color(0xFFF0D9A2));
      expect(AppTheme.accentGoldGlowLight, const Color(0xFFC7A96B));
    });

    test('couleurs semantiques', () {
      expect(AppTheme.successGreen, const Color(0xFF35D9A6));
      expect(AppTheme.lightSuccessGreen, const Color(0xFF0E7A5F));
      expect(AppTheme.errorRed, const Color(0xFFFF6B5A));
      expect(AppTheme.lightErrorRed, const Color(0xFFC0392B));
      expect(AppTheme.warningOrange, const Color(0xFFF2A93B));
      expect(AppTheme.lightWarningOrange, const Color(0xFF9A6410));
    });

    test('mode clair - marbre chaud', () {
      expect(AppTheme.lightBackground, const Color(0xFFF6F3EC));
      expect(AppTheme.lightSurface, const Color(0xFFFDFBF7));
      expect(AppTheme.lightSurfaceVariant, const Color(0xFFEDE8DE));
      expect(AppTheme.lightOnBackground, const Color(0xFF141B2B));
      expect(AppTheme.lightOnSurface, const Color(0xFF2B3444));
      expect(AppTheme.lightOnSurfaceMuted, const Color(0xFF5C6577));
    });

    test('mode sombre - nuit minerale', () {
      expect(AppTheme.darkBackground, const Color(0xFF0A0E16));
      expect(AppTheme.darkSurface, const Color(0xFF121826));
      expect(AppTheme.darkSurfaceVariant, const Color(0xFF1C2432));
      expect(AppTheme.darkOnBackground, const Color(0xFFF2EFE9));
      expect(AppTheme.darkOnSurface, const Color(0xFFDCD8D0));
      expect(AppTheme.darkOnSurfaceMuted, const Color(0xFF98A1B0));
    });

    test('socle pictogramme et contour', () {
      expect(AppTheme.pictogramPlinthTopLight, const Color(0xFF2A3949));
      expect(AppTheme.pictogramPlinthTopDark, const Color(0xFF26313F));
      expect(AppTheme.pictogramPlinthBottomLight, const Color(0xFF141B2B));
      expect(AppTheme.pictogramPlinthBottomDark, const Color(0xFF0F151F));
      expect(AppTheme.outlineSubtleLight, const Color(0x17141B2B));
      expect(AppTheme.outlineSubtleDark, const Color(0x14FFFFFF));
    });

    test('mesh gradients (4 couleurs par mode)', () {
      expect(AppTheme.lightMeshGradient, const [
        Color(0xFFF8F5EF),
        Color(0xFFEDF0F4),
        Color(0xFFF2ECE0),
        Color(0xFFFBF9F5),
      ]);
      expect(AppTheme.darkMeshGradient, const [
        Color(0xFF0A0E16),
        Color(0xFF101A2A),
        Color(0xFF16202E),
        Color(0xFF0C1119),
      ]);
    });
  });

  group('AppTheme - jetons radius (resserres depuis la V2)', () {
    test('valeurs numeriques exactes', () {
      expect(AppTheme.radiusS, 6.0);
      expect(AppTheme.radiusM, 10.0);
      expect(AppTheme.radiusL, 12.0);
      expect(AppTheme.radiusXL, 14.0);
      expect(AppTheme.radiusXXL, 20.0);
      expect(AppTheme.radiusPill, 999.0);
    });
  });

  group('AppTheme - ombres a 2 niveaux', () {
    test('shadowElev1/2 different entre clair et sombre', () {
      final elev1Light = AppTheme.shadowElev1(Brightness.light);
      final elev1Dark = AppTheme.shadowElev1(Brightness.dark);
      final elev2Light = AppTheme.shadowElev2(Brightness.light);
      final elev2Dark = AppTheme.shadowElev2(Brightness.dark);
      expect(elev1Light, isNotEmpty);
      expect(elev1Dark, isNotEmpty);
      expect(elev2Light, isNotEmpty);
      expect(elev2Dark, isNotEmpty);
      expect(elev1Light.first.color, isNot(equals(elev1Dark.first.color)));
      expect(elev2Light.first.blurRadius, isNot(equals(elev1Light.first.blurRadius)));
    });
  });

  group('AppTheme - typographie', () {
    // testWidgets (pas test()) : GoogleFonts a besoin du binding Flutter
    // complet (asset bundle) pour resoudre une famille de police sans lever
    // d'exception - seul le pumpWidget() d'un test de widget le fournit.
    testWidgets('screenTitle et wordmark sont en Cinzel', (tester) async {
      expect(AppTheme.screenTitle(Colors.black).fontFamily, contains('Cinzel'));
      expect(AppTheme.wordmark(Colors.black).fontFamily, contains('Cinzel'));
      // Regle dure : Cinzel interdit sous 20px.
      expect(AppTheme.screenTitle(Colors.black).fontSize, greaterThanOrEqualTo(20));
      expect(AppTheme.wordmark(Colors.black).fontSize, greaterThanOrEqualTo(17));
    });

    testWidgets('seriesNumber et timerNumber sont en JetBrains Mono', (tester) async {
      // google_fonts normalise le nom de famille sans espaces ('JetBrainsMono_...').
      expect(AppTheme.seriesNumber(Colors.black).fontFamily, contains('JetBrainsMono'));
      expect(AppTheme.timerNumber(Colors.black).fontFamily, contains('JetBrainsMono'));
      expect(AppTheme.seriesNumber(Colors.black, active: true).fontSize, 34);
      expect(AppTheme.seriesNumber(Colors.black, active: false).fontSize, 30);
    });

    testWidgets('buttonLabel et labelSecondary sont en Manrope', (tester) async {
      expect(AppTheme.buttonLabel(Colors.black).fontFamily, contains('Manrope'));
      expect(AppTheme.labelSecondary(Colors.black).fontFamily, contains('Manrope'));
    });
  });

  group('AppTheme - 14 groupes musculaires', () {
    const expectedGroups = [
      'Pectoraux',
      'Epaules',
      'Abdominaux',
      'Lombaires',
      'Quadriceps',
      'Ischio-jambiers',
      'Triceps',
      'Mollets',
      'Dorsaux',
      'Trapezes',
      'Avant-bras',
      'Biceps',
      'Fessiers',
      'Cardio',
    ];

    test('les 14 groupes sont presents dans les deux referentiels', () {
      expect(AppTheme.muscleGroupColorsLight.length, 14);
      expect(AppTheme.muscleGroupColorsDark.length, 14);
      for (final group in expectedGroups) {
        expect(AppTheme.muscleGroupColorsLight.containsKey(group), isTrue,
            reason: '$group manquant en clair');
        expect(AppTheme.muscleGroupColorsDark.containsKey(group), isTrue,
            reason: '$group manquant en sombre');
      }
    });

    test('les 5 nouvelles entrees ne sont pas absentes', () {
      const newGroups = ['Lombaires', 'Ischio-jambiers', 'Mollets', 'Trapezes', 'Avant-bras'];
      for (final group in newGroups) {
        expect(AppTheme.muscleGroupColorsLight[group], isNotNull);
        expect(AppTheme.muscleGroupColorsDark[group], isNotNull);
      }
    });

    test('chaque groupe resout une couleur clair et sombre distinctes', () {
      for (final group in expectedGroups) {
        final light = AppTheme.muscleGroupColorsLight[group];
        final dark = AppTheme.muscleGroupColorsDark[group];
        expect(light, isNotNull);
        expect(dark, isNotNull);
        expect(light, isNot(equals(dark)),
            reason: '$group doit avoir une teinte differente en clair/sombre');
      }
    });
  });
}
