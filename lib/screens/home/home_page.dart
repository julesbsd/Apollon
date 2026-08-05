import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/workout_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/services/workout_service.dart';
import '../../core/services/statistics_service.dart';
import '../../core/models/workout.dart';
import '../../core/models/statistics.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_orb_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state_card.dart';
import '../../core/utils/page_transitions.dart';
import '../exercise_library/exercise_library_selection_screen.dart';
import '../history/history_screen.dart';
import '../history/workout_detail_screen.dart';
import '../statistics/statistics_screen.dart';
import '../statistics/personal_records_screen.dart';

/// Page d'accueil Apollon - direction "Marbre & Lumiere".
///
/// Composition tenue sur UN seul ecran (maquette section 02, "Ecran A -
/// Accueil", verifiee ligne a ligne dans le HTML extrait) : bandeau
/// (wordmark + avatar), salutation, orbe "Nouvelle seance", triptyque de
/// statistiques chiffrees (Seances / Volume / Records), puis les derniers
/// entrainements. La navigation Historique/Statistiques/Records reste
/// accessible depuis le tiroir plutot que de dupliquer des cartes de
/// navigation qui n'existent pas dans la maquette.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WorkoutService _workoutService = WorkoutService();
  final StatisticsService _statisticsService = StatisticsService();
  // Cle de Scaffold : le context de build() est un ANCETRE du Scaffold qu'il
  // retourne, pas un descendant - Scaffold.of(context) a l'interieur de ce
  // meme build() ne trouve donc rien et l'ouverture du tiroir echoue. La
  // cle permet d'ouvrir le tiroir sans dependre d'un Scaffold.of() mal
  // positionne (bug reel corrige).
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // RG-004 / EC-002: reprendre une séance draft interrompue + purger les vieux drafts.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userId = context.read<AuthProvider>().user?.uid;
      if (userId != null) {
        context.read<WorkoutProvider>().restoreDraftIfAny(userId);
      }
    });
  }

  /// Message d'accroche selon l'heure - zero emoji (Mantra IA-23).
  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Séance de guerrier nocturne.';
    if (hour < 12) return 'Prêt à sculpter ta perfection ?';
    if (hour < 18) return "L'après-midi parfait pour s'entraîner.";
    if (hour < 22) return 'Session du soir, puissance maximale.';
    return 'Courage pour cette séance tardive.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context, authProvider, isDark),
              const SizedBox(height: 26),
              _buildGreeting(context, authProvider, isDark),
              const SizedBox(height: 30),
              // Seul l'orbe depend du chrono -> Consumer cible pour ne pas
              // reconstruire l'ecran entier chaque seconde.
              Consumer<WorkoutProvider>(
                builder: (context, workoutProvider, _) =>
                    _buildProgressSection(context, workoutProvider),
              ),
              const SizedBox(height: 26),
              _buildStatsTriptych(context, isDark),
              const SizedBox(height: 26),
              _buildRecentWorkoutsSection(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  /// Bandeau : bouton menu (ouvre le tiroir), symbole + wordmark APOLLON
  /// (Cinzel, +0.30em, filet d'or dessous), avatar a bordure or.
  ///
  /// Le symbole utilise la variante monochrome adaptee au theme (trace
  /// sombre #141B2B sur fond clair, trace blanc sur fond sombre) - livree
  /// par Claude Design specifiquement pour ces petits contextes, distincte
  /// du PNG plein-fond reserve a l'icone d'application.
  Widget _buildTopBar(BuildContext context, AuthProvider authProvider, bool isDark) {
    final gold = isDark ? AppTheme.accentGoldLine : AppTheme.lightAccentGoldLine;
    final onBackground = isDark ? AppTheme.darkOnBackground : AppTheme.lightOnBackground;

    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(Icons.menu, color: onBackground, size: 22),
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  isDark
                      ? 'assets/branding/apollon-monochrome-claire.png'
                      : 'assets/branding/apollon-monochrome-sombre.png',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 8),
                Text('APOLLON', style: AppTheme.wordmark(onBackground)),
              ],
            ),
            const SizedBox(height: 4),
            Container(width: 74, height: 1, color: gold.withValues(alpha: 0.6)),
          ],
        ),
        const Spacer(),
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightSurfaceVariant,
              border: Border.all(color: gold.withValues(alpha: 0.55), width: 1),
              image: authProvider.user?.photoURL != null
                  ? DecorationImage(image: NetworkImage(authProvider.user!.photoURL!), fit: BoxFit.cover)
                  : null,
            ),
            child: authProvider.user?.photoURL == null
                ? Icon(Icons.person, size: 18, color: isDark ? AppTheme.accentGold : AppTheme.lightAccentGold)
                : null,
          ),
        ),
      ],
    );
  }

  /// Salutation : titre d'ecran Cinzel + sous-titre Manrope attenue.
  Widget _buildGreeting(BuildContext context, AuthProvider authProvider, bool isDark) {
    final firstName = authProvider.user?.displayName?.split(' ').first ?? 'Athlète';
    final onBackground = isDark ? AppTheme.darkOnBackground : AppTheme.lightOnBackground;
    final muted = isDark ? AppTheme.darkOnSurfaceMuted : AppTheme.lightOnSurfaceMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bienvenue, $firstName', style: AppTheme.screenTitle(onBackground)),
        const SizedBox(height: 6),
        Text(_getGreetingMessage(), style: TextStyle(fontSize: 14, color: muted, fontWeight: FontWeight.w500)),
      ],
    );
  }

  /// Orbe "Nouvelle seance" - action heros de l'ecran (GlassOrbButton).
  Widget _buildProgressSection(BuildContext context, WorkoutProvider workoutProvider) {
    final hasActiveWorkout = workoutProvider.hasActiveWorkout;

    double progress = 0.0;
    if (hasActiveWorkout) {
      final elapsed = DateTime.now().difference(workoutProvider.currentWorkout!.createdAt);
      progress = (elapsed.inSeconds / 7200).clamp(0.0, 1.0);
    }

    return GlassOrbButton(
      text: hasActiveWorkout ? 'Séance en cours' : 'Nouvelle séance',
      subtitle: hasActiveWorkout
          ? '${workoutProvider.currentWorkout!.totalExercises} exercices • ${workoutProvider.elapsedTimeFormatted}'
          : null,
      progress: progress,
      icon: hasActiveWorkout ? Icons.fitness_center : Icons.add_circle_outline,
      isActive: hasActiveWorkout,
      onPressed: () => _startWorkout(context),
    );
  }

  /// Triptyque de statistiques chiffrees (Seances / Volume / Records) -
  /// fidele a la maquette "Ecran A" (grid 3 colonnes apres l'orbe). Le
  /// volume affiche est celui du mois en cours (meme donnee que
  /// [Statistics.totalVolume], deja consommee ailleurs dans l'app - pas de
  /// nouveau calcul invente). Records = nombre d'exercices distincts avec
  /// un record personnel (dedoublonne par [StatisticsService.getAllPersonalRecords]).
  Widget _buildStatsTriptych(BuildContext context, bool isDark) {
    final userId = context.read<AuthProvider>().user?.uid;
    if (userId == null) return const SizedBox.shrink();

    return FutureBuilder<(Statistics, int)>(
      future: _loadStatsTriptychData(userId),
      builder: (context, snapshot) {
        final stats = snapshot.data?.$1 ?? Statistics.empty();
        final recordsCount = snapshot.data?.$2 ?? 0;

        return Row(
          children: [
            Expanded(
              child: _StatTile(
                value: '${stats.totalWorkouts}',
                label: 'SÉANCES',
                isDark: isDark,
                accent: false,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                value: _formatVolume(stats.totalVolume),
                label: 'VOLUME',
                isDark: isDark,
                accent: false,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                value: '$recordsCount',
                label: 'RECORDS',
                isDark: isDark,
                accent: true,
                onTap: () => Navigator.of(context).push(
                  AppPageRoute.fadeSlide(builder: (context) => PersonalRecordsScreen(userId: userId)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Charge en parallele les stats globales et les records, combines dans
  /// un seul Future pour eviter deux FutureBuilder imbriques (et donc deux
  /// re-builds/sauts de layout independants) sur le triptyque.
  Future<(Statistics, int)> _loadStatsTriptychData(String userId) async {
    final results = await Future.wait([
      _statisticsService.getGlobalStatistics(userId),
      _statisticsService.getAllPersonalRecords(userId),
    ]);
    final stats = results[0] as Statistics;
    final records = results[1] as List<dynamic>;
    return (stats, records.length);
  }

  /// Formate un volume en kg, en tonnes ("5.2t") au-dela de 1000 kg -
  /// convention deja utilisee dans la maquette ("5.2t VOLUME").
  static String _formatVolume(double volumeKg) {
    if (volumeKg >= 1000) {
      return '${(volumeKg / 1000).toStringAsFixed(1)}t';
    }
    return volumeKg.toStringAsFixed(0);
  }

  /// Section "Derniers entrainements" - 2 dernieres seances terminees.
  Widget _buildRecentWorkoutsSection(BuildContext context, bool isDark) {
    final userId = context.read<AuthProvider>().user?.uid;
    final muted = isDark ? AppTheme.darkOnSurfaceMuted : AppTheme.lightOnSurfaceMuted;

    if (userId == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DERNIERS ENTRAÎNEMENTS', style: AppTheme.labelSecondary(muted)),
        const SizedBox(height: 11),
        StreamBuilder<List<Workout>>(
          stream: _workoutService.getCompletedWorkouts(userId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
            final recent = snapshot.data!.take(2).toList();
            if (recent.isEmpty) {
              return const EmptyStateCard(
                title: 'Pas de séance pour l\'instant',
                message: 'Ta première séance apparaîtra ici.',
              );
            }
            return Column(
              children: [
                for (final workout in recent) ...[
                  _RecentWorkoutTile(workout: workout, isDark: isDark),
                  const SizedBox(height: 10),
                ],
              ],
            );
          },
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
            ListTile(
              leading: const Icon(Icons.emoji_events),
              title: const Text('Records personnels'),
              onTap: () {
                Navigator.pop(context);
                final userId = authProvider.user?.uid;
                if (userId != null) {
                  Navigator.of(context).push(
                    AppPageRoute.fadeSlide(
                      builder: (context) => PersonalRecordsScreen(userId: userId),
                    ),
                  );
                }
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
  Future<void> _startWorkout(BuildContext context) async {
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

/// Tuile du triptyque de statistiques (spec maquette "Ecran A", grid 3
/// colonnes apres l'orbe) : chiffre en JetBrains Mono 24px/800, libelle en
/// capitales attenuees. La tuile Records porte l'accent or (bordure +
/// texte) et est cliquable vers l'ecran des records - les deux autres sont
/// de simple lecture, sans navigation (fidele a la maquette : seul le grand
/// chiffre compte ici, pas une carte de navigation generique).
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.isDark,
    required this.accent,
    this.onTap,
  });

  final String value;
  final String label;
  final bool isDark;
  final bool accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final onBackground = isDark ? AppTheme.darkOnBackground : AppTheme.lightOnBackground;
    final muted = isDark ? AppTheme.darkOnSurfaceMuted : AppTheme.lightOnSurfaceMuted;
    final gold = isDark ? AppTheme.accentGold : AppTheme.lightAccentGold;
    final goldLine = isDark ? AppTheme.accentGoldLine : AppTheme.lightAccentGoldLine;

    final card = AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTheme.timerNumber(accent ? gold : onBackground).copyWith(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.08 * 10,
              color: accent ? gold : muted,
            ),
          ),
        ],
      ),
    );

    if (!accent) return card;

    // Bordure or additionnelle pour la tuile Records (spec maquette :
    // border rgba(138,106,47,.34)) - AppCard n'expose pas de couleur de
    // bordure custom, on la superpose donc via un Container englobant de
    // meme rayon plutot que d'etendre l'API generique d'AppCard pour un
    // seul appelant.
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(color: goldLine.withValues(alpha: 0.34)),
      ),
      child: card,
    );
  }
}

/// Ligne d'historique compacte (spec maquette d1-history-item) : nom +
/// muscles principaux a gauche, date/duree en Mono attenue a droite, fleche
/// primaire.
class _RecentWorkoutTile extends StatelessWidget {
  const _RecentWorkoutTile({required this.workout, required this.isDark});

  final Workout workout;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final onBackground = isDark ? AppTheme.darkOnBackground : AppTheme.lightOnBackground;
    final muted = isDark ? AppTheme.darkOnSurfaceMuted : AppTheme.lightOnSurfaceMuted;
    final primary = isDark ? AppTheme.primaryBlue : AppTheme.lightPrimaryBlue;
    final exerciseNames = workout.exercises.map((e) => e.exerciseName).take(2).join(', ');

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      onTap: () => Navigator.of(context).push(
        AppPageRoute.fadeSlide(builder: (context) => WorkoutDetailScreen(workout: workout)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exerciseNames.isEmpty ? 'Séance' : exerciseNames,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: onBackground),
                ),
                const SizedBox(height: 3),
                Text(
                  '${workout.displayDate} • ${workout.totalExercises} exercices • ${workout.displayDuration}',
                  style: AppTheme.timerNumber(muted).copyWith(fontSize: 11.5, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: primary, size: 20),
        ],
      ),
    );
  }
}
