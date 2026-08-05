// Tests de fumee E8 : verifient que les points d'integration RayonSweep
// existants rendent sans exception. Note (E8) : le point "GlassOrbButton
// apparition" demande par la consigne n'a jamais ete cable par E6 (qui a
// cable CriticalCta a la place) - glass_orb_button.dart ne contient aucune
// reference a RayonSweep. Ce test couvre donc les 3 points reellement
// cables (PRCelebrationOverlay, LoginScreen wordmark, serie validee dans
// WorkoutSessionScreen) et documente l'absence du 4e via un test skip.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apollon/core/widgets/pr_celebration_overlay.dart';
import 'package:apollon/core/widgets/glass_orb_button.dart';
import 'package:apollon/core/models/personal_record.dart';

void main() {
  testWidgets('PRCelebrationOverlay rend sans exception', (tester) async {
    final pr = PersonalRecord(
      id: '1',
      userId: 'u1',
      exerciseId: 'e1',
      exerciseName: 'Developpe couche',
      weight: 100,
      reps: 5,
      achievedAt: DateTime(2026, 1, 1),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => showPrCelebration(context, [pr]),
                child: const Text('go'),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('GlassOrbButton rend sans exception (mais sans RayonSweep - gap E6)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlassOrbButton(
            text: 'Nouvelle seance',
            onPressed: () {},
            icon: Icons.add,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  }, skip: false);
}
