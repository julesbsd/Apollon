import 'package:flutter/material.dart';

/// Bouton moderne Material 3 avec animations
/// Supporte Dark et Light mode
/// Arrondis 24px selon Design System Apollon
class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? icon;
  final double? width;
  final EdgeInsets? padding;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.width,
    this.padding,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Couleurs selon variant
    Color backgroundColor;
    Color textColor;
    Color? borderColor;
    List<BoxShadow> shadows;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        backgroundColor = colorScheme.primary;
        textColor = colorScheme.onPrimary;
        borderColor = null;
        shadows = !_isPressed
            ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [];
        break;
      case AppButtonVariant.secondary:
        backgroundColor = colorScheme.secondaryContainer;
        textColor = colorScheme.onSecondaryContainer;
        borderColor = null;
        shadows = !_isPressed
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [];
        break;
      case AppButtonVariant.outlined:
        backgroundColor = Colors.transparent;
        textColor = colorScheme.primary;
        borderColor = colorScheme.primary;
        shadows = [];
        break;
      case AppButtonVariant.text:
        backgroundColor = Colors.transparent;
        textColor = colorScheme.primary;
        borderColor = null;
        shadows = [];
        break;
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: SizedBox(
        width: widget.width,
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: _buildContainer(
            backgroundColor,
            borderColor,
            shadows,
            textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildContainer(
    Color backgroundColor,
    Color? borderColor,
    List<BoxShadow> shadows,
    Color textColor,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 2)
            : null,
        boxShadow: shadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding:
                widget.padding ??
                const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: widget.isLoading
                ? _buildLoadingIndicator(textColor)
                : _buildContent(textColor),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(Color color) {
    return SizedBox(
      height: 24,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Color textColor) {
    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, color: textColor, size: 24),
          const SizedBox(width: 12),
          Text(
            widget.text,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Variants de style pour AppButton
enum AppButtonVariant {
  primary, // Bouton principal coloré
  secondary, // Bouton secondaire
  outlined, // Bouton outlined (bordure uniquement)
  text, // Bouton text (pas de bordure ni background)
}
