import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/workout.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/marble_card.dart';

/// Widget affichant un calendrier heatmap des séances
/// Style inspiré de GitHub contribution graph
class WorkoutHeatmapCalendar extends StatefulWidget {
  final String userId;

  const WorkoutHeatmapCalendar({
    super.key,
    required this.userId,
  });

  @override
  State<WorkoutHeatmapCalendar> createState() => _WorkoutHeatmapCalendarState();
}

class _WorkoutHeatmapCalendarState extends State<WorkoutHeatmapCalendar> {
  Map<DateTime, int> _workoutData = {};
  bool _isLoading = true;
  int _currentStreak = 0;
  int _bestStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadWorkoutData();
  }

  Future<void> _loadWorkoutData() async {
    setState(() => _isLoading = true);

    try {
      // Récupérer les séances des 12 derniers mois
      final now = DateTime.now();
      final startDate = DateTime(now.year - 1, now.month, now.day);

      final workoutsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('workouts')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      final workouts = workoutsSnapshot.docs
          .map((doc) => Workout.fromFirestore(doc))
          .where((workout) => workout.status == WorkoutStatus.completed) // Filtrer côté client
          .toList();

      // Grouper par date (jour uniquement, sans heure)
      final Map<DateTime, int> data = {};
      for (final workout in workouts) {
        final dateKey = DateTime(
          workout.date.year,
          workout.date.month,
          workout.date.day,
        );
        data[dateKey] = (data[dateKey] ?? 0) + 1;
      }

      // Calculer les streaks
      final streaks = _calculateStreaks(workouts);

      if (mounted) {
        setState(() {
          _workoutData = data;
          _currentStreak = streaks['current']!;
          _bestStreak = streaks['best']!;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Map<String, int> _calculateStreaks(List<Workout> workouts) {
    if (workouts.isEmpty) return {'current': 0, 'best': 0};

    // Trier par date décroissante
    workouts.sort((a, b) => b.date.compareTo(a.date));

    // Extraire les dates uniques (jours)
    final uniqueDates = workouts
        .map((w) => DateTime(w.date.year, w.date.month, w.date.day))
        .toSet()
        .toList();
    uniqueDates.sort((a, b) => b.compareTo(a));

    int currentStreak = 0;
    int bestStreak = 0;
    int tempStreak = 1;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Vérifier si le streak actuel est valide (aujourd'hui ou hier)
    if (uniqueDates.isNotEmpty) {
      final lastWorkoutDate = uniqueDates.first;
      final daysSinceLastWorkout = todayDate.difference(lastWorkoutDate).inDays;

      if (daysSinceLastWorkout <= 1) {
        currentStreak = 1;

        // Calculer le streak actuel
        for (int i = 1; i < uniqueDates.length; i++) {
          final diff = uniqueDates[i - 1].difference(uniqueDates[i]).inDays;
          if (diff == 1) {
            currentStreak++;
          } else {
            break;
          }
        }
      }

      // Calculer le meilleur streak
      bestStreak = currentStreak;
      for (int i = 1; i < uniqueDates.length; i++) {
        final diff = uniqueDates[i - 1].difference(uniqueDates[i]).inDays;
        if (diff == 1) {
          tempStreak++;
          if (tempStreak > bestStreak) {
            bestStreak = tempStreak;
          }
        } else {
          tempStreak = 1;
        }
      }
    }

    return {'current': currentStreak, 'best': bestStreak};
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const MarbleCard(
        child: SizedBox(
          height: 300,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MarbleCard(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  color: AppTheme.primaryBlue,
                  size: 24,
                ),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  'Calendrier d\'activité',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),

            // Heatmap
            HeatMapCalendar(
              datasets: _workoutData,
              colorMode: ColorMode.opacity,
              defaultColor: theme.colorScheme.surfaceContainerHighest,
              flexible: true,
              colorsets: {
                1: AppTheme.primaryBlue,
                2: AppTheme.successGreen,
                3: AppTheme.warningOrange,
                4: const Color(0xFFFFD700),
              },
              onClick: (date) {
                final workoutCount = _workoutData[date] ?? 0;
                if (workoutCount > 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${DateFormat('d MMMM yyyy').format(date)} : $workoutCount séance${workoutCount > 1 ? 's' : ''}',
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Stats streaks
            Row(
              children: [
                Expanded(
                  child: _buildStreakCard(
                    context,
                    icon: Icons.local_fire_department,
                    label: 'Streak actuel',
                    value: '$_currentStreak',
                    color: AppTheme.warningOrange,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: _buildStreakCard(
                    context,
                    icon: Icons.star,
                    label: 'Meilleur streak',
                    value: '$_bestStreak',
                    color: const Color(0xFFFFD700),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingM),

            // Légende
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Moins',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                _buildLegendSquare(theme, theme.colorScheme.surfaceContainerHighest),
                const SizedBox(width: 4),
                _buildLegendSquare(theme, AppTheme.primaryBlue),
                const SizedBox(width: 4),
                _buildLegendSquare(theme, AppTheme.successGreen),
                const SizedBox(width: 4),
                _buildLegendSquare(theme, AppTheme.warningOrange),
                const SizedBox(width: 4),
                _buildLegendSquare(theme, const Color(0xFFFFD700)),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  'Plus',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? theme.colorScheme.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          // Neumorphism - Ombre claire en haut à gauche
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.06)
                : Colors.white.withOpacity(0.9),
            blurRadius: 10,
            offset: const Offset(-5, -5),
          ),
          // Neumorphism - Ombre sombre en bas à droite
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withOpacity(0.5)
                : theme.colorScheme.primary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendSquare(ThemeData theme, Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.2),
          width: 0.5,
        ),
      ),
    );
  }
}
