import 'package:flutter_test/flutter_test.dart';
import 'package:apollon/core/utils/string_normalization.dart';

// Tests de la fonction pure normalizeString : supprime les accents et met en
// minuscules, pour permettre une recherche insensible a la casse et aux
// diacritiques (ex: 'developpe' doit pouvoir matcher 'Développé').
void main() {
  group('normalizeString', () {
    test('met en minuscules', () {
      expect(normalizeString('DEVELOPPE'), 'developpe');
      expect(normalizeString('Presse'), 'presse');
    });

    test('supprime les accents courants du francais', () {
      expect(normalizeString('Développé couché barre'), 'developpe couche barre');
      expect(normalizeString('Presse à cuisses'), 'presse a cuisses');
      expect(normalizeString('Épaules'), 'epaules');
      expect(normalizeString('Élévation'), 'elevation');
    });

    test('combine accents et casse en une seule normalisation', () {
      expect(normalizeString('DÉVELOPPÉ COUCHÉ'), 'developpe couche');
      expect(normalizeString('PRESSE À CUISSES'), 'presse a cuisses');
    });

    test('supprime les espaces superflus en debut et fin', () {
      expect(normalizeString('  Presse  '), 'presse');
    });

    test('gere une chaine vide', () {
      expect(normalizeString(''), '');
    });

    test('laisse les chaines deja normalisees inchangees', () {
      expect(normalizeString('developpe couche barre'), 'developpe couche barre');
    });

    test('gere un jeu etendu de diacritiques latins', () {
      expect(normalizeString('àâäéèêëîïôöùûüçñœæ'), 'aaaeeeeiioouuucnoeae');
    });
  });
}
