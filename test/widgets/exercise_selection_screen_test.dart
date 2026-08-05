import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apollon/core/providers/auth_provider.dart' as app_providers;
import 'package:apollon/core/providers/workout_provider.dart';
import 'package:apollon/screens/exercise_library/exercise_library_selection_screen.dart';
import 'package:apollon/core/services/exercise_library_repository.dart';
import 'package:apollon/core/providers/exercise_library_provider.dart';
import 'package:apollon/core/models/exercise_library.dart';
import 'package:apollon/core/models/muscle_info.dart';
import 'package:apollon/core/models/type_info.dart';
import 'package:apollon/core/models/category_info.dart';
import '../helpers/test_helpers.dart';

class MockExerciseLibraryRepository extends Mock implements ExerciseLibraryRepository {}

/// Construit un exercice de test minimal mais realiste (meme forme que
/// test/providers/exercise_library_provider_test.dart, duplique ici pour que
/// ce fichier widget reste autonome).
ExerciseLibrary _buildExercise({
  required String id,
  required String name,
  required List<MuscleInfo> primaryMuscles,
  List<MuscleInfo> secondaryMuscles = const [],
  required List<CategoryInfo> categories,
  required List<TypeInfo> types,
}) {
  return ExerciseLibrary(
    id: id,
    code: id,
    name: name,
    description: name,
    primaryMuscles: primaryMuscles,
    secondaryMuscles: secondaryMuscles,
    types: types,
    categories: categories,
    syncedAt: DateTime(2026, 1, 1),
    source: 'workout-api',
  );
}

// Jeu de donnees fixe reutilise par les tests de filtres/compteur :
// 3 categories (FREE_WEIGHT, MACHINE, BODYWEIGHT) et 2 types (COMPOUND,
// ISOLATION) presents, pour pouvoir couvrir la multi-selection et le filtre
// type sans dependre du catalogue reel.
final _benchPress = _buildExercise(
  id: 'BARBELL_BENCH_PRESS',
  name: 'Développé couché barre',
  primaryMuscles: [MuscleInfo(code: 'CHEST', name: 'Pectoraux')],
  categories: [CategoryInfo(code: 'FREE_WEIGHT', name: 'Poids libres')],
  types: [TypeInfo(code: 'COMPOUND', name: 'Polyarticulaire')],
);

final _legPress = _buildExercise(
  id: 'LEG_PRESS',
  name: 'Presse à cuisses',
  primaryMuscles: [MuscleInfo(code: 'QUADRICEPS', name: 'Quadriceps')],
  categories: [CategoryInfo(code: 'MACHINE', name: 'Machine guidée')],
  types: [TypeInfo(code: 'COMPOUND', name: 'Polyarticulaire')],
);

final _bicepsCurl = _buildExercise(
  id: 'DUMBBELL_BICEPS_CURL',
  name: 'Curl biceps haltère',
  primaryMuscles: [MuscleInfo(code: 'BICEPS', name: 'Biceps')],
  categories: [CategoryInfo(code: 'FREE_WEIGHT', name: 'Poids libres')],
  types: [TypeInfo(code: 'ISOLATION', name: 'Isolation')],
);

final _tricepsExtension = _buildExercise(
  id: 'CABLE_TRICEPS_EXTENSION',
  name: 'Extension triceps poulie',
  primaryMuscles: [MuscleInfo(code: 'TRICEPS', name: 'Triceps')],
  categories: [CategoryInfo(code: 'MACHINE', name: 'Machine guidée')],
  types: [TypeInfo(code: 'ISOLATION', name: 'Isolation')],
);

final _bodyweightSquat = _buildExercise(
  id: 'BODYWEIGHT_SQUAT',
  name: 'Squat poids du corps',
  primaryMuscles: [MuscleInfo(code: 'QUADRICEPS', name: 'Quadriceps')],
  categories: [CategoryInfo(code: 'BODYWEIGHT', name: 'Poids du corps')],
  types: [TypeInfo(code: 'COMPOUND', name: 'Polyarticulaire')],
);

final _allExercises = [
  _benchPress,
  _legPress,
  _bicepsCurl,
  _tricepsExtension,
  _bodyweightSquat,
];

