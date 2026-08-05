import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:apollon/core/services/exercise_library_repository.dart';
import 'package:apollon/screens/exercise_library/widgets/exercise_image_widget.dart';

class MockExerciseLibraryRepository extends Mock
    implements ExerciseLibraryRepository {}

void main() {
  group('ExerciseImageWidget - Verification avatar de repli', () {
    late MockExerciseLibraryRepository mockRepository;

    setUp(() {
      mockRepository = MockExerciseLibraryRepository();
    });

    /// Widget de test pour ExerciseImageWidget
    /// Crée un exercice custom (hasImage=false) et teste le widget
    Widget buildTestWidget({required String exerciseId}) {
      return Provider<ExerciseLibraryRepository>.value(
        value: mockRepository,
        child: MaterialApp(
          home: Scaffold(
            body: ExerciseImageWidget(
              exerciseId: exerciseId,
              size: 100,
            ),
          ),
        ),
      );
    }

    testWidgets(
        'ExerciseImageWidget affiche placeholder quand exercice n\'a pas d\'image',
        (WidgetTester tester) async {
      final exerciseId = 'custom_exercise_no_image';

      // Stub: getImageSource retourne null pour indiquer pas d'image disponible
      when(() => mockRepository.getImageSource(exerciseId))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(buildTestWidget(exerciseId: exerciseId));
      // Attendre un frame pour que didChangeDependencies se déclenche
      await tester.pump(const Duration(milliseconds: 100));

      // Le widget doit afficher un placeholder sans erreur
      // (container gris avec spinner)
      expect(find.byType(ClipRRect), findsOneWidget);
      // Le placeholder doit être visible sans crash
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets(
        'ExerciseImageThumbnail affiche emoji de repli quand getImageSource=null',
        (WidgetTester tester) async {
      final exerciseId = 'custom_machine_workout';

      // Stub: getImageSource retourne null (pas d'image pour exercice custom)
      when(() => mockRepository.getImageSource(exerciseId))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(
        Provider<ExerciseLibraryRepository>.value(
          value: mockRepository,
          child: MaterialApp(
            home: Scaffold(
              body: ExerciseImageThumbnail(
                exerciseId: exerciseId,
                size: 56,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Le thumbnail doit afficher l'emoji de repli
      expect(find.text('💪'), findsOneWidget);
    });

    testWidgets(
        'ExerciseImageAvatar gère exercice sans image sans crash',
        (WidgetTester tester) async {
      final exerciseId = 'custom_low_row';

      // Stub: getImageSource retourne null
      when(() => mockRepository.getImageSource(exerciseId))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(
        Provider<ExerciseLibraryRepository>.value(
          value: mockRepository,
          child: MaterialApp(
            home: Scaffold(
              body: ExerciseImageAvatar(
                exerciseId: exerciseId,
                radius: 30,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // L'avatar doit afficher un placeholder sans crash
      expect(find.byType(ClipRRect), findsOneWidget);
      // Pas de crash = succès
    });

    testWidgets(
        'ExerciseImageContainer gère exercice sans image sans crash',
        (WidgetTester tester) async {
      final exerciseId = 'custom_seated_dip';

      // Stub: getImageSource retourne null
      when(() => mockRepository.getImageSource(exerciseId))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(
        Provider<ExerciseLibraryRepository>.value(
          value: mockRepository,
          child: MaterialApp(
            home: Scaffold(
              body: ExerciseImageContainer(
                exerciseId: exerciseId,
                size: 60,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Le container doit afficher sans crash
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets(
        'ExerciseImageWidget affiche image asset quand disponible',
        (WidgetTester tester) async {
      final exerciseId = 'top_20_exercise';
      final assetPath = 'assets/exercise_images/top_20_exercise.svg';

      // Stub: getImageSource retourne une image asset
      when(() => mockRepository.getImageSource(exerciseId))
          .thenAnswer((_) async => ImageSource.asset(assetPath));

      await tester.pumpWidget(buildTestWidget(exerciseId: exerciseId));
      await tester.pump(const Duration(milliseconds: 100));

      // Le widget doit afficher quelque chose (le SvgPicture.asset)
      expect(find.byType(ClipRRect), findsOneWidget);
    });
  });

  // Phase rouge TDD : reproduit le bug de recyclage d'image par POSITION.
  // ListView.builder recycle l'Element/State d'un item par sa position dans
  // la liste (pas par son contenu) quand aucune Key stable n'est posee sur
  // l'item. Ici, on simule ce recyclage sans ListView : on re-pompe le MEME
  // arbre de widgets (meme position, aucune Key distincte) en changeant
  // uniquement l'exerciseId passe en parametre. Comme _initialized reste a
  // true et que didChangeDependencies ne redeclenche pas le chargement au
  // simple changement de widget.exerciseId (didUpdateWidget non surcharge),
  // l'ancienne _imageSource (celle du premier exercice) reste affichee a la
  // place de celle du nouvel exercice : c'est le bug observe dans l'app.
  group(
      'Bug de recyclage d\'image par position (ListView.builder sans Key stable)',
      () {
    late MockExerciseLibraryRepository mockRepository;

    setUp(() {
      mockRepository = MockExerciseLibraryRepository();
    });

    testWidgets(
        'ExerciseImageThumbnail affiche encore l\'image de l\'exercice A '
        'apres recyclage a position identique vers B (doit echouer sur le '
        'code actuel)', (WidgetTester tester) async {
      const exerciseIdA = 'recycled_position_exercise_a';
      const exerciseIdB = 'recycled_position_exercise_b';
      const assetA = 'assets/exercise_images/recycled_position_exercise_a.svg';
      const assetB = 'assets/exercise_images/recycled_position_exercise_b.svg';

      when(() => mockRepository.getImageSource(exerciseIdA))
          .thenAnswer((_) async => const ImageSource.asset(assetA));
      when(() => mockRepository.getImageSource(exerciseIdB))
          .thenAnswer((_) async => const ImageSource.asset(assetB));

      // Meme structure d'arbre (Provider > MaterialApp > Scaffold >
      // ExerciseImageThumbnail), meme position, aucune Key distincte : c'est
      // exactement ce que verrait Flutter si un ListView.builder recyclait
      // l'item a un index donne sans Key stable derivee de l'id.
      Widget buildThumbnailAtFixedPosition(String exerciseId) {
        return Provider<ExerciseLibraryRepository>.value(
          value: mockRepository,
          child: MaterialApp(
            home: Scaffold(
              body: ExerciseImageThumbnail(
                exerciseId: exerciseId,
                size: 56,
              ),
            ),
          ),
        );
      }

      // 1) Premier affichage : l'exercice A occupe la position.
      await tester.pumpWidget(buildThumbnailAtFixedPosition(exerciseIdA));
      await tester.pumpAndSettle();

      final svgAfterA = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect((svgAfterA.bytesLoader as SvgAssetLoader).assetName, assetA);

      // 2) Meme tester, meme arbre, meme position : on substitue uniquement
      // l'exercice par B (recyclage par position, sans Key).
      await tester.pumpWidget(buildThumbnailAtFixedPosition(exerciseIdB));
      await tester.pumpAndSettle();

      final svgAfterB = tester.widget<SvgPicture>(find.byType(SvgPicture));
      // Doit afficher l'image de B : echoue sur le code actuel car
      // _imageSource garde l'ancienne valeur (celle de A).
      expect((svgAfterB.bytesLoader as SvgAssetLoader).assetName, assetB);
    });

    testWidgets(
        'ExerciseImageWidget affiche encore l\'image de l\'exercice A apres '
        'recyclage a position identique vers B (doit echouer sur le code '
        'actuel)', (WidgetTester tester) async {
      const exerciseIdA = 'recycled_position_widget_exercise_a';
      const exerciseIdB = 'recycled_position_widget_exercise_b';
      const assetA =
          'assets/exercise_images/recycled_position_widget_exercise_a.svg';
      const assetB =
          'assets/exercise_images/recycled_position_widget_exercise_b.svg';

      when(() => mockRepository.getImageSource(exerciseIdA))
          .thenAnswer((_) async => const ImageSource.asset(assetA));
      when(() => mockRepository.getImageSource(exerciseIdB))
          .thenAnswer((_) async => const ImageSource.asset(assetB));

      Widget buildWidgetAtFixedPosition(String exerciseId) {
        return Provider<ExerciseLibraryRepository>.value(
          value: mockRepository,
          child: MaterialApp(
            home: Scaffold(
              body: ExerciseImageWidget(
                exerciseId: exerciseId,
                size: 100,
              ),
            ),
          ),
        );
      }

      // 1) Premier affichage : l'exercice A occupe la position.
      await tester.pumpWidget(buildWidgetAtFixedPosition(exerciseIdA));
      await tester.pumpAndSettle();

      final svgAfterA = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect((svgAfterA.bytesLoader as SvgAssetLoader).assetName, assetA);

      // 2) Meme tester, meme arbre, meme position : on substitue uniquement
      // l'exercice par B (recyclage par position, sans Key).
      await tester.pumpWidget(buildWidgetAtFixedPosition(exerciseIdB));
      await tester.pumpAndSettle();

      final svgAfterB = tester.widget<SvgPicture>(find.byType(SvgPicture));
      // Doit afficher l'image de B : echoue sur le code actuel car
      // _imageSource garde l'ancienne valeur (celle de A).
      expect((svgAfterB.bytesLoader as SvgAssetLoader).assetName, assetB);
    });
  });
}
