// Tests de couverture du manifest d'images pour les 15 exercices custom
// (etape E5).
//
// Ce fichier verifie deux aspects complementaires :
// (a) le contenu brut de assets/exercise_images/manifest.json : les 15 ids
//     custom sont bien presents, et pour chacun le fichier SVG reference
//     existe physiquement dans assets/exercise_images/ ;
// (b) le comportement de la classe ExerciseImageManifest
//     (lib/core/models/exercise_image_manifest.dart) : chaque id custom est
//     correctement resolu vers son chemin d'asset attendu.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:apollon/core/models/exercise_image_manifest.dart';

/// Repertoire des assets d'images d'exercices.
const String kExerciseImagesDir = 'assets/exercise_images';

/// Les 15 ids custom ajoutes aux etapes E1-E4, avec leur fichier SVG attendu.
/// La convention observee dans manifest.json est filename = id + ".svg"
/// pour chacune de ces 15 entrees.
const Map<String, String> kExpectedCustomEntries = {
  'custom_low_row': 'custom_low_row.svg',
  'custom_seated_dip': 'custom_seated_dip.svg',
  'custom_shoulder_press_machine': 'custom_shoulder_press_machine.svg',
  'custom_seated_leg_curl': 'custom_seated_leg_curl.svg',
  'custom_glute_kickback_machine': 'custom_glute_kickback_machine.svg',
  'custom_hip_thrust_machine': 'custom_hip_thrust_machine.svg',
  'custom_smith_machine_squat': 'custom_smith_machine_squat.svg',
  'custom_assisted_pull_up_machine': 'custom_assisted_pull_up_machine.svg',
  'custom_assisted_dip_machine': 'custom_assisted_dip_machine.svg',
  'custom_cable_crossover': 'custom_cable_crossover.svg',
  'custom_rotary_torso_machine': 'custom_rotary_torso_machine.svg',
  'custom_ab_crunch_machine': 'custom_ab_crunch_machine.svg',
  'custom_preacher_curl_machine': 'custom_preacher_curl_machine.svg',
  'custom_triceps_extension_machine': 'custom_triceps_extension_machine.svg',
  'custom_shrug_machine': 'custom_shrug_machine.svg',
};

void main() {
  group('manifest.json - contenu brut (15 exercices custom)', () {
    late List<Map<String, dynamic>> preseededExercises;

    setUpAll(() {
      final manifestFile = File('$kExerciseImagesDir/manifest.json');
      expect(
        manifestFile.existsSync(),
        isTrue,
        reason: 'assets/exercise_images/manifest.json doit exister sur le disque',
      );

      final jsonString = manifestFile.readAsStringSync();
      final manifestData = jsonDecode(jsonString) as Map<String, dynamic>;
      preseededExercises = (manifestData['preseeded_exercises'] as List)
          .cast<Map<String, dynamic>>();
    });

    test('les 15 ids custom sont tous presents dans le manifest', () {
      final allIds = preseededExercises
          .map((exercise) => exercise['id'] as String)
          .toSet();

      for (final id in kExpectedCustomEntries.keys) {
        expect(
          allIds.contains(id),
          isTrue,
          reason: 'L\'id "$id" est absent de manifest.json',
        );
      }
    });

    for (final entry in kExpectedCustomEntries.entries) {
      final id = entry.key;
      final expectedFilename = entry.value;

      test('l\'entree "$id" reference le bon filename', () {
        final matches =
            preseededExercises.where((exercise) => exercise['id'] == id);

        expect(
          matches.length,
          1,
          reason: 'L\'id "$id" doit apparaitre exactement une fois dans '
              'manifest.json',
        );
        expect(matches.first['filename'], expectedFilename);
      });

      test(
        'le fichier SVG "$expectedFilename" de "$id" existe physiquement',
        () {
          final svgFile = File('$kExerciseImagesDir/$expectedFilename');
          expect(
            svgFile.existsSync(),
            isTrue,
            reason: 'Le fichier $kExerciseImagesDir/$expectedFilename doit '
                'exister sur le disque pour l\'id "$id"',
          );
        },
      );
    }
  });

  group('ExerciseImageManifest - resolution des ids custom', () {
    late ExerciseImageManifest manifest;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      manifest = await ExerciseImageManifest.load();
    });

    test('le manifest charge contient au moins les 15 entrees custom', () {
      expect(
        manifest.count,
        greaterThanOrEqualTo(kExpectedCustomEntries.length),
      );
    });

    for (final entry in kExpectedCustomEntries.entries) {
      final id = entry.key;
      final expectedAssetPath = '$kExerciseImagesDir/${entry.value}';

      test('hasPreseededImage("$id") retourne true', () {
        expect(manifest.hasPreseededImage(id), isTrue);
      });

      test('getAssetPath("$id") resout vers "$expectedAssetPath"', () {
        expect(manifest.getAssetPath(id), expectedAssetPath);
      });
    }

    test('getAssetPath retourne null pour un id custom inconnu', () {
      const unknownId = 'custom_id_qui_nexiste_pas';
      expect(manifest.getAssetPath(unknownId), isNull);
      expect(manifest.hasPreseededImage(unknownId), isFalse);
    });

    test('preseededIds contient les 15 ids custom', () {
      final ids = manifest.preseededIds;
      for (final id in kExpectedCustomEntries.keys) {
        expect(ids.contains(id), isTrue, reason: 'id manquant : $id');
      }
    });
  });
}
