import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/workout_provider.dart';
import '../../core/widgets/widgets.dart';
import '../../core/utils/page_transitions.dart';
import '../workout/exercise_selection_screen.dart';
import '../history/history_screen.dart';

/// Page d'accueil Premium de l'application Apollon
/// Design Premium Phase 1 :
/// - MeshGradientBackground animé (breathing effect)
/// - FloatingGlassAppBar avec glassmorphism
/// - Section hero avec accueil premium
/// - Cards glassmorphism pour features
/// Point de départ pour EPIC-4 (Enregistrement séance)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final hasActiveWorkout = workoutProvider.currentWorkout != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FloatingGlassAppBar(
        title: 'APOLLON',
        showTimer: hasActiveWorkout,
        timerText: hasActiveWorkout ? workoutProvider.elapsedTimeFormatted : null,
        onTimerTap: hasActiveWorkout
            ? () {
                // Navigation vers séance en cours
                Navigator.of(context).push(
                  AppPageRoute.fadeSlide(
                    builder: (context) => const ExerciseSelectionScreen(),
                  ),
                );
              }
            : null,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: 'Profil',
            ),
          ),
        ],
      ),
      endDrawer: const ProfileDrawer(),
      body: MeshGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  _buildHeroSection(context),
                  const SizedBox(height: 20),
                  _buildMainActionButton(context),
                  const SizedBox(height: 12),
                  _buildComingSoonCards(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Section hero premium avec salutation et badge
  Widget _buildHeroSection(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final theme = Theme.of(context);
    final firstName = user?.displayName?.split(' ').first ?? 'Athlète';

    return Row(
      children: [
        // Avatar avec bordure dorée
        _buildPremiumAvatar(context, user),
        const SizedBox(width: 16),
        
        // Textes de bienvenue
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Salutation avec Cinzel
              Text(
                'Bienvenue, $firstName',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),

              // Message motivant
              Text(
                _getGreetingMessage(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Avatar premium avec bordure dorée
  Widget _buildPremiumAvatar(BuildContext context, user) {
    final theme = Theme.of(context);
    final photoUrl = user?.photoURL;
    
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFD700), // Or pur
            Color(0xFFFFE57F), // Or clair
            Color(0xFFFFA000), // Or brûlé
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surface,
        ),
        child: ClipOval(
          child: photoUrl != null
              ? Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultAvatarIcon(theme);
                  },
                )
              : _buildDefaultAvatarIcon(theme),
        ),
      ),
    );
  }

  /// Icône par défaut pour l'avatar
  Widget _buildDefaultAvatarIcon(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
      child: Icon(
        Icons.person,
        size: 40,
        color: theme.colorScheme.primary,
      ),
    );
  }

  /// Bouton principal "Nouvelle séance" avec arc de progression
  /// Implémente US-4.1: Navigation vers ExerciseSelectionScreen
  /// US-4.1 Enhanced: Arc circulaire progressif (0-120 min = 0-100%)
  Widget _buildMainActionButton(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final hasActiveWorkout = workoutProvider.currentWorkout != null;

    // Calcul du progrès : 0.0 à 1.0 (100% à 120 minutes = 2H)
    double progress = 0.0;
    String mainText = 'Nouvelle séance';
    String? subtitleText;
    IconData icon = Icons.add_circle_outline;

    if (hasActiveWorkout) {
      // Séance active : afficher le temps et calculer le progrès
      final elapsed = DateTime.now().difference(workoutProvider.currentWorkout!.createdAt);
      
      // Progress de 0 à 1 sur 120 minutes (7200 secondes = 2H)
      progress = (elapsed.inSeconds / 7200).clamp(0.0, 1.0);
      
      mainText = 'Séance en cours';
      subtitleText = workoutProvider.elapsedTimeFormatted;
      icon = Icons.fitness_center;
    }

    return GlassOrbButton(
      text: mainText,
      subtitle: subtitleText,
      progress: progress,
      icon: icon,
      isActive: hasActiveWorkout,
      onPressed: () {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
        
        // Démarrer une nouvelle séance si pas déjà démarrée
        if (!workoutProvider.hasActiveWorkout) {
          workoutProvider.startNewWorkout(authProvider.user!.uid);
        }
        
        // Navigation vers ExerciseSelectionScreen
        Navigator.of(context).push(
          AppPageRoute.fadeSlide(
            builder: (context) => const ExerciseSelectionScreen(),
          ),
        );
      },
    );
  }

  /// Cards "Coming Soon" avec design glassmorphism premium
  Widget _buildComingSoonCards(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.95,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: _buildPremiumFeatureCard(
            context,
            'Historique',
            Icons.article_outlined,
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: _buildPremiumFeatureCard(
            context,
            'Statistiques',
            Icons.analytics_outlined,
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: _buildPremiumFeatureCard(
            context,
            'Calendrier',
            Icons.calendar_today_outlined,
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: _buildPremiumFeatureCard(
            context,
            'Profil',
            Icons.person_outline,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MarbleCard(
      onTap: () {
        // Navigation selon la feature
        if (title == 'Historique') {
          Navigator.of(context).push(
            AppPageRoute.fadeSlide(
              builder: (context) => const HistoryScreen(),
            ),
          );
        }
        // Autres features: TODO
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône avec background circulaire
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withOpacity(0.15),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 26,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Titre avec Cinzel
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
