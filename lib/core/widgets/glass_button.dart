/// Widget GlassButton - Bouton avec effet glassmorphisme Liquid Glass
/// 
/// Boutons réutilisables avec différentes variantes :
/// - Primary : bouton principal avec couleur primaire
/// - Secondary : bouton secondaire avec couleur secondaire
/// - Outlined : bouton avec bordure uniquement
/// - Text : bouton texte transparent
/// 
/// Usage typique :
/// ```dart
/// GlassButton.primary(
///   label: 'Confirmer',
///   onPressed: () => print('Pressed'),
///   icon: Icons.check,
/// )
/// ```

import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_typography.dart';

/// Type de bouton avec effet glassmorphisme
enum GlassButtonType {
  /// Bouton principal avec fond coloré
  primary,

  /// Bouton secondaire avec fond coloré
  secondary,

  /// Bouton avec bordure uniquement
  outlined,

  /// Bouton texte transparent
  text,
}

/// Widget de bouton avec effet glassmorphisme
/// 
/// Support :
/// - Différentes variantes (primary, secondary, outlined, text)
/// - Icônes optionnelles (leading/trailing)
/// - États disabled
/// - Feedback tactile avec animation
/// - Mode clair/sombre automatique
class GlassButton extends StatefulWidget {
  /// Label du bouton
  final String label;

  /// Callback au tap
  final VoidCallback? onPressed;

  /// Type de bouton
  final GlassButtonType type;

  /// Icône à gauche du label
  final IconData? leadingIcon;

  /// Icône à droite du label
  final IconData? trailingIcon;

  /// Largeur du bouton (défaut: étend au parent avec constraints)
  final double? width;

  /// Hauteur du bouton (défaut: 56)
  final double height;

  /// Padding interne horizontal (défaut: 24)
  final double horizontalPadding;

  /// Si true, le bouton affiche un indicateur de chargement
  final bool isLoading;

