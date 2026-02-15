import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/widgets.dart';

/// Écran de connexion avec Google Sign-In
/// Implémente US-1.1: Connexion avec compte Google
/// Respecte RG-001: Authentification Google obligatoire
/// Design: Moderne Material 3 avec Dark/Light mode support
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(Theme.of(context).colorScheme),
                  const SizedBox(height: 48),
                  _buildWelcomeCard(context),
                  const SizedBox(height: 32),
                  _buildGoogleSignInButton(context),
                  const SizedBox(height: 16),
                  _buildErrorMessage(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Logo et titre de l'application
  Widget _buildLogo(ColorScheme colorScheme) {
    return Column(
      children: [
        // Icône fitness_center en grand
        Icon(
          Icons.fitness_center,
          size: 100,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'APOLLON',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Suivi de musculation',
          style: TextStyle(
            fontSize: 16,
            color: colorScheme.onBackground.withOpacity(0.7),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  /// Card de bienvenue
  Widget _buildWelcomeCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Bienvenue',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Suivez votre progression en musculation avec un design premium',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Bouton de connexion Google avec gestion du loading
  Widget _buildGoogleSignInButton(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return AppButton(
          text: 'Se connecter avec Google',
          icon: Icons.login,
          onPressed: () => _handleGoogleSignIn(context, authProvider),
          isLoading: authProvider.isLoading,
          variant: AppButtonVariant.primary,
          width: double.infinity,
        );
      },
    );
  }

  /// Message d'erreur si échec de connexion
  Widget _buildErrorMessage(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.errorMessage == null) {
          return const SizedBox.shrink();
        }

        return AppCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  authProvider.errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => authProvider.clearError(),
                color: Theme.of(context).colorScheme.error,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Gestion du clic sur le bouton Google Sign-In
  /// Affiche SnackBar en cas d'erreur (US-1.1)
  Future<void> _handleGoogleSignIn(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    final success = await authProvider.signInWithGoogle();

    if (!success && context.mounted) {
      // Afficher SnackBar en cas d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Erreur de connexion'),
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
