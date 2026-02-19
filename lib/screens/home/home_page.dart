import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/workout_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_orb_button.dart';
import '../../core/widgets/marble_card.dart';
import '../../core/utils/page_transitions.dart';
import '../exercise_library/exercise_library_selection_screen.dart';
import '../history/history_screen.dart';
import '../statistics/statistics_screen.dart';
import '../statistics/personal_records_screen.dart';

/// Page d'accueil Apollon V2 - Design Moderne Épuré
///
/// Migration du style Liquid Glass vers un design moderne minimaliste.
/// Implémentation du brief DESIGN_MODERNE_SPECIFICATION.md
///
/// Features:
/// - Background uniforme (pas de gradient animé)
/// - AppBar standard épurée
/// - Section progression avec CircularProgressCard
/// - Catégories avec ModernCategoryIcon
/// - Workouts populaires avec ModernImageCard
/// - Layout spacieux et aéré
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Messages motivants selon l'heure
  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 6) return "Séance de guerrier nocturne ! 🌙";
    if (hour < 12) return "Prêt à sculpter ta perfection ? 💪";
    if (hour < 18) return "L'après-midi parfait pour s'entraîner ⚡";
    if (hour < 22) return "Session du soir, puissance maximale 🔥";
    return "Courage pour cette séance tardive ! 🌟";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? AppTheme.neutralGray900
          : const Color(0xFFF0F0F0),
      appBar: _buildAppBar(context, authProvider),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(context, authProvider),
            const SizedBox(height: AppTheme.spacingXL),
            _buildProgressSection(context, workoutProvider),
            const SizedBox(height: AppTheme.spacingL),
            _buildPopularWorkoutsSection(context),
            const SizedBox(height: AppTheme.spacingL),
          ],
        ),
      ),
    );
  }

  /// AppBar moderne épurée
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    final theme = Theme.of(context);

    return AppBar(
      title: Text(
        'APOLLON',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: CircleAvatar(
            radius: 18,
            backgroundColor: theme.colorScheme.primaryContainer,
            backgroundImage: authProvider.user?.photoURL != null
                ? NetworkImage(authProvider.user!.photoURL!)
                : null,
            child: authProvider.user?.photoURL == null
                ? Icon(
                    Icons.person,
                    size: 20,
                    color: theme.colorScheme.primary,
                  )
                : null,
          ),
          onPressed: () {
            // TODO: Navigation vers profil
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Section hero avec salutation
  Widget _buildHeroSection(BuildContext context, AuthProvider authProvider) {
    final theme = Theme.of(context);
    final firstName =
        authProvider.user?.displayName?.split(' ').first ?? 'Athlète';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bienvenue, $firstName',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getGreetingMessage(),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  /// Section GlassOrbButton pour nouvelle séance
  Widget _buildProgressSection(
    BuildContext context,
    WorkoutProvider workoutProvider,
  ) {
    final hasActiveWorkout = workoutProvider.hasActiveWorkout;

    // Calcul progression (séance active : temps / 120 min)
    double progress = 0.0;

    if (hasActiveWorkout) {
      final elapsed = DateTime.now().difference(
        workoutProvider.currentWorkout!.createdAt,
      );
      progress = (elapsed.inSeconds / 7200).clamp(0.0, 1.0);
    }

    return GlassOrbButton(
      text: hasActiveWorkout ? 'Séance en cours' : 'Commencer une nouvelle séance',
      subtitle: hasActiveWorkout
          ? '${workoutProvider.currentWorkout!.totalExercises} exercices • ${workoutProvider.elapsedTimeFormatted}'
          : null,
      progress: progress,
      icon: hasActiveWorkout ? Icons.fitness_center : Icons.add_circle_outline,
      isActive: hasActiveWorkout,
      onPressed: () => _startWorkout(context, null),
    );
  }

  /// Section fonctionnalités avec MarbleCard
  Widget _buildPopularWorkoutsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fonctionnalités',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacingM),

        // Card Historique
        MarbleCard(
          onTap: () {
            Navigator.of(context).push(
              AppPageRoute.fadeSlide(
                builder: (context) => const HistoryScreen(),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.history,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Historique',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Consulte tes séances passées',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppTheme.spacingM),

        // Card Statistiques
        MarbleCard(
          onTap: () {
            Navigator.of(context).push(
              AppPageRoute.fadeSlide(
                builder: (context) => const StatisticsScreen(),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bar_chart,
                  color: AppTheme.successGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistiques',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Analyse tes performances',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppTheme.spacingM),

        // Card Records Personnels
        MarbleCard(
          onTap: () {
            final userId = context.read<AuthProvider>().user?.uid;
            if (userId != null) {
              Navigator.of(context).push(
                AppPageRoute.fadeSlide(
                  builder: (context) => PersonalRecordsScreen(userId: userId),
                ),
              );
            }
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFAA00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Records Personnels',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tes meilleures performances',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppTheme.spacingM),

        // Card Paramètres
        MarbleCard(
          onTap: () {
            // TODO: Navigation paramètres
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.settings,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paramètres',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Personnalise ton expérience',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Drawer pour navigation
  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: authProvider.user?.photoURL != null
                        ? NetworkImage(authProvider.user!.photoURL!)
                        : null,
                    child: authProvider.user?.photoURL == null
                        ? Icon(
                            Icons.person,
                            size: 30,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authProvider.user?.displayName ?? 'Athlète',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          authProvider.user?.email ?? '',
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historique'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  AppPageRoute.fadeSlide(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Statistiques'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  AppPageRoute.fadeSlide(
                    builder: (context) => const StatisticsScreen(),
                  ),
                );
              },
            ),
            SwitchListTile(
              secondary: Icon(
                themeProvider.isDarkMode
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              title: const Text('Thème sombre'),
              value: themeProvider.isDarkMode,
              onChanged: (bool value) async {
                // Change le thème sans fermer le drawer
                await themeProvider.toggleTheme();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigation paramètres
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppTheme.errorRed),
              title: const Text('Déconnexion'),
              textColor: AppTheme.errorRed,
              onTap: () async {
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Démarrer un workout
  Future<void> _startWorkout(BuildContext context, String? type) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final workoutProvider =
        Provider.of<WorkoutProvider>(context, listen: false);

    // Démarrer une nouvelle séance si pas déjà démarrée
    if (!workoutProvider.hasActiveWorkout) {
      workoutProvider.startNewWorkout(authProvider.user!.uid);
    }

    // Navigation vers catalogue Exercise Library
    // L'utilisateur sélectionne un exercice, puis WorkoutSessionScreen gère l'ajout
    Navigator.of(context).push(
      AppPageRoute.fadeSlide(
        builder: (context) => const ExerciseLibrarySelectionScreen(),
      ),
    );
  }
}
