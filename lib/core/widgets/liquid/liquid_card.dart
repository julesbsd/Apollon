import 'dart:ui';
import 'package:flutter/material.dart';

/// Card avec effet Liquid Glass (glassmorphism)
/// Supporte Dark et Light mode avec animations
/// Arrondis 24px selon Design System Apollon
class LiquidCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final LiquidCardVariant variant;
  final double? elevation;

  const LiquidCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.onTap,
    this.variant = LiquidCardVariant.standard,
    this.elevation,
  });

  @override
  State<LiquidCard> createState() => _LiquidCardState();
}

class _LiquidCardState extends State<LiquidCard>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
    Color borderColor;
    double blurAmount;
    double defaultElevation;

    switch (widget.variant) {
      case LiquidCardVariant.standard:
        backgroundColor = colorScheme.surface.withOpacity(0.75);
        borderColor = Colors.white.withOpacity(0.15);
        blurAmount = 12;
        defaultElevation = 0;
        break;
      case LiquidCardVariant.elevated:
        backgroundColor = colorScheme.surface.withOpacity(0.85);
        borderColor = Colors.white.withOpacity(0.2);
        blurAmount = 16;
        defaultElevation = 8;
        break;
      case LiquidCardVariant.outlined:
        backgroundColor = Colors.transparent;
        borderColor = colorScheme.outline.withOpacity(0.5);
        blurAmount = 8;
        defaultElevation = 0;
        break;
    }

    final elevation = widget.elevation ?? defaultElevation;
    final shadows = elevation > 0
        ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: elevation * 2,
              offset: Offset(0, elevation / 2),
            ),
          ]
        : <BoxShadow>[];

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
            boxShadow: _isPressed ? [] : shadows,
          ),
          padding: widget.padding ?? const EdgeInsets.all(16),
          child: widget.child,
        ),
      ),
    );

    // Si onTap est défini, rendre la card cliquable avec animation
    if (widget.onTap != null) {
      return GestureDetector(
        onTap: widget.onTap,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: card,
        ),
      );
    }

    return card;
  }
}

/// Variants de style pour LiquidCard
enum LiquidCardVariant {
  standard, // Card standard avec blur modéré
  elevated, // Card élevée avec shadow et blur fort
  outlined, // Card outlined transparente
}
