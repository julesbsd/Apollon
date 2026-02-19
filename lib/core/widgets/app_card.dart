import 'package:flutter/material.dart';

/// Card moderne Material 3 avec animations
/// Supporte Dark et Light mode
/// Arrondis 24px selon Design System Apollon
class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final AppCardVariant variant;
  final double? elevation;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.onTap,
    this.variant = AppCardVariant.standard,
    this.elevation,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
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
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
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

    // Configuration selon variant
    Color backgroundColor;
    Color? borderColor;
    double defaultElevation;

    switch (widget.variant) {
      case AppCardVariant.standard:
        backgroundColor = colorScheme.surface;
        borderColor = null;
        defaultElevation = 1;
        break;
      case AppCardVariant.elevated:
        backgroundColor = colorScheme.surface;
        borderColor = null;
        defaultElevation = 4;
        break;
      case AppCardVariant.outlined:
        backgroundColor = colorScheme.surface;
        borderColor = colorScheme.outline;
        defaultElevation = 0;
        break;
    }

    final elevation = widget.elevation ?? defaultElevation;
    final shadows = elevation > 0 && !_isPressed
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: elevation * 3,
              offset: Offset(0, elevation),
            ),
          ]
        : <BoxShadow>[];

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1.5)
            : null,
        boxShadow: shadows,
      ),
      padding: widget.padding ?? const EdgeInsets.all(16),
      child: widget.child,
    );

    // Si onTap est défini, rendre la card cliquable avec animation
    if (widget.onTap != null) {
      return GestureDetector(
        onTap: widget.onTap,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: ScaleTransition(scale: _scaleAnimation, child: card),
      );
    }

    return card;
  }
}

/// Variants de style pour AppCard
enum AppCardVariant {
  standard, // Card standard avec subtle shadow
  elevated, // Card élevée avec shadow prononcée
  outlined, // Card avec bordure
}
