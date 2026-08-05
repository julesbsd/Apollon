import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

/// MeshGradientBackground - Background premium avec gradient mesh animé
///
/// Caractéristiques :
/// - Gradient mesh avec 4 couleurs organiques
/// - Animation breathing subtile (20s loop)
/// - Mode clair : Bleu (seed primaryBlue) + Blanc marbre + Vert menthe
/// - Mode sombre : Bleu nuit + Bleu-gris sombre + Marbre sombre + Bleu profond
/// - Performance optimisée avec ImplicitlyAnimatedWidget
/// - Palettes alignees sur AppTheme (seed 0xFF4A90E2), voir
///   AppTheme.lightMeshGradient / AppTheme.darkMeshGradient
class MeshGradientBackground extends StatefulWidget {
  final Widget child;
  final Duration animationDuration;

  const MeshGradientBackground({
    super.key,
    required this.child,
    this.animationDuration = const Duration(seconds: 20),
  });

  @override
  State<MeshGradientBackground> createState() => _MeshGradientBackgroundState();
}

class _MeshGradientBackgroundState extends State<MeshGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Loop infini
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark
        ? AppTheme.darkMeshGradient
        : AppTheme.lightMeshGradient;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: _buildMeshGradient(colors, _animation.value),
          ),
          child: widget.child,
        );
      },
    );
  }

  /// Construit un gradient mesh avec animation breathing
  LinearGradient _buildMeshGradient(List<Color> colors, double animationValue) {
    // Animation breathing : les stops bougent légèrement
    final breathingOffset = math.sin(animationValue * math.pi * 2) * 0.1;

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
      stops: [0.0, 0.3 + breathingOffset, 0.7 - breathingOffset, 1.0],
    );
  }
}

/// MeshGradientBackgroundStatic - Version statique sans animation
///
/// Utilisez cette version pour :
/// - Écrans où l'animation n'est pas nécessaire
/// - Meilleure performance sur devices bas de gamme
/// - Réduire la consommation batterie
class MeshGradientBackgroundStatic extends StatelessWidget {
  final Widget child;

  const MeshGradientBackgroundStatic({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark
        ? AppTheme.darkMeshGradient
        : AppTheme.lightMeshGradient;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: child,
    );
  }
}
