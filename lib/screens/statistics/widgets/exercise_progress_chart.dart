import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/services/statistics_service.dart';
import '../../../core/models/statistics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/marble_card.dart';
import '../../../core/models/exercise_library.dart';
import '../../../core/providers/exercise_library_provider.dart';

/// Widget graphique ligne progression par exercice
/// Style inspiré de l'image: ligne avec points, dégradé area chart
class ExerciseProgressChart extends StatefulWidget {
  final String userId;
  final StatisticsService statisticsService;

  const ExerciseProgressChart({
    super.key,
    required this.userId,
    required this.statisticsService,
  });

  @override
  State<ExerciseProgressChart> createState() => _ExerciseProgressChartState();
}

class _ExerciseProgressChartState extends State<ExerciseProgressChart> {
  List<ExerciseLibrary> _exercises = [];
  ExerciseLibrary? _selectedExercise;
  List<ProgressDataPoint> _dataPoints = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      final provider = context.read<ExerciseLibraryProvider>();
      if (provider.allExercises.isEmpty) {
        await provider.loadExercises();
      }
      final exercises = provider.allExercises;

      if (mounted) {
        setState(() {
          _exercises = exercises;
          if (exercises.isNotEmpty) {
            _selectedExercise = exercises.first;
            _loadChartData();
          } else {
            _isLoading = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadChartData() async {
    if (_selectedExercise == null) return;

    setState(() => _isLoading = true);

    try {
      final data = await widget.statisticsService.getExerciseProgressData(
        widget.userId,
        _selectedExercise!.id,
        lastNWorkouts: 20,
      );

      if (mounted) {
        setState(() {
          _dataPoints = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MarbleCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown sélection exercice
            _buildExerciseSelector(theme),
            const SizedBox(height: AppTheme.spacingL),

            // Graphique
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.spacingXL),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_dataPoints.isEmpty)
              _buildEmptyState(theme)
            else
              _buildChart(theme),

            // Stats progression
            if (_dataPoints.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingL),
              _buildProgressStats(theme),
            ],
          ],
        ),
      ),
    );
  }

  /// Dropdown pour sélectionner un exercice
  Widget _buildExerciseSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: [
          // Neumorphism - Ombre claire en haut à gauche
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.8),
            blurRadius: 8,
            offset: const Offset(-4, -4),
          ),
          // Neumorphism - Ombre sombre en bas à droite
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.6)
                : theme.colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ExerciseLibrary>(
          value: _selectedExercise,
          isExpanded: true,
          icon: Icon(Icons.expand_more, color: theme.colorScheme.primary),
          style: theme.textTheme.titleMedium,
          items: _exercises.map((exercise) {
            return DropdownMenuItem<ExerciseLibrary>(
              value: exercise,
              child: Text(
                exercise.name,
                style: theme.textTheme.bodyLarge,
              ),
            );
          }).toList(),
          onChanged: (ExerciseLibrary? newExercise) {
            if (newExercise != null) {
              setState(() {
                _selectedExercise = newExercise;
              });
              _loadChartData();
            }
          },
        ),
      ),
    );
  }

  /// Graphique ligne avec area gradient (style image)
  Widget _buildChart(ThemeData theme) {
    if (_dataPoints.isEmpty) return const SizedBox();

    final minValue = _dataPoints.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    final maxValue = _dataPoints.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;
    
    // Padding pour ne pas coller aux bords
    final chartMinY = (minValue - range * 0.1).floorToDouble();
    final chartMaxY = (maxValue + range * 0.1).ceilToDouble();

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (_dataPoints.length - 1).toDouble(),
          minY: chartMinY,
          maxY: chartMaxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: range > 0 ? range / 4 : 1.0,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: (_dataPoints.length / 4).ceilToDouble(),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= _dataPoints.length) {
                    return const SizedBox();
                  }
                  final date = _dataPoints[index].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('dd/MM').format(date),
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}kg',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _dataPoints
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
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: AppTheme.primaryBlue,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryBlue.withValues(alpha: 0.3),
                    AppTheme.primaryBlue.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => theme.colorScheme.surface.withValues(alpha: 0.9),
              tooltipRoundedRadius: AppTheme.radiusS,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  if (index >= _dataPoints.length) return null;
                  
                  final dataPoint = _dataPoints[index];
                  return LineTooltipItem(
                    '${dataPoint.value.toInt()}kg\n${DateFormat('dd/MM/yy').format(dataPoint.date)}',
                    TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Stats de progression en bas du graphique
  Widget _buildProgressStats(ThemeData theme) {
    if (_dataPoints.length < 2) return const SizedBox();

    final firstValue = _dataPoints.first.value;
    final lastValue = _dataPoints.last.value;
    final diff = lastValue - firstValue;
    final percentChange = (diff / firstValue * 100);
    final isPositive = diff >= 0;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: (isPositive ? AppTheme.successGreen : AppTheme.errorRed)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: [
          // Neumorphism - Ombre claire en haut à gauche
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.9),
            blurRadius: 10,
            offset: const Offset(-5, -5),
          ),
          // Neumorphism - Ombre sombre en bas à droite
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.5)
                : theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progression',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${isPositive ? '+' : ''}${diff.toStringAsFixed(1)}kg',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: isPositive ? AppTheme.successGreen : AppTheme.errorRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Variation',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${isPositive ? '+' : ''}${percentChange.toStringAsFixed(1)}%',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: isPositive ? AppTheme.successGreen : AppTheme.errorRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// État vide (pas de données pour cet exercice)
  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.timeline,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Pas de données pour cet exercice',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
