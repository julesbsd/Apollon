import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/services/statistics_service.dart';
import '../../../core/models/statistics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/marble_card.dart';

/// Widget graphique barres volume hebdomadaire
/// Style inspiré de l'image: barres verticales bleues avec dégradé
class VolumeBarChart extends StatefulWidget {
  final String userId;
  final StatisticsService statisticsService;

  const VolumeBarChart({
    super.key,
    required this.userId,
    required this.statisticsService,
  });

  @override
  State<VolumeBarChart> createState() => _VolumeBarChartState();
}

class _VolumeBarChartState extends State<VolumeBarChart> {
  List<VolumeDataPoint> _dataPoints = [];
  bool _isLoading = true;
  int _selectedWeeks = 8; // 8 semaines par défaut

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    setState(() => _isLoading = true);

    try {
      final data = await widget.statisticsService.getVolumeByPeriod(
        widget.userId,
        weeks: _selectedWeeks,
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
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec sélecteur période
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Volume levé',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _buildPeriodSelector(theme),
              ],
            ),
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

            // Stats totales
            if (_dataPoints.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingL),
              _buildTotalStats(theme),
            ],
          ],
        ),
      ),
    );
  }

  /// Sélecteur de période
  Widget _buildPeriodSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        boxShadow: [
          // Neumorphism - Ombre claire en haut à gauche
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.8),
            blurRadius: 6,
            offset: const Offset(-3, -3),
          ),
          // Neumorphism - Ombre sombre en bas à droite
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.6)
                : theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedWeeks,
          isDense: true,
          icon: Icon(
            Icons.expand_more,
            color: theme.colorScheme.primary,
            size: 18,
          ),
          style: theme.textTheme.bodySmall,
          items: const [
            DropdownMenuItem(value: 4, child: Text('4 semaines')),
            DropdownMenuItem(value: 8, child: Text('8 semaines')),
            DropdownMenuItem(value: 12, child: Text('12 semaines')),
          ],
          onChanged: (int? newWeeks) {
            if (newWeeks != null) {
              setState(() {
                _selectedWeeks = newWeeks;
              });
              _loadChartData();
            }
          },
        ),
      ),
    );
  }

  /// Graphique barres verticales (style image)
  Widget _buildChart(ThemeData theme) {
    if (_dataPoints.isEmpty) return const SizedBox();

    final maxVolume = _dataPoints
        .map((p) => p.volume)
        .reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxVolume * 1.15, // 15% padding au-dessus
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => theme.colorScheme.surface.withValues(alpha: 0.9),
              tooltipRoundedRadius: AppTheme.radiusS,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                if (groupIndex >= _dataPoints.length) return null;
                
                final dataPoint = _dataPoints[groupIndex];
                return BarTooltipItem(
                  '${(dataPoint.volume / 1000).toStringAsFixed(1)}t\n${dataPoint.workoutCount} séance${dataPoint.workoutCount > 1 ? 's' : ''}',
                  TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= _dataPoints.length) {
                    return const SizedBox();
                  }
                  
                  // Afficher une date sur deux pour éviter le chevauchement
                  if (_dataPoints.length > 6 && index % 2 != 0) {
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
                    '${(value / 1000).toStringAsFixed(0)}t',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxVolume > 0 ? maxVolume / 4 : 1.0,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: _dataPoints.asMap().entries.map((entry) {
            final index = entry.key;
            final dataPoint = entry.value;
            
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: dataPoint.volume,
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppTheme.primaryBlue,
                      AppTheme.primaryBlueLight,
                    ],
                  ),
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusS),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Stats totales en bas
  Widget _buildTotalStats(ThemeData theme) {
    final totalVolume = _dataPoints.fold<double>(
      0,
      (sum, point) => sum + point.volume,
    );
    final totalWorkouts = _dataPoints.fold<int>(
      0,
      (sum, point) => sum + point.workoutCount,
    );
    final avgVolumePerWeek = totalVolume / _dataPoints.length;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            theme,
            'Total',
            '${(totalVolume / 1000).toStringAsFixed(1)}t',
          ),
          Container(
            height: 30,
            width: 1,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          _buildStatItem(
            theme,
            'Séances',
            '$totalWorkouts',
          ),
          Container(
            height: 30,
            width: 1,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          _buildStatItem(
            theme,
            'Moyenne/sem',
            '${(avgVolumePerWeek / 1000).toStringAsFixed(1)}t',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppTheme.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  /// État vide
  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Pas de données pour cette période',
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
