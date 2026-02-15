import 'dart:ui';
import 'package:flutter/material.dart';

/// Bouton avec effet Liquid Glass (glassmorphism)
/// Supporte Dark et Light mode avec animations fluides
/// Arrondis 24px selon Design System Apollon
class LiquidButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final LiquidButtonVariant variant;
  final IconData? icon;
  final double? width;
  final EdgeInsets? padding;

  const LiquidButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.variant = LiquidButtonVariant.primary,
    this.icon,
    this.width,
    this.padding,
  });

  @override
  State<LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<LiquidButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
    Color borderColor;
    bool showBlur;
    List<BoxShadow> shadows;

    switch (widget.variant) {
      case LiquidButtonVariant.primary:
        backgroundColor = colorScheme.primary.withOpacity(0.85);
        textColor = colorScheme.onPrimary;
        borderColor = colorScheme.primary.withOpacity(0.3);
        showBlur = true;
        shadows = [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];
        break;
      case LiquidButtonVariant.secondary:
        backgroundColor = colorScheme.surface.withOpacity(0.7);
        textColor = colorScheme.onSurface;
        borderColor = Colors.white.withOpacity(0.15);
        showBlur = true;
        shadows = [];
        break;
      case LiquidButtonVariant.outlined:
        backgroundColor = Colors.transparent;
        textColor = colorScheme.primary;
        borderColor = colorScheme.primary.withOpacity(0.5);
        showBlur = false;
        shadows = [];
        break;
      case LiquidButtonVariant.text:
        backgroundColor = Colors.transparent;
        textColor = colorScheme.primary;
        borderColor = Colors.transparent;
        showBlur = false;
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: showBlur
                ? BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: _buildContainer(
                      backgroundColor,
                      borderColor,
                      shadows,
                      textColor,
                    ),
                  )
                : _buildContainer(
                    backgroundColor,
                    borderColor,
                    shadows,
                    textColor,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildContainer(
    Color backgroundColor,
    Color borderColor,
    List<BoxShadow> shadows,
    Color textColor,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
        boxShadow: _isPressed ? [] : shadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: widget.padding ??
                const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
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

/// Variants de style pour LiquidButton avec animations
enum LiquidButtonVariant {
  primary,   // Bouton principal (coloré avec blur)
  secondary, // Bouton secondaire (transparent avec blur)
  outlined,  // Bouton outlined (bordure uniquement)
  text,      // Bouton text (pas de bordure ni background)
}
