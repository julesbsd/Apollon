import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/statistics.dart';
import '../../core/services/statistics_service.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/marble_card.dart';
import 'widgets/exercise_progress_chart.dart';
import 'widgets/volume_bar_chart.dart';
import 'widgets/workout_heatmap_calendar.dart';

/// Écran Statistiques & Graphiques
/// Implémente EPIC-V2-1: Statistiques & Graphiques
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StatisticsService _statisticsService = StatisticsService();
  Statistics? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user == null) return;

    setState(() => _isLoading = true);

    try {
      final stats = await _statisticsService.getGlobalStatistics(
        authProvider.user!.uid,
      );
      if (mounted) {
        setState(() {
          _stats = stats;
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFF0F0F0),
      appBar: AppBar(
        title: Text(
          'Statistiques',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: _loadStatistics,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section KPIs globaux
                        _buildKPIsSection(context),
                        const SizedBox(height: AppTheme.spacingXL),

                        // Graphique progression exercice
                        _buildSectionTitle(context, 'Progression par exercice'),
                        const SizedBox(height: AppTheme.spacingM),
                        ExerciseProgressChart(
                          userId: context.read<AuthProvider>().user!.uid,
                          statisticsService: _statisticsService,
                        ),
                        const SizedBox(height: AppTheme.spacingXL),

                        // Graphique volume total
                        _buildSectionTitle(context, 'Volume hebdomadaire'),
                        const SizedBox(height: AppTheme.spacingM),
                        VolumeBarChart(
                          userId: context.read<AuthProvider>().user!.uid,
                          statisticsService: _statisticsService,
                        ),
                        const SizedBox(height: AppTheme.spacingXL),

                        // Calendrier heatmap
                        _buildSectionTitle(context, 'Calendrier d\'activité'),
                        const SizedBox(height: AppTheme.spacingM),
                        WorkoutHeatmapCalendar(
                          userId: context.read<AuthProvider>().user!.uid,
                        ),
                        const SizedBox(height: AppTheme.spacingL),
                      ],
                    ),
                  ),
                ),
    );
  }

  /// Section KPIs avec cartes statistiques
  Widget _buildKPIsSection(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppTheme.spacingM,
      crossAxisSpacing: AppTheme.spacingM,
      childAspectRatio: 0.85,
      children: [
        _buildKPICard(
          context,
          icon: Icons.fitness_center,
          title: 'Séances totales',
          value: '${_stats!.totalWorkouts}',
          subtitle: '${_stats!.monthWorkouts} ce mois',
          color: AppTheme.primaryBlue,
        ),
        _buildKPICard(
          context,
          icon: Icons.trending_up,
          title: 'Volume ce mois',
          value: _formatVolume(_stats!.totalVolume),
          subtitle: 'tonnes levées',
          color: AppTheme.successGreen,
        ),
        _buildKPICard(
          context,
          icon: Icons.local_fire_department,
          title: 'Streak actuel',
          value: '${_stats!.currentStreak}',
          subtitle: 'jours consécutifs',
          color: AppTheme.warningOrange,
        ),
        _buildKPICard(
          context,
          icon: Icons.star,
          title: 'Meilleur streak',
          value: '${_stats!.bestStreak}',
          subtitle: 'jours record',
          color: const Color(0xFFFFD700), // Gold
        ),
      ],
    );
  }

  /// Card KPI individuelle
  Widget _buildKPICard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return MarbleCard(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: AppTheme.spacingM),

            // Valeur et titre
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Titre de section
  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// État vide (pas de données)
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'Pas encore de statistiques',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Effectue ta première séance pour voir tes stats !',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Formater le volume (kg → tonnes)
  String _formatVolume(double volume) {
    if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}t';
    }
    return '${volume.toInt()}kg';
  }
}
