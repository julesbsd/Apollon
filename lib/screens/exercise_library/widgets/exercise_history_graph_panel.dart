import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/services/statistics_service.dart';
import '../../../core/models/statistics.dart';
import '../../../core/models/workout_set.dart';
import '../../../core/theme/app_theme.dart';

// Type alias pour une entrée d'historique brute
typedef _HistoryEntry = ({
  DateTime date,
  String workoutId,
  List<WorkoutSet> sets,
  double maxWeight,
});

/// Panel glissant Historique ↔ Graphe de progression
/// Intégré dans l'écran de détail d'un exercice
class ExerciseHistoryGraphPanel extends StatefulWidget {
  final String exerciseId;
  final String exerciseName;
  final String userId;
  final StatisticsService statisticsService;

  const ExerciseHistoryGraphPanel({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    required this.userId,
    required this.statisticsService,
  });

  @override
  State<ExerciseHistoryGraphPanel> createState() =>
      _ExerciseHistoryGraphPanelState();
}

class _ExerciseHistoryGraphPanelState
    extends State<ExerciseHistoryGraphPanel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<ProgressDataPoint> _progressPoints = [];
  List<_HistoryEntry> _historyEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final raw = await widget.statisticsService.getExerciseRawHistory(
        widget.userId,
        widget.exerciseId,
        lastNWorkouts: 20,
      );
      if (mounted) {
        setState(() {
          _historyEntries = raw;
          _progressPoints = raw
              .map((e) => ProgressDataPoint(
                    date: e.date,
                    value: e.maxWeight,
                    workoutId: e.workoutId,
                  ))
              .toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onTabTap(int index) {
    if (index == _currentPage) return;
    setState(() => _currentPage = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.white.withValues(alpha: 0.95),
            blurRadius: 16,
            offset: const Offset(-6, -6),
          ),
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.65)
                : colorScheme.primary.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(6, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Sélecteur à glissière ──────────────────────
          _SliderTabBar(
            currentIndex: _currentPage,
            onTabTap: _onTabTap,
          ),
          const SizedBox(height: 20),

          // ── Contenu paginé ─────────────────────────────
          if (_isLoading)
            const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SizedBox(
              height: 270,
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _HistoryPage(entries: _historyEntries, theme: theme),
                  _ProgressPage(
                    dataPoints: _progressPoints,
                    theme: theme,
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// Sélecteur à glissière animée
// ═══════════════════════════════════════════════════════

class _SliderTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabTap;

  const _SliderTabBar({required this.currentIndex, required this.onTabTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colorScheme.surfaceVariant.withValues(alpha: 0.35)
            : colorScheme.surfaceVariant.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // Neumorphism creux : ombre interne simulée avec ombre externe inversée
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.55)
                : Colors.black.withValues(alpha: 0.10),
            blurRadius: 6,
            offset: const Offset(3, 3),
          ),
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.85),
            blurRadius: 6,
            offset: const Offset(-3, -3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Curseur animé
          AnimatedAlign(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            alignment:
                currentIndex == 0 ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Labels
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TabLabel(
                label: 'Historique',
                icon: Icons.history_rounded,
                isSelected: currentIndex == 0,
                onTap: () => onTabTap(0),
              ),
              _TabLabel(
                label: 'Progression',
                icon: Icons.trending_up_rounded,
                isSelected: currentIndex == 1,
                onTap: () => onTabTap(1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabLabel({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isSelected
        ? colorScheme.onPrimary
        : colorScheme.onSurface.withValues(alpha: 0.55);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// Page Historique
// ═══════════════════════════════════════════════════════

class _HistoryPage extends StatelessWidget {
  final List<_HistoryEntry> entries;
  final ThemeData theme;

  const _HistoryPage({required this.entries, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _emptyState(
        theme,
        icon: Icons.history_rounded,
        message: 'Pas encore de séance avec cet exercice',
      );
    }

    // Afficher uniquement la dernière séance (la plus récente)
    final last = entries.last;
    final colorScheme = theme.colorScheme;
    final dateStr = DateFormat('EEEE dd MMMM yyyy', 'fr_FR').format(last.date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête date
        Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 15, color: colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              dateStr,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.55),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Liste des séries
        ...last.sets.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          final w = s.weight % 1 == 0
              ? s.weight.toInt().toString()
              : s.weight.toString();

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                // Badge numéro de série
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${s.reps} répétitions',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${w} kg',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
// Page Graphe de progression
// ═══════════════════════════════════════════════════════

class _ProgressPage extends StatelessWidget {
  final List<ProgressDataPoint> dataPoints;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _ProgressPage({
    required this.dataPoints,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.length < 2) {
      return _emptyState(
        theme,
        icon: Icons.trending_up_rounded,
        message: dataPoints.isEmpty
            ? 'Effectue au moins une séance\npour voir ta progression'
            : 'Effectue encore des séances\npour voir l\'évolution du graphe',
      );
    }

    final minVal =
        dataPoints.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    final maxVal =
        dataPoints.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;
    final topPad = range > 0 ? range * 0.40 : 10.0;
    final bottomPad = range > 0 ? range * 0.15 : 5.0;
    final chartMinY = (minVal - bottomPad).floorToDouble();
    final chartMaxY = (maxVal + topPad).ceilToDouble();

    return Column(
      children: [
        SizedBox(
          height: 155,
          child: Padding(
            padding: const EdgeInsets.only(top: 12, right: 8),
            child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (dataPoints.length - 1).toDouble(),
              minY: chartMinY,
              maxY: chartMaxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: range > 0 ? range / 4 : 1.0,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: colorScheme.onSurface.withValues(alpha: 0.08),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false, reservedSize: 20)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: (dataPoints.length / 4).ceilToDouble(),
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= dataPoints.length) {
                        return const SizedBox();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          DateFormat('dd/MM').format(dataPoints[index].date),
                          style:
                              theme.textTheme.bodySmall?.copyWith(fontSize: 9),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    getTitlesWidget: (value, meta) => Text(
                      '${value.toInt()}kg',
                      style:
                          theme.textTheme.bodySmall?.copyWith(fontSize: 9),
                    ),
                  ),
                ),
              ),
              clipData: const FlClipData.none(),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: dataPoints
                      .asMap()
                      .entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                      .toList(),
                  isCurved: true,
                  color: AppTheme.primaryBlue,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                      radius: 4,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: AppTheme.primaryBlue,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.primaryBlue.withValues(alpha: 0.28),
                        AppTheme.primaryBlue.withValues(alpha: 0.04),
                      ],
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) =>
                      colorScheme.surface.withValues(alpha: 0.95),
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (spots) => spots.map((spot) {
                    final index = spot.x.toInt();
                    if (index >= dataPoints.length) return null;
                    final dp = dataPoints[index];
                    return LineTooltipItem(
                      '${dp.value.toInt()}kg\n${DateFormat('dd/MM/yy').format(dp.date)}',
                      TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
        ),  // Padding
        const SizedBox(height: 14),
        _buildProgressStats(),
      ],
    );
  }

  Widget _buildProgressStats() {
    final first = dataPoints.first.value;
    final last = dataPoints.last.value;
    final diff = last - first;
    final percent = first > 0 ? diff / first * 100 : 0.0;
    final isPositive = diff >= 0;
    final accent = isPositive ? AppTheme.successGreen : AppTheme.errorRed;
    final record =
        dataPoints.map((p) => p.value).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.9),
            blurRadius: 8,
            offset: const Offset(-4, -4),
          ),
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.5)
                : accent.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatChip(
            label: 'Départ',
            value: '${first.toInt()}kg',
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            theme: theme,
          ),
          _StatChip(
            label: 'Record',
            value: '${record.toInt()}kg',
            color: colorScheme.primary,
            theme: theme,
          ),
          _StatChip(
            label: 'Progression',
            value:
                '${isPositive ? '+' : ''}${diff.toStringAsFixed(1)}kg'
                ' (${isPositive ? '+' : ''}${percent.toStringAsFixed(0)}%)',
            color: accent,
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final ThemeData theme;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
// Utilitaire état vide
// ═══════════════════════════════════════════════════════

Widget _emptyState(ThemeData theme,
    {required IconData icon, required String message}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 44,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.22)),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