Widget buildTestWidget({
  List<ExerciseLibrary>? exercises,
}) {
  final mockRepo = MockExerciseLibraryRepository();
  when(() => mockRepo.getAll()).thenAnswer((_) async => exercises ?? []);
  // ExerciseImageThumbnail (une par carte de la liste) interroge toujours
  // getImageSource : retourner null pour faire afficher l'emoji de repli
  // sans déclencher de téléchargement (comportement de ExerciseImageThumbnail).
  when(() => mockRepo.getImageSource(any())).thenAnswer((_) async => null);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<WorkoutProvider>(
        create: (_) => createTestWorkoutProvider(),
      ),
      ChangeNotifierProvider<app_providers.AuthProvider>(
        create: (_) => TestAuthProvider(MockAuthService()),
      ),
      Provider<ExerciseLibraryRepository>.value(value: mockRepo),
      ChangeNotifierProvider<ExerciseLibraryProvider>(
        create: (_) => ExerciseLibraryProvider(mockRepo),
      ),
    ],
    child: const MaterialApp(home: ExerciseLibrarySelectionScreen()),
  );
}

void main() {
  setUp(() {
    // Isole le stockage shared_preferences simule entre chaque test, pour
    // qu'aucun filtre persiste d'un test au suivant.
    SharedPreferences.setMockInitialValues({});
  });

  group('ExerciseLibrarySelectionScreen Widget Tests', () {
    testWidgets('should have tabs for muscle groups', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(Tab), findsWidgets);
    });

    testWidgets('should have search bar', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should have Scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('search bar should be editable', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Bench');
      await tester.pump();

      expect(find.text('Bench'), findsOneWidget);
    });
  });

  group('compteur de resultats', () {
    testWidgets("affiche le nombre de resultats sous la forme 'N exercices'", (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(exercises: _allExercises));
      await tester.pumpAndSettle();

      expect(find.text('5 exercices'), findsOneWidget);
    });

    testWidgets('se met a jour quand un filtre reduit les resultats', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(exercises: _allExercises));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'bench');
      await tester.pumpAndSettle();

      expect(find.text('1 exercices'), findsOneWidget);
    });
  });

  group("bouton 'Reinitialiser' conditionnel", () {
    testWidgets('est absent quand aucun filtre n\'est actif', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(exercises: _allExercises));
      await tester.pumpAndSettle();

      expect(find.text('Réinitialiser'), findsNothing);
    });

    testWidgets('apparait des qu\'un filtre (recherche) est actif', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(exercises: _allExercises));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'bench');
      await tester.pumpAndSettle();

      expect(find.text('Réinitialiser'), findsOneWidget);
    });

    testWidgets('apparait des qu\'un onglet muscle est selectionne', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(exercises: _allExercises));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(Tab, 'Pectoraux'));
      await tester.pumpAndSettle();

      expect(find.text('Réinitialiser'), findsOneWidget);
    });

    testWidgets('disparait apres un tap, et le compteur revient au total', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(exercises: _allExercises));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'bench');
      await tester.pumpAndSettle();
      expect(find.text('Réinitialiser'), findsOneWidget);

      await tester.tap(find.text('Réinitialiser'));
      await tester.pumpAndSettle();

      expect(find.text('Réinitialiser'), findsNothing);
      expect(find.text('5 exercices'), findsOneWidget);
    });
  });

  group('etat vide', () {
    testWidgets(
        "affiche 'Aucun exercice ne correspond' avec une action de reset quand un filtre actif ne matche rien",
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(exercises: _allExercises));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'zzz_aucun_match_zzz');
      await tester.pumpAndSettle();

      expect(find.text('Aucun exercice ne correspond'), findsOneWidget);
      expect(find.text('Réinitialiser les filtres'), findsOneWidget);
    });

    testWidgets("l'action de reset de l'etat vide restaure la liste complete", (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(exercises: _allExercises));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'zzz_aucun_match_zzz');
      await tester.pumpAndSettle();
      expect(find.text('Aucun exercice ne correspond'), findsOneWidget);

      await tester.tap(find.text('Réinitialiser les filtres'));
      await tester.pumpAndSettle();

      expect(find.text('Aucun exercice ne correspond'), findsNothing);
      expect(find.text('5 exercices'), findsOneWidget);
    });
  });

  group('FilterChips categories en multi-selection', () {
    testWidgets('selectionner deux categories fait une union des resultats', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(exercises: _allExercises));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilterChip, 'Poids libres'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'Machine guidée'));
      await tester.pumpAndSettle();

      final freeWeightChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Poids libres'),
      );
      final machineChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Machine guidée'),
      );
      expect(freeWeightChip.selected, isTrue);
      expect(machineChip.selected, isTrue);

      // Union FREE_WEIGHT (benchPress, bicepsCurl) + MACHINE (legPress,
      // tricepsExtension) = 4 exercices, bodyweightSquat exclu.
      expect(find.text('4 exercices'), findsOneWidget);
    });

    testWidgets('re-taper sur une categorie selectionnee la deselectionne', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(exercises: _allExercises));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilterChip, 'Poids libres'));
      await tester.pumpAndSettle();
      expect(find.text('2 exercices'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilterChip, 'Poids libres'));
      await tester.pumpAndSettle();

      expect(find.text('5 exercices'), findsOneWidget);
    });
  });

  group('filtre type', () {
    testWidgets('les FilterChips de type sont visibles avec les types presents', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(exercises: _allExercises));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(FilterChip, 'Polyarticulaire'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Isolation'), findsOneWidget);
    });

    testWidgets('selectionner le type Isolation filtre la liste', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(exercises: _allExercises));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilterChip, 'Isolation'));
      await tester.pumpAndSettle();

      // Seuls bicepsCurl et tricepsExtension sont de type ISOLATION.
      expect(find.text('2 exercices'), findsOneWidget);
      expect(find.text('Réinitialiser'), findsOneWidget);
    });
  });

  group('restauration des filtres persistes a l\'ouverture', () {
    testWidgets('le champ de recherche persiste est restaure au demarrage', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'exercise_library_filters_v1_search': 'bench',
      });

      await tester.pumpWidget(buildTestWidget(exercises: _allExercises));
      await tester.pumpAndSettle();

      expect(find.text('bench'), findsOneWidget);
      expect(find.text('1 exercices'), findsOneWidget);
    });
  });

  // Phase rouge TDD : le ListView.builder de _buildExerciseList() recycle
  // ses Elements/State par POSITION (index) quand aucune Key stable n'est
  // posee sur l'item retourne par itemBuilder. Sans Key derivee de l'id de
  // l'exercice (ex. ValueKey(exercise.id)), un scroll ou un changement de
  // filtre qui modifie l'ordre/le contenu de la liste fait heriter un item
  // du State (et donc de l'image en cache) d'un exercice different affiche
  // a la meme position auparavant : c'est le bug de recyclage d'image.
  group('cle stable par carte (recyclage ListView.builder)', () {
    testWidgets(
        'chaque carte generee par le ListView.builder porte une Key stable '
        'derivee de l\'id de l\'exercice',
        (WidgetTester tester) async {
      // Agrandir la surface de test pour que les 5 cartes tiennent a l'ecran
      // sans defilement : ListView.builder DETRUIT les elements sortis du
      // viewport, donc verifier les clefs apres un scroll evincerait les
      // premieres cartes (faux negatif). Tout visible = verification
      // deterministe de chaque clef.
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(exercises: _allExercises));
      await tester.pumpAndSettle();

      // Pomper une fois de plus pour s'assurer que le chargement asynchrone
      // du provider est completement termine et que tous les widgets de
      // la liste sont construits.
      await tester.pump();

      // Verifier d'abord que le compteur d'exercices est affiche
      expect(find.text('5 exercices'), findsOneWidget,
          reason: 'Le compteur de resultats n\'est pas visible');

      // Verifier aussi qu'au moins le titre du premier exercice est visible
      expect(find.text('Développé couché barre'), findsOneWidget,
          reason: 'Le premier exercice n\'est pas visible');

      for (final exercise in _allExercises) {
        expect(
          find.byKey(ValueKey(exercise.id)),
          findsOneWidget,
          reason: 'Key stable ValueKey(${exercise.id}) non trouvee sur la '
              'carte de l\'exercice ${exercise.name}.',
        );
      }
    });
  });
}
