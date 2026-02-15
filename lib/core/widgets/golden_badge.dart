import 'package:flutter/material.dart';

/// GoldenBadge - Badge premium avec glow or pour achievements
/// 
/// Design "Temple Digital" :
/// - Gradient gold (or pur → or clair)
/// - Glow animé doré
/// - Icône ou texte au centre
/// - Shadow dorée
/// - Taille ajustable
class GoldenBadge extends StatefulWidget {
  final String? text;
  final IconData? icon;
  final double size;
  final bool animated;

  const GoldenBadge({
    super.key,
    this.text,
    this.icon,
    this.size = 32,
    this.animated = true,
  }) : assert(text != null || icon != null, 'Either text or icon must be provided');

  @override
  State<GoldenBadge> createState() => _GoldenBadgeState();
}

class _GoldenBadgeState extends State<GoldenBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.animated) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final glowValue = _glowAnimation.value;

        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFD700), // Or pur
                Color(0xFFFFE57F), // Or clair
                Color(0xFFFFA000), // Or brûlé
              ],
              stops: [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.4 + glowValue * 0.3),
                blurRadius: 12 + glowValue * 8,
                spreadRadius: 2 + glowValue * 2,
              ),
            ],
          ),
          child: Center(
            child: widget.icon != null
                ? Icon(
                    widget.icon,
                    color: Colors.white,
                    size: widget.size * 0.5,
                  )
                : Text(
                    widget.text!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: widget.size * 0.35,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
