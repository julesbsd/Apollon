import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:apollon/core/theme/app_theme.dart';

/// Calcule la luminance relative WCAG d'une couleur (0.0 - 1.0).
/// Formule officielle : https://www.w3.org/TR/WCAG21/#dfn-relative-luminance
/// Ecrite ici volontairement (aucune fonction equivalente n'existe ailleurs
/// dans le depot au moment de l'ecriture) plutot que d'ajouter une
/// dependance externe pour un simple calcul mathematique.
double relativeLuminance(Color color) {
  double linearize(double channel) {
    return channel <= 0.03928
        ? channel / 12.92
        : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = linearize(color.r);
  final g = linearize(color.g);
  final b = linearize(color.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/// Calcule le ratio de contraste WCAG entre deux couleurs.
/// Formule : (L1 + 0.05) / (L2 + 0.05), L1 >= L2.
/// https://www.w3.org/TR/WCAG21/#dfn-contrast-ratio
double contrastRatio(Color a, Color b) {
  final la = relativeLuminance(a);
  final lb = relativeLuminance(b);
  final lighter = math.max(la, lb);
  final darker = math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('contrastRatio - sanite du calcul', () {
    test('noir sur blanc donne le ratio maximal (21:1)', () {
      expect(contrastRatio(Colors.black, Colors.white), closeTo(21.0, 0.01));
    });

    test('une couleur avec elle-meme donne un ratio de 1:1', () {
      expect(
        contrastRatio(AppTheme.lightPrimaryBlue, AppTheme.lightPrimaryBlue),
        closeTo(1.0, 0.0001),
      );
    });

    test('le ratio est symetrique', () {
      final r1 = contrastRatio(AppTheme.lightOnBackground, AppTheme.lightBackground);
      final r2 = contrastRatio(AppTheme.lightBackground, AppTheme.lightOnBackground);
      expect(r1, closeTo(r2, 0.0001));
    });
  });

  group('AppTheme - contraste WCAG AA texte (>= 4.5:1) - mode clair', () {
    test('lightOnBackground / lightBackground', () {
      expect(contrastRatio(AppTheme.lightOnBackground, AppTheme.lightBackground), greaterThanOrEqualTo(4.5));
    });

    test('lightOnSurface / lightSurface', () {
      expect(contrastRatio(AppTheme.lightOnSurface, AppTheme.lightSurface), greaterThanOrEqualTo(4.5));
    });

    test('blanc / lightPrimaryBlue (texte de bouton)', () {
      expect(contrastRatio(Colors.white, AppTheme.lightPrimaryBlue), greaterThanOrEqualTo(4.5));
    });

    test('lightAccentGold / lightSurface (texte or)', () {
      expect(contrastRatio(AppTheme.lightAccentGold, AppTheme.lightSurface), greaterThanOrEqualTo(4.5));
    });
  });

  group('AppTheme - contraste WCAG AA texte (>= 4.5:1) - mode sombre', () {
    test('darkOnBackground / darkBackground', () {
      expect(contrastRatio(AppTheme.darkOnBackground, AppTheme.darkBackground), greaterThanOrEqualTo(4.5));
    });

    test('darkOnSurface / darkSurface', () {
      expect(contrastRatio(AppTheme.darkOnSurface, AppTheme.darkSurface), greaterThanOrEqualTo(4.5));
    });

    test('accentGold / darkSurface (texte or)', () {
      expect(contrastRatio(AppTheme.accentGold, AppTheme.darkSurface), greaterThanOrEqualTo(4.5));
    });
  });

  group('AppTheme - contraste des 14 groupes musculaires (critere CS-DA-04)', () {
    test('chaque groupe clair est lisible sur lightSurface', () {
      AppTheme.muscleGroupColorsLight.forEach((name, color) {
        expect(
          contrastRatio(color, AppTheme.lightSurface),
          greaterThanOrEqualTo(4.5),
          reason: '$name (clair) sous le seuil AA sur lightSurface',
        );
      });
    });

    test('chaque groupe sombre est lisible sur darkSurface', () {
      AppTheme.muscleGroupColorsDark.forEach((name, color) {
        expect(
          contrastRatio(color, AppTheme.darkSurface),
          greaterThanOrEqualTo(4.5),
          reason: '$name (sombre) sous le seuil AA sur darkSurface',
        );
      });
    });
  });
}
