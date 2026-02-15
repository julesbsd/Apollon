import 'package:flutter/material.dart';

/// PulseIcon - Icône avec effet pulse glow pour états actifs
/// 
/// Design "Temple Digital" :
/// - Pulse/glow animé
/// - Couleur personnalisable
/// - Container circulaire avec background
/// - Shadow animée
/// - Utilisé pour indiquer états actifs (workout en cours, notifications, etc.)
class PulseIcon extends StatefulWidget {
  final IconData icon;
  final Color? color;
  final double size;
  final bool isActive;
  final VoidCallback? onTap;

  const PulseIcon({
    super.key,
    required this.icon,
    this.color,
    this.size = 24,
    this.isActive = true,
    this.onTap,
  });

  @override
  State<PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<PulseIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulseIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
      _controller.reset();
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
    final iconColor = widget.color ?? theme.colorScheme.primary;

    final iconWidget = AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final pulseValue = _pulseAnimation.value;

        return Container(
          width: widget.size * 2,
          height: widget.size * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconColor.withOpacity(0.15),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: iconColor.withOpacity(0.3 + pulseValue * 0.2),
                      blurRadius: 12 + pulseValue * 8,
                      spreadRadius: 2 + pulseValue * 3,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            widget.icon,
            size: widget.size,
            color: iconColor,
          ),
        );
      },
    );

    if (widget.onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(widget.size),
          child: iconWidget,
        ),
      );
    }

    return iconWidget;
  }
}
