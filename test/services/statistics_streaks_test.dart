import 'package:flutter_test/flutter_test.dart';
import 'package:apollon/core/models/workout.dart';
import 'package:apollon/core/services/statistics_service.dart';

/// Crée une séance "completed" à une date donnée (les exercices n'importent pas ici).
Workout _w(DateTime date) => Workout(
      userId: 'u',
      date: date,
      status: WorkoutStatus.completed,
      exercises: const [],
    );

void main() {
  group('StatisticsService._calculateStreaks (jours calendaires)', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    test('liste vide -> 0/0', () {
      final r = StatisticsService.calculateStreaksForTest([]);
      expect(r['current'], 0);
      expect(r['best'], 0);
    });

    test('jours consécutifs comptés malgré des heures différentes (ex ancien bug .inDays)', () {
      final r = StatisticsService.calculateStreaksForTest([
        _w(today.add(const Duration(hours: 20))), // aujourd'hui 20h
        _w(today.subtract(const Duration(days: 1)).add(const Duration(hours: 8))), // hier 8h (~36h d'écart)
        _w(today.subtract(const Duration(days: 2)).add(const Duration(hours: 7))), // avant-hier
      ]);
      expect(r['current'], 3);
      expect(r['best'], 3);
    });

    test('plusieurs séances le même jour comptent pour 1 jour', () {
      final r = StatisticsService.calculateStreaksForTest([
        _w(today.add(const Duration(hours: 9))),
        _w(today.add(const Duration(hours: 18))),
        _w(today.subtract(const Duration(days: 1))),
      ]);
      expect(r['current'], 2); // hier + aujourd'hui
      expect(r['best'], 2);
    });

    test('un trou casse le streak courant mais best retient le maximum', () {
      final r = StatisticsService.calculateStreaksForTest([
        _w(today), // aujourd'hui (isolé)
        _w(today.subtract(const Duration(days: 5))),
        _w(today.subtract(const Duration(days: 6))),
        _w(today.subtract(const Duration(days: 7))),
      ]);
      expect(r['current'], 1); // seulement aujourd'hui (hier manquant)
      expect(r['best'], 3); // la série de 3 jours plus ancienne
    });

    test('streak courant invalide si la dernière séance est plus vieille qu\'hier', () {
      final r = StatisticsService.calculateStreaksForTest([
        _w(today.subtract(const Duration(days: 3))),
        _w(today.subtract(const Duration(days: 4))),
      ]);
      expect(r['current'], 0);
      expect(r['best'], 2);
    });
  });
}
