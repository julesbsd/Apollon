import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/personal_record.dart';
import '../../core/services/statistics_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/marble_card.dart';

/// Écran listant tous les records personnels de l'utilisateur
class PersonalRecordsScreen extends StatefulWidget {
  final String userId;

  const PersonalRecordsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<PersonalRecordsScreen> createState() => _PersonalRecordsScreenState();
}

class _PersonalRecordsScreenState extends State<PersonalRecordsScreen> {
  final StatisticsService _statisticsService = StatisticsService();
  List<PersonalRecord> _records = [];
  bool _isLoading = true;
  String _sortBy = 'date'; // 'date' ou 'weight'

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);

    try {
      final records = await _statisticsService.getAllPersonalRecords(widget.userId);
      
      if (mounted) {
        setState(() {
          _records = records;
          _sortRecords();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _sortRecords() {
    if (_sortBy == 'date') {
      _records.sort((a, b) => b.achievedAt.compareTo(a.achievedAt));
    } else {
      _records.sort((a, b) => b.weight.compareTo(a.weight));
    }
  }

  void _changeSortOrder(String? value) {
    if (value != null) {
      setState(() {
        _sortBy = value;
        _sortRecords();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Records Personnels'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: _changeSortOrder,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'date',
                child: Text('Trier par date'),
              ),
              const PopupMenuItem(
                value: 'weight',
                child: Text('Trier par poids'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: _loadRecords,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      return _buildRecordCard(context, _records[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Aucun record personnel',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Complète des séances pour établir tes premiers records !',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, PersonalRecord record) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMM yyyy');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: MarbleCard(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            children: [
              // Icône trophée doré
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFAA00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  boxShadow: [
                    // Neumorphism - Effet doré brillant
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.6),
                      blurRadius: 8,
                      offset: const Offset(-3, -3),
                    ),
                    BoxShadow(
                      color: const Color(0xFFB8860B).withValues(alpha: 0.6),
                      blurRadius: 8,
                      offset: const Offset(3, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),

              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.exerciseName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 16,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${record.weight.toStringAsFixed(1)} kg × ${record.reps} reps',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateFormat.format(record.achievedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Badge "Record"
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFAA00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  boxShadow: [
                    // Neumorphism - Effet doré brillant
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.5),
                      blurRadius: 6,
                      offset: const Offset(-2, -2),
                    ),
                    BoxShadow(
                      color: const Color(0xFFB8860B).withValues(alpha: 0.5),
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Text(
                  'PR',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
