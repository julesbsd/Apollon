import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/widgets.dart';

/// Écran de connexion Premium avec Google Sign-In
/// Implémente US-1.1: Connexion avec compte Google
/// Respecte RG-001: Authentification Google obligatoire
/// Design Premium "Temple Digital": Mesh gradient + glassmorphism + Cinzel
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MeshGradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(context),
                  const SizedBox(height: 64),
                  _buildWelcomeCard(context),
                  const SizedBox(height: 32),
                  _buildGoogleSignInButton(context),
                  const SizedBox(height: 24),
                  _buildErrorMessage(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Logo et titre de l'application Premium avec Cinzel
  Widget _buildLogo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Icône fitness_center avec effet glassmorphism
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withOpacity(0.25),
                colorScheme.primary.withOpacity(0.15),
              ],
            ),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.4),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.3),
                blurRadius: 32,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Icon(
            Icons.fitness_center,
            size: 70,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 32),
        
        // Titre APOLLON avec Cinzel (Greek nobility)
        Text(
          'APOLLON',
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 4,
            color: colorScheme.primary,
            shadows: [
              Shadow(
                color: colorScheme.primary.withOpacity(0.3),
                blurRadius: 16,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Sous-titre avec Raleway
        Text(
          'Temple Digital du Dépassement',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onBackground.withOpacity(0.7),
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  /// Card de bienvenue avec glassmorphism
  Widget _buildWelcomeCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      colorScheme.surface.withOpacity(0.6),
                      colorScheme.surface.withOpacity(0.3),
                    ]
                  : [
                      Colors.white.withOpacity(0.7),
                      Colors.white.withOpacity(0.4),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.15)
                  : Colors.white.withOpacity(0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : colorScheme.primary.withOpacity(0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Titre avec Cinzel
              Text(
                'Bienvenue',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              
              // Description
              Text(
                'Sculptez votre excellence dans notre temple digital. Chaque série compte, chaque répétition forge votre légende.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.8),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bouton de connexion Google premium avec glassmorphism
  Widget _buildGoogleSignInButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          colorScheme.primary.withOpacity(0.3),
                          colorScheme.primary.withOpacity(0.2),
                        ]
                      : [
                          colorScheme.primary.withOpacity(0.15),
                          colorScheme.primary.withOpacity(0.1),
                        ],
                ),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: authProvider.isLoading
                      ? null
                      : () => _handleGoogleSignIn(context, authProvider),
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (authProvider.isLoading)
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.primary,
                              ),
                            ),
                          )
                        else
                          Icon(
                            Icons.login,
                            size: 24,
                            color: colorScheme.primary,
                          ),
                        const SizedBox(width: 16),
                        Text(
                          authProvider.isLoading
                              ? 'Connexion...'
                              : 'Se connecter avec Google',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Message d'erreur glassmorphism si échec de connexion
  Widget _buildErrorMessage(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.errorMessage == null) {
          return const SizedBox.shrink();
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          colorScheme.errorContainer.withOpacity(0.3),
                          colorScheme.errorContainer.withOpacity(0.2),
                        ]
                      : [
                          colorScheme.errorContainer.withOpacity(0.5),
                          colorScheme.errorContainer.withOpacity(0.3),
                        ],
                ),
                border: Border.all(
                  color: colorScheme.error.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: colorScheme.error,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      authProvider.errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => authProvider.clearError(),
                    color: colorScheme.error,
                    tooltip: 'Fermer',
                  ),
                ],
              ),
            ),
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
