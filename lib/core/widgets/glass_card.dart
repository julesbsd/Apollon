/// Widget GlassCard - Carte avec effet glassmorphisme Liquid Glass
/// 
/// Composant réutilisable qui applique l'effet de verre avec :
/// - Opacité configurée (glassOpacityLight/Dark)
/// - Flou de fond (blur filter)
/// - Bordures arrondies
/// - Gestion automatique du mode clair/sombre
/// 
/// Usage typique :
/// ```dart
/// GlassCard(
///   child: Padding(
///     padding: EdgeInsets.all(16),
///     child: Text('Contenu'),
///   ),
/// )
/// ```

import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_decorations.dart';

/// Widget de carte avec effet glassmorphisme
/// 
/// Fournit une surface vitrée pour contenir du contenu avec :
/// - Effet de flou d'arrière-plan
/// - Opacité automatique selon le mode clair/sombre
/// - Bordures arrondies personnalisables
/// - Support du padding et margin
class GlassCard extends StatelessWidget {
  /// Contenu de la carte
  final Widget child;

  /// Rayon de bordure personnalisé (défaut: AppDecorations.borderRadiusLarge)
  final BorderRadius? borderRadius;

  /// Couleur de fond personnalisée (défaut: automatique selon thème)
  final Color? backgroundColor;

  /// Bordure personnalisée
  final Border? border;

  /// Padding interne
  final EdgeInsetsGeometry? padding;

  /// Marge externe
  final EdgeInsetsGeometry? margin;

  /// Largeur de la carte
  final double? width;

  /// Hauteur de la carte
  final double? height;

  /// Callback au tap
  final VoidCallback? onTap;

  /// Si true, affiche une ombre portée
  final bool showShadow;

  /// Intensité du flou (défaut: 10.0)
  final double blurIntensity;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius,
    this.backgroundColor,
    this.border,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.showShadow = true,
    this.blurIntensity = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? AppDecorations.borderRadiusLarge;

    Widget content = ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blurIntensity,
          sigmaY: blurIntensity,
        ),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: AppDecorations.glass(
            context,
            backgroundColor: backgroundColor,
            borderRadius: effectiveBorderRadius,
            border: border,
          ).copyWith(
            boxShadow: showShadow ? AppDecorations.shadowMedium(context) : null,
          ),
          child: child,
        ),
      ),
    );

    // Si onTap est fourni, envelopper dans InkWell pour l'interactivité
    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: effectiveBorderRadius,
        child: content,
      );
    }

    // Appliquer la marge si fournie
    if (margin != null) {
      content = Padding(
        padding: margin!,
        child: content,
      );
    }

    return content;
  }
}

/// Variante de GlassCard avec animation au survol
/// 
/// Ajoute un effet d'élévation et d'échelle au survol/tap
class AnimatedGlassCard extends StatefulWidget {
  /// Contenu de la carte
  final Widget child;

  /// Rayon de bordure
  final BorderRadius? borderRadius;

  /// Couleur de fond personnalisée
  final Color? backgroundColor;

  /// Bordure personnalisée
  final Border? border;

  /// Padding interne
  final EdgeInsetsGeometry? padding;

  /// Marge externe
  final EdgeInsetsGeometry? margin;

  /// Largeur de la carte
  final double? width;

  /// Hauteur de la carte
  final double? height;

  /// Callback au tap
  final VoidCallback? onTap;

  /// Facteur d'échelle au survol (défaut: 1.02)
  final double scaleFactor;

  /// Durée de l'animation (défaut: 200ms)
  final Duration animationDuration;

  const AnimatedGlassCard({
    super.key,
    required this.child,
    this.borderRadius,
    this.backgroundColor,
    this.border,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.scaleFactor = 1.02,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<AnimatedGlassCard> createState() => _AnimatedGlassCardState();
}

class _AnimatedGlassCardState extends State<AnimatedGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _handleTapDown : null,
      onTapUp: widget.onTap != null ? _handleTapUp : null,
      onTapCancel: widget.onTap != null ? _handleTapCancel : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GlassCard(
          borderRadius: widget.borderRadius,
          backgroundColor: widget.backgroundColor,
          border: widget.border,
          padding: widget.padding,
          margin: widget.margin,
          width: widget.width,
          height: widget.height,
          showShadow: _isPressed,
          blurIntensity: _isPressed ? 15.0 : 10.0,
          child: widget.child,
        ),
      ),
    );
  }
}
