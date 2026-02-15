import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/liquid/liquid_button.dart';
import '../../core/widgets/liquid/liquid_card.dart';
import '../../core/widgets/liquid/theme_switcher.dart';

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
          // Menu avec option de déconnexion
          _buildProfileMenu(context),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.background,
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(context),
                const SizedBox(height: 32),
                _buildMainButton(context),
                const SizedBox(height: 16),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bonjour,',
          style: TextStyle(
            fontSize: 20,
            color: colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user?.displayName?.split(' ').first ?? 'Athlète',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  /// Bouton principal "Nouvelle séance"
  /// Placeholder pour EPIC-4
  Widget _buildMainButton(BuildContext context) {
    return LiquidButton(
      text: 'Nouvelle séance',
      icon: Icons.add_circle_outline,
      onPressed: () {
        // TODO: Navigation vers ExerciseSelectionScreen (EPIC-4)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('À implémenter dans EPIC-4'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      variant: LiquidButtonVariant.primary,
      width: double.infinity,
    );
  }

  /// Cards "Coming Soon" pour fonctionnalités futures
  Widget _buildComingSoonCards(BuildContext context) {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
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

    return LiquidCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40,
            color: colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// Menu de profil avec options Thème et Déconnexion (US-1.3 + US-3.3)
  Widget _buildProfileMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.account_circle),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'theme',
          child: Row(
            children: [
              Icon(Icons.palette_outlined, size: 20),
              SizedBox(width: 12),
              Text('Thème'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20),
              SizedBox(width: 12),
              Text('Déconnexion'),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'theme') {
          _showThemeSheet(context);
        } else if (value == 'logout') {
          _showLogoutConfirmation(context);
        }
      },
    );
  }

  /// Bottom sheet pour changer le thème (US-3.3)
  void _showThemeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const ThemeSwitcher(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Dialog de confirmation de déconnexion (US-1.3)
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('Déconnexion'),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _performLogout(context);
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  /// Exécution de la déconnexion
  Future<void> _performLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signOut();

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Erreur lors de la déconnexion',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
