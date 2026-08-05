import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';

/// Écran de connexion Google Sign-In - direction "Marbre & Lumiere".
///
/// Implémente US-1.1: Connexion avec compte Google
/// Respecte RG-001: Authentification Google obligatoire
///
/// Fidele a la maquette Claude Design (Apollon DA Finale.dc.html, reponse a
/// CS-DA-01 : "Login : marbre ou nuit, APOLLON gravé en Cinzel, filet d'or,
/// Le Rayon qui passe une fois. Aucun mot ne dit « sport » ; le registre le
/// dit.") - remplace l'ancien design "Temple Digital" (glassmorphism bleu,
/// BackdropFilter, icone fitness_center generique) qui ne portait plus la
/// direction artistique actuelle.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: MeshGradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMark(context, isDark),
                  const SizedBox(height: 26),
                  _buildWordmark(context, isDark),
                  const SizedBox(height: 44),
                  _buildWelcomeCard(context, isDark),
                  const SizedBox(height: 28),
                  _buildGoogleSignInButton(context, isDark),
                  const SizedBox(height: 14),
                  _buildHelperText(isDark),
                  _buildErrorMessage(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Symbole de marque : le "A" grave, barre du filet d'or, Le Rayon en un
  /// seul passage a l'apparition de l'ecran (spec CS-DA-01). Dessine
  /// nativement (pas via les PNG de la bibliotheque de marque) car c'est le
  /// seul endroit ou le glyphe doit changer de couleur selon le theme tout
  /// en gardant le filet d'or dans les deux cas - aucun des PNG livres ne
  /// couvre cette combinaison precise.
  Widget _buildMark(BuildContext context, bool isDark) {
    final onBackground = isDark ? AppTheme.darkOnBackground : AppTheme.lightOnBackground;
    final goldLine = isDark ? AppTheme.accentGoldLine : AppTheme.lightAccentGoldLine;

    return RayonSweep(
      color: isDark ? goldLine.withValues(alpha: 0.38) : Colors.white.withValues(alpha: 0.95),
      child: SizedBox(
        width: 132,
        height: 132,
        child: ClipRect(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 7,
                child: Text('A', style: AppTheme.markGlyph(onBackground)),
              ),
              Positioned(
                top: 81,
                left: 15,
                right: 15,
                child: Container(height: 2, color: goldLine),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Wordmark "APOLLON" (30px/+0.28em, spec maquette) + filet degrade +
  /// sous-titre identitaire.
  Widget _buildWordmark(BuildContext context, bool isDark) {
    final onBackground = isDark ? AppTheme.darkOnBackground : AppTheme.lightOnBackground;
    final muted = isDark ? AppTheme.darkOnSurfaceMuted : AppTheme.lightOnSurfaceMuted;
    final gold = isDark ? AppTheme.accentGoldLine : AppTheme.lightAccentGoldLine;

    return Column(
      children: [
        Text(
          'APOLLON',
          style: AppTheme.wordmark(onBackground, fontSize: 30, trackingEm: 0.28),
        ),
        const SizedBox(height: 11),
        Container(
          width: 150,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gold.withValues(alpha: 0), gold, gold.withValues(alpha: 0)],
            ),
          ),
        ),
        const SizedBox(height: 11),
        Text(
          'TEMPLE DIGITAL DU DÉPASSEMENT',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 11 * 0.24, color: muted),
        ),
      ],
    );
  }

  /// Carte "Bienvenue" - MarbleCard (veinage marbre + filet d'or, garde-fou
  /// design "une seule carte par ecran" : c'est celle-ci, qui porte
  /// l'accroche identitaire).
  Widget _buildWelcomeCard(BuildContext context, bool isDark) {
    final onBackground = isDark ? AppTheme.darkOnBackground : AppTheme.lightOnBackground;
    final onSurface = isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface;

    return MarbleCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Bienvenue', style: AppTheme.screenTitle(onBackground).copyWith(fontSize: 22, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Text(
            'Sculptez votre excellence. Chaque série compte, chaque répétition forge votre légende.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.6, color: onSurface),
          ),
        ],
      ),
    );
  }

  /// Bouton de connexion Google - fond plein (surface/surfaceVariant selon
  /// theme), badge "G" en JetBrains Mono, zero BackdropFilter (spec design :
  /// c'est une matiere, pas du glassmorphism).
  Widget _buildGoogleSignInButton(BuildContext context, bool isDark) {
    final onBackground = isDark ? AppTheme.darkOnBackground : AppTheme.lightOnBackground;
    final muted = isDark ? AppTheme.darkOnSurfaceMuted : AppTheme.lightOnSurfaceMuted;
    final surface = isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightSurface;
    final badgeBg = isDark ? const Color(0xFF0D131E) : AppTheme.lightSurfaceVariant;
    final outline = isDark ? AppTheme.outlineSubtleDark : AppTheme.outlineSubtleLight;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Material(
          color: surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            onTap: authProvider.isLoading ? null : () => _handleGoogleSignIn(context, authProvider),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                border: Border.all(color: outline.withValues(alpha: outline.a * 2)),
                boxShadow: AppTheme.shadowElev1(Theme.of(context).brightness),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (authProvider.isLoading)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: onBackground),
                    )
                  else ...[
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: outline.withValues(alpha: outline.a * 2)),
                      ),
                      alignment: Alignment.center,
                      child: Text('G', style: AppTheme.timerNumber(muted).copyWith(fontSize: 11)),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    authProvider.isLoading ? 'Connexion...' : 'Se connecter avec Google',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 15 * 0.02, color: onBackground),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHelperText(bool isDark) {
    final muted = isDark ? AppTheme.darkOnSurfaceMuted : AppTheme.lightOnSurfaceMuted;
    return Text(
      'Un compte Google est requis pour synchroniser vos séances.',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.5, color: muted),
    );
  }

  /// Message d'erreur - sobre, sans BackdropFilter, coherent avec le reste
  /// de l'ecran (pas dans la maquette d'origine, qui ne montre pas cet
  /// etat : style aligne sur les tokens du theme plutot qu'invente).
  Widget _buildErrorMessage(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.errorMessage == null) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.errorRed : AppTheme.lightErrorRed).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              border: Border.all(color: colorScheme.error.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: colorScheme.error, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    authProvider.errorMessage!,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colorScheme.error),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => authProvider.clearError(),
                  color: colorScheme.error,
                  tooltip: 'Fermer',
                ),
              ],
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Erreur de connexion',
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}
