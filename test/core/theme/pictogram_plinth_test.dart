import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:apollon/core/theme/app_theme.dart';
import 'package:apollon/core/widgets/pictogram_plinth.dart';

void main() {
  Future<List<Color>> gradientColorsFor(WidgetTester tester, Brightness brightness) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: brightness == Brightness.dark ? AppTheme.darkTheme : AppTheme.lightTheme,
        home: const Scaffold(
          body: PictogramPlinth(
            width: 58,
            height: 58,
            child: Icon(Icons.fitness_center),
          ),
        ),
      ),
    );
    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    return decoration.gradient is LinearGradient
        ? (decoration.gradient as LinearGradient).colors
        : <Color>[];
  }

  testWidgets(
    'le socle clair n\'utilise ni lightSurface ni lightSurfaceVariant, et porte le degrade ardoise clair',
    (tester) async {
      final colors = await gradientColorsFor(tester, Brightness.light);

      // Aucune des couleurs composant le fond du socle ne doit etre
      // lightSurface (blanc casse) ni lightSurfaceVariant : le pictogramme
      // doit toujours reposer sur le socle ardoise dedie, jamais directement
      // sur une surface de carte/page (defaut reel corrige par ce widget).
      for (final color in colors) {
        expect(color, isNot(equals(AppTheme.lightSurface)));
        expect(color, isNot(equals(AppTheme.lightSurfaceVariant)));
      }

      expect(colors, contains(AppTheme.pictogramPlinthTopLight));
      expect(colors, contains(AppTheme.pictogramPlinthBottomLight));
    },
  );

  testWidgets(
    'le socle sombre porte le degrade ardoise sombre',
    (tester) async {
      final colors = await gradientColorsFor(tester, Brightness.dark);

      for (final color in colors) {
        expect(color, isNot(equals(AppTheme.lightSurface)));
        expect(color, isNot(equals(AppTheme.lightSurfaceVariant)));
      }

      expect(colors, contains(AppTheme.pictogramPlinthTopDark));
      expect(colors, contains(AppTheme.pictogramPlinthBottomDark));
    },
  );
}
