import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apollon/core/providers/exercise_library_provider.dart';
import 'package:apollon/core/services/exercise_library_repository.dart';
import 'package:apollon/core/models/exercise_library.dart';
import 'package:apollon/core/models/muscle_info.dart';
import 'package:apollon/core/models/type_info.dart';
import 'package:apollon/core/models/category_info.dart';

class MockExerciseLibraryRepository extends Mock implements ExerciseLibraryRepository {}

/// Construit un exercice de test minimal mais realiste.
ExerciseLibrary _buildExercise({
  required String id,
  required String name,
  required List<MuscleInfo> primaryMuscles,
  List<MuscleInfo> secondaryMuscles = const [],
  required List<CategoryInfo> categories,
  required List<TypeInfo> types,
  String? description,
}) {
  return ExerciseLibrary(
    id: id,
    code: id,
    name: name,
    description: description ?? name,
    primaryMuscles: primaryMuscles,
    secondaryMuscles: secondaryMuscles,
    types: types,
    categories: categories,
    syncedAt: DateTime(2026, 1, 1),
    source: 'workout-api',
  );
}

void main() {
  // Jeu de donnees fixe reutilise par tous les tests de recherche/filtrage.
  final benchPress = _buildExercise(
    id: 'BARBELL_BENCH_PRESS',
    name: 'Développé couché barre',
    primaryMuscles: [MuscleInfo(code: 'CHEST', name: 'Pectoraux')],
    secondaryMuscles: [MuscleInfo(code: 'TRICEPS', name: 'Triceps')],
    categories: [CategoryInfo(code: 'FREE_WEIGHT', name: 'Poids libres')],
    types: [TypeInfo(code: 'COMPOUND', name: 'Polyarticulaire')],
  );

  final legPress = _buildExercise(
    id: 'LEG_PRESS',
    name: 'Presse à cuisses',
    primaryMuscles: [MuscleInfo(code: 'QUADRICEPS', name: 'Quadriceps')],
    secondaryMuscles: [MuscleInfo(code: 'GLUTES', name: 'Fessiers')],
    categories: [CategoryInfo(code: 'MACHINE', name: 'Machine guidée')],
    types: [TypeInfo(code: 'COMPOUND', name: 'Polyarticulaire')],
  );

  final bicepsCurl = _buildExercise(
    id: 'DUMBBELL_BICEPS_CURL',
    name: 'Curl biceps haltère',
    primaryMuscles: [MuscleInfo(code: 'BICEPS', name: 'Biceps')],
    categories: [CategoryInfo(code: 'FREE_WEIGHT', name: 'Poids libres')],
    types: [TypeInfo(code: 'ISOLATION', name: 'Isolation')],
  );

  final tricepsExtension = _buildExercise(
    id: 'CABLE_TRICEPS_EXTENSION',
    name: 'Extension triceps poulie',
    primaryMuscles: [MuscleInfo(code: 'TRICEPS', name: 'Triceps')],
    categories: [CategoryInfo(code: 'MACHINE', name: 'Machine guidée')],
    types: [TypeInfo(code: 'ISOLATION', name: 'Isolation')],
  );

  final bodyweightSquat = _buildExercise(
    id: 'BODYWEIGHT_SQUAT',
    name: 'Squat poids du corps',
    primaryMuscles: [MuscleInfo(code: 'QUADRICEPS', name: 'Quadriceps')],
    secondaryMuscles: [MuscleInfo(code: 'GLUTES', name: 'Fessiers')],
    categories: [CategoryInfo(code: 'BODYWEIGHT', name: 'Poids du corps')],
    types: [TypeInfo(code: 'COMPOUND', name: 'Polyarticulaire')],
  );

  final allExercises = [
    benchPress,
    legPress,
    bicepsCurl,
    tricepsExtension,
    bodyweightSquat,
  ];

  late MockExerciseLibraryRepository mockRepository;
  late ExerciseLibraryProvider provider;

  setUp(() async {
    // Isole le stockage shared_preferences simule entre chaque test.
    SharedPreferences.setMockInitialValues({});
    mockRepository = MockExerciseLibraryRepository();
    when(() => mockRepository.getAll()).thenAnswer((_) async => allExercises);
    provider = ExerciseLibraryProvider(mockRepository);
    await provider.loadExercises();
  });

  group('recherche textuelle insensible aux accents et a la casse', () {
    test("'developpe' (sans accent, minuscule) trouve 'Développé couché barre'", () async {
      await provider.search('developpe');

      expect(provider.exercises, contains(benchPress));
      expect(provider.exercises.length, 1);
    });

    test("'PRESSE A CUISSES' (majuscule, sans accent) trouve 'Presse à cuisses'", () async {
      await provider.search('PRESSE A CUISSES');

      expect(provider.exercises, contains(legPress));
      expect(provider.exercises.length, 1);
    });

    test("'DÉVELOPPÉ' (majuscule accentuee) trouve aussi l'exercice", () async {
      await provider.search('DÉVELOPPÉ');

      expect(provider.exercises, contains(benchPress));
    });

    test('une recherche sans resultat retourne une liste vide', () async {
      await provider.search('exercice inexistant xyz');

      expect(provider.exercises, isEmpty);
    });
  });

  group('recherche etendue aux muscles primaires', () {
    test("'pectoraux' trouve les exercices dont le muscle primaire est Pectoraux", () async {
      await provider.search('pectoraux');

      expect(provider.exercises, contains(benchPress));
      expect(provider.exercises.length, 1);
    });

    test("'quadriceps' trouve les exercices cibles sans que le mot apparaisse dans le nom", () async {
      await provider.search('quadriceps');

      expect(provider.exercises, containsAll([legPress, bodyweightSquat]));
      expect(provider.exercises.length, 2);
    });

    test('la recherche ne matche pas sur un muscle uniquement secondaire', () async {
      // 'Fessiers' n'est un muscle primaire d'aucun exercice du jeu de donnees
      // (seulement secondaire pour legPress et bodyweightSquat) : la recherche
      // etendue est explicitement limitee aux muscles primaires.
      await provider.search('fessiers');

      expect(provider.exercises, isEmpty);
    });
  });

  group('filtre categorie en multi-selection', () {
    test('filterByCategoryGroup avec un seul code filtre correctement', () async {
      await provider.filterByCategoryGroup(['FREE_WEIGHT']);

      expect(provider.exercises, containsAll([benchPress, bicepsCurl]));
      expect(provider.exercises.length, 2);
      expect(provider.selectedCategoryCodes, ['FREE_WEIGHT']);
    });

    test('filterByCategoryGroup avec plusieurs codes fait une union', () async {
      await provider.filterByCategoryGroup(['FREE_WEIGHT', 'MACHINE']);

      expect(
        provider.exercises,
        containsAll([benchPress, bicepsCurl, legPress, tricepsExtension]),
      );
      expect(provider.exercises.length, 4);
    });

    test('filterByCategoryGroup avec une liste vide retire le filtre', () async {
      await provider.filterByCategoryGroup(['FREE_WEIGHT']);
      await provider.filterByCategoryGroup([]);

      expect(provider.exercises.length, allExercises.length);
      expect(provider.selectedCategoryCodes, isEmpty);
    });
  });

  group('filtre type expose et fonctionnel', () {
    test('filterByType filtre sur un seul code type', () async {
      await provider.filterByType('ISOLATION');

      expect(provider.exercises, containsAll([bicepsCurl, tricepsExtension]));
      expect(provider.exercises.length, 2);
      expect(provider.selectedTypeCodes, ['ISOLATION']);
    });

    test('filterByTypeGroup filtre sur plusieurs codes types', () async {
      await provider.filterByTypeGroup(['COMPOUND']);

      expect(
        provider.exercises,
        containsAll([benchPress, legPress, bodyweightSquat]),
      );
      expect(provider.exercises.length, 3);
    });

    test('getAvailableTypes retourne les codes types reellement presents, tries', () {
      expect(provider.getAvailableTypes(), ['COMPOUND', 'ISOLATION']);
    });
  });

  group('combinaisons de plusieurs filtres actifs simultanement', () {
    test('recherche + categorie + type combines restreignent le resultat', () async {
      // 'triceps' matche uniquement tricepsExtension (nom + muscle primaire) ;
      // benchPress n'a Triceps qu'en muscle secondaire, donc hors recherche etendue.
      await provider.search('triceps');
      await provider.filterByCategoryGroup(['MACHINE']);
      await provider.filterByType('ISOLATION');

      expect(provider.exercises, [tricepsExtension]);
      expect(provider.hasActiveFilters, isTrue);
    });

    test('muscle + categorie combines restreignent au bon sous-ensemble', () async {
      await provider.filterByMuscleGroup(['QUADRICEPS']);
      await provider.filterByCategoryGroup(['BODYWEIGHT']);

      expect(provider.exercises, [bodyweightSquat]);
    });
  });

  group('reset : purge etat memoire et persistance shared_preferences', () {
    test('clearFilters reinitialise tous les filtres en memoire', () async {
      await provider.search('developpe');
      await provider.filterByMuscleGroup(['CHEST']);
      await provider.filterByCategoryGroup(['FREE_WEIGHT']);
      await provider.filterByTypeGroup(['COMPOUND']);
      expect(provider.hasActiveFilters, isTrue);

      await provider.clearFilters();

      expect(provider.hasActiveFilters, isFalse);
      expect(provider.searchQuery, isEmpty);
      expect(provider.selectedMuscleCodes, isEmpty);
      expect(provider.selectedCategoryCodes, isEmpty);
      expect(provider.selectedTypeCodes, isEmpty);
      expect(provider.exercises.length, allExercises.length);
    });

    test('clearFilters purge aussi la persistance shared_preferences', () async {
      await provider.search('developpe');
      await provider.filterByCategoryGroup(['FREE_WEIGHT']);

      // Verifie qu'une valeur a bien ete persistee avant le reset.
      final prefsBefore = await SharedPreferences.getInstance();
      expect(prefsBefore.getString('exercise_library_filters_v1_search'), 'developpe');

      await provider.clearFilters();

      final prefsAfter = await SharedPreferences.getInstance();
      expect(prefsAfter.getString('exercise_library_filters_v1_search'), isNull);
      expect(prefsAfter.getStringList('exercise_library_filters_v1_muscles'), isNull);
      expect(prefsAfter.getStringList('exercise_library_filters_v1_categories'), isNull);
      expect(prefsAfter.getStringList('exercise_library_filters_v1_types'), isNull);
    });
  });

  group('persistance shared_preferences chargee a l\'initialisation', () {
    test('un nouveau provider restaure les filtres persistes par un provider precedent', () async {
      await provider.search('presse');
      await provider.filterByMuscleGroup(['QUADRICEPS']);
      await provider.filterByCategoryGroup(['MACHINE']);
      await provider.filterByTypeGroup(['COMPOUND']);

      // Nouveau provider (nouvelle instance, meme stockage shared_preferences simule).
      final restoredProvider = ExerciseLibraryProvider(mockRepository);
      await restoredProvider.loadExercises();

      expect(restoredProvider.searchQuery, 'presse');
      expect(restoredProvider.selectedMuscleCodes, ['QUADRICEPS']);
      expect(restoredProvider.selectedCategoryCodes, ['MACHINE']);
      expect(restoredProvider.selectedTypeCodes, ['COMPOUND']);
      expect(restoredProvider.exercises, [legPress]);
    });
  });
}
