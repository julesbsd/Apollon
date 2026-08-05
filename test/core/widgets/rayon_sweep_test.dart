import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:apollon/core/widgets/rayon_sweep.dart';

void main() {
  group('RayonSweep', () {
    testWidgets('rend son enfant sans exception', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RayonSweep(
            trigger: false,
            child: Text('contenu'),
          ),
        ),
      );

      expect(find.text('contenu'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'un seul passage se produit sur trigger=true, sans boucle',
      (tester) async {
        const duration = Duration(milliseconds: 100);
        var trigger = false;

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: RayonSweep(
                    duration: duration,
                    trigger: trigger,
                    child: const SizedBox(width: 200, height: 100),
                  ),
                );
              },
            ),
          ),
        );

        // Etat initial : trigger=false, aucun passage n'a ete declenche.
        await tester.pump();

        // On declenche le passage.
        trigger = true;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RayonSweep(
                duration: duration,
                trigger: trigger,
                child: const SizedBox(width: 200, height: 100),
              ),
            ),
          ),
        );

        // L'animation doit etre en cours juste apres le declenchement.
        await tester.pump(const Duration(milliseconds: 30));
        expect(tester.hasRunningAnimations, isTrue);

        // On avance au-dela de la duree du passage : l'animation doit
        // s'etre terminee et NE PAS avoir boucle (pas de nouvelle frame
        // programmee, pumpAndSettle se termine sans timeout).
        await tester.pumpAndSettle(const Duration(milliseconds: 50));

        expect(tester.hasRunningAnimations, isFalse);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'aucune animation ne demarre si disableAnimations est actif',
      (tester) async {
        const duration = Duration(milliseconds: 100);

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: MaterialApp(
              home: Scaffold(
                body: RayonSweep(
                  duration: duration,
                  trigger: true,
                  child: const SizedBox(width: 200, height: 100),
                ),
              ),
            ),
          ),
        );

        // Le passage a ete "saute" au montage : aucune animation ne doit
        // etre en cours, meme immediatement apres le premier pump.
        await tester.pump();
        expect(tester.hasRunningAnimations, isFalse);

        // On avance le temps : toujours aucune animation en cours.
        await tester.pump(const Duration(milliseconds: 200));
        expect(tester.hasRunningAnimations, isFalse);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
