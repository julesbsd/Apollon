import 'package:flutter/material.dart';

/// ModernImageCard - Card avec image en background et overlay
///
/// Composant épuré style moderne pour afficher des cards avec grandes images,
/// texte overlay et actions optionnelles.
///
/// Features:
/// - Image en background (network ou asset)
/// - Overlay sombre pour lisibilité (0.45 opacity)
/// - Badge optionnel en top-right
/// - Titre et sous-titre en bas (blanc)
/// - Bouton d'action optionnel
/// - Tap gesture configurable
/// - Border radius 20px
///
/// Usage:
/// ```dart
/// ModernImageCard(
///   imageUrl: 'https://example.com/workout.jpg',
///   title: 'Chest Muscle Exercise',
///   subtitle: '15 min • 120 kcal',
///   badge: Container(
///     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
///     decoration: BoxDecoration(
///       color: Colors.orange,
///       borderRadius: BorderRadius.circular(12),
///     ),
///     child: Text('NEW', style: TextStyle(color: Colors.white)),
///   ),
///   actionButton: ElevatedButton(
///     onPressed: () {},
///     child: Text('Start workout'),
///   ),
///   onTap: () => Navigator.push(...),
/// )
/// ```
class ModernImageCard extends StatelessWidget {
  /// URL de l'image (network ou asset)
  final String imageUrl;

  /// Titre principal (blanc, 22px SemiBold)
  final String title;

  /// Sous-titre optionnel (blanc, 14px Regular)
  final String? subtitle;

  /// Badge optionnel en top-right (widget custom)
  final Widget? badge;

  /// Bouton d'action optionnel en bas (widget custom)
  final Widget? actionButton;

  /// Callback au tap sur la card
  final VoidCallback? onTap;

  /// Hauteur de la card (défaut: 200)
  final double height;

  /// Largeur de la card (défaut: double.infinity)
  final double? width;

  /// Opacité de l'overlay sombre (défaut: 0.45)
  final double overlayOpacity;

  /// Border radius (défaut: 20)
  final double borderRadius;

  const ModernImageCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.badge,
    this.actionButton,
    this.onTap,
    this.height = 200,
    this.width,
    this.overlayOpacity = 0.45,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            // Neumorphism - Ombre claire (highlight) en haut à gauche
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 18,
              offset: const Offset(-8, -8),
            ),
            // Neumorphism - Ombre sombre en bas à droite
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(8, 8),
            ),
            // Shadow principale
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image background
              _buildImage(),

              // Overlay sombre
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(overlayOpacity * 0.3),
                      Colors.black.withOpacity(overlayOpacity),
                      Colors.black.withOpacity(overlayOpacity * 1.2),
                    ],
                  ),
                ),
              ),

              // Contenu
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge en top-right
                    if (badge != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [badge!],
                      ),

                    const Spacer(),

                    // Titre et sous-titre en bas
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),

                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Action button si fourni
                    if (actionButton != null) ...[
                      const SizedBox(height: 12),
                      actionButton!,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    // Si URL réseau (http/https)
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 48),
        ),
      );
    }

    // Sinon, asset local
    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, size: 48),
      ),
    );
  }
}