  /// Rayon de bordure personnalisé
  final BorderRadius? borderRadius;

  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = GlassButtonType.primary,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height = 56,
    this.horizontalPadding = 24,
    this.isLoading = false,
    this.borderRadius,
  });

  /// Constructeur pour bouton primary
  const GlassButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height = 56,
    this.horizontalPadding = 24,
    this.isLoading = false,
    this.borderRadius,
  }) : type = GlassButtonType.primary;

  /// Constructeur pour bouton secondary
  const GlassButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height = 56,
    this.horizontalPadding = 24,
    this.isLoading = false,
    this.borderRadius,
  }) : type = GlassButtonType.secondary;

  /// Constructeur pour bouton outlined
  const GlassButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height = 56,
    this.horizontalPadding = 24,
    this.isLoading = false,
    this.borderRadius,
  }) : type = GlassButtonType.outlined;

  /// Constructeur pour bouton text
  const GlassButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height = 48,
    this.horizontalPadding = 16,
    this.isLoading = false,
    this.borderRadius,
  }) : type = GlassButtonType.text;

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
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
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
      widget.onPressed!();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    switch (widget.type) {
      case GlassButtonType.primary:
        return isEnabled
            ? Theme.of(context).colorScheme.primary
            : (isDark
                ? AppColors.glassDisabledBackgroundDark
                : AppColors.glassDisabledBackgroundLight);
      case GlassButtonType.secondary:
        return isEnabled
            ? Theme.of(context).colorScheme.secondary
            : (isDark
                ? AppColors.glassDisabledBackgroundDark
                : AppColors.glassDisabledBackgroundLight);
      case GlassButtonType.outlined:
      case GlassButtonType.text:
        return Colors.transparent;
    }
  }

  Color _getTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    if (!isEnabled) {
      return isDark
          ? AppColors.glassDisabledTextDark
          : AppColors.glassDisabledTextLight;
    }

    switch (widget.type) {
      case GlassButtonType.primary:
        return Theme.of(context).colorScheme.onPrimary;
      case GlassButtonType.secondary:
        return Theme.of(context).colorScheme.onSecondary;
      case GlassButtonType.outlined:
      case GlassButtonType.text:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Border? _getBorder(BuildContext context) {
    if (widget.type == GlassButtonType.outlined) {
      final isEnabled = widget.onPressed != null && !widget.isLoading;
      return Border.all(
        color: isEnabled
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
        width: 2,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius =
        widget.borderRadius ?? AppDecorations.borderRadiusMedium;
    final backgroundColor = _getBackgroundColor(context);
    final textColor = _getTextColor(context);
    final border = _getBorder(context);
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ClipRRect(
          borderRadius: effectiveBorderRadius,
          child: BackdropFilter(
            filter: widget.type != GlassButtonType.text
                ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
                : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Container(
              width: widget.width,
              height: widget.height,
              padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: effectiveBorderRadius,
                border: border,
                boxShadow: widget.type == GlassButtonType.primary ||
                        widget.type == GlassButtonType.secondary
                    ? (isEnabled ? AppDecorations.shadowMedium(context) : null)
                    : null,
              ),
              child: Row(
                mainAxisSize: widget.width == null ? MainAxisSize.min : MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      ),
                    )
                  else ...[
                    if (widget.leadingIcon != null) ...[
                      Icon(
                        widget.leadingIcon,
                        color: textColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: AppTypography.bodyLarge(context).copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.trailingIcon != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        widget.trailingIcon,
                        color: textColor,
                        size: 20,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bouton icon avec effet glassmorphisme
/// 
/// Version compacte pour afficher uniquement une icône
class GlassIconButton extends StatefulWidget {
  /// Icône à afficher
  final IconData icon;

  /// Callback au tap
  final VoidCallback? onPressed;

  /// Type de bouton
  final GlassButtonType type;

  /// Taille de l'icône (défaut: 24)
  final double iconSize;

  /// Taille du bouton (défaut: 48)
  final double size;

  /// Si true, affiche un indicateur de chargement
  final bool isLoading;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.type = GlassButtonType.primary,
    this.iconSize = 24,
    this.size = 48,
    this.isLoading = false,
  });

  @override
  State<GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<GlassIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.90,
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

  void _handleTap() {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward().then((_) {
        _controller.reverse();
        widget.onPressed!();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    Color backgroundColor;
    Color iconColor;

    switch (widget.type) {
      case GlassButtonType.primary:
        backgroundColor = isEnabled
            ? Theme.of(context).colorScheme.primary
            : (isDark
                ? AppColors.glassDisabledBackgroundDark
                : AppColors.glassDisabledBackgroundLight);
        iconColor = isEnabled
            ? Theme.of(context).colorScheme.onPrimary
            : (isDark
                ? AppColors.glassDisabledTextDark
                : AppColors.glassDisabledTextLight);
        break;
      case GlassButtonType.secondary:
        backgroundColor = isEnabled
            ? Theme.of(context).colorScheme.secondary
            : (isDark
                ? AppColors.glassDisabledBackgroundDark
                : AppColors.glassDisabledBackgroundLight);
        iconColor = isEnabled
            ? Theme.of(context).colorScheme.onSecondary
            : (isDark
                ? AppColors.glassDisabledTextDark
                : AppColors.glassDisabledTextLight);
        break;
      case GlassButtonType.outlined:
      case GlassButtonType.text:
        backgroundColor = Colors.transparent;
        iconColor =
            isEnabled ? Theme.of(context).colorScheme.primary : (isDark
                ? AppColors.glassDisabledTextDark
                : AppColors.glassDisabledTextLight);
        break;
    }

    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.size / 2),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
                border: widget.type == GlassButtonType.outlined
                    ? Border.all(
                        color: isEnabled
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.12),
                        width: 2,
                      )
                    : null,
                boxShadow: widget.type == GlassButtonType.primary ||
                        widget.type == GlassButtonType.secondary
                    ? (isEnabled ? AppDecorations.shadowLight(context) : null)
                    : null,
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: widget.iconSize,
                        height: widget.iconSize,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                        ),
                      )
                    : Icon(
                        widget.icon,
                        color: iconColor,
                        size: widget.iconSize,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
