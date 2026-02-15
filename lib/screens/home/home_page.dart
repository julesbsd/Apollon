import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/workout_provider.dart';
import '../../core/widgets/widgets.dart';
import '../../core/utils/page_transitions.dart';
import '../workout/exercise_selection_screen.dart';

/// Page d'accueil de l'application Apollon
/// Implémente US-1.3: Bouton de déconnexion avec confirmation
/// Implémente US-3.3: Theme switcher accessible depuis menu
/// Point de départ pour EPIC-4 (Enregistrement séance)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('APOLLON'),
        centerTitle: true,
        backgroundColor: colorScheme.surface.withOpacity(0.8),
        elevation: 0,
        actions: [
          // Bouton pour ouvrir le drawer
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: 'Profil',
            ),
          ),
        ],
      ),
      endDrawer: const ProfileDrawer(),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(context),
                const SizedBox(height: 48),
                // Gros bouton central avec arc de progression
                _buildMainActionButton(context),
                const SizedBox(height: 32),
                _buildComingSoonCards(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Section de bienvenue avec nom de l'utilisateur
  Widget _buildWelcomeSection(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          'Bonjour, ',
          style: TextStyle(
            fontSize: 24,
            color: colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
        Text(
          user?.displayName?.split(' ').first ?? 'Athlète',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  /// Bouton principal "Nouvelle séance" avec arc de progression
  /// Implémente US-4.1: Navigation vers ExerciseSelectionScreen
  /// US-4.1 Enhanced: Arc circulaire progressif (0-60 min = 0-100%)
  Widget _buildMainActionButton(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final hasActiveWorkout = workoutProvider.currentWorkout != null;

    // Calcul du progrès : 0.0 à 1.0 (100% à 60 minutes)
    double progress = 0.0;
    String mainText = 'Nouvelle séance';
    String? subtitleText;
    IconData icon = Icons.add_circle_outline;

    if (hasActiveWorkout) {
      // Séance active : afficher le temps et calculer le progrès
      final elapsed = DateTime.now().difference(workoutProvider.currentWorkout!.createdAt);
      
      // Progress de 0 à 1 sur 60 minutes (3600 secondes)
      progress = (elapsed.inSeconds / 3600).clamp(0.0, 1.0);
      
      mainText = 'Séance en cours';
      subtitleText = workoutProvider.elapsedTimeFormatted;
      icon = Icons.fitness_center;
    }

    return Center(
      child: CircularProgressButton(
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
      ),
    );
  }

  /// Cards "Coming Soon" pour fonctionnalités futures
  Widget _buildComingSoonCards(BuildContext context) {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.95,
        children: [
          _buildFeatureCard(
            context,
            'Historique',
            Icons.history,
            'À venir dans EPIC-5',
          ),
          _buildFeatureCard(
            context,
            'Statistiques',
            Icons.analytics_outlined,
            'Prévu pour V2',
          ),
          _buildFeatureCard(
            context,
            'Calendrier',
            Icons.calendar_today,
            'Prévu pour V2',
          ),
          _buildFeatureCard(
            context,
            'Profil',
            Icons.person_outline,
            'Prévu pour V2',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    String subtitle,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      variant: AppCardVariant.elevated,
      elevation: 8,
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.1),
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
