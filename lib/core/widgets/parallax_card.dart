import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// ParallaxCard - Wrapper qui ajoute un effet parallax subtil au scroll
/// 
/// Design Premium :
/// - Effet parallax au scroll (déplacement vertical léger)
/// - Animation fluide et naturelle
/// - Optionnel : légère rotation et scale
class ParallaxCard extends StatefulWidget {
  final Widget child;
  final double parallaxStrength;
  final bool enableRotation;

  const ParallaxCard({
    super.key,
    required this.child,
    this.parallaxStrength = 0.3,
    this.enableRotation = false,
  });

  @override
  State<ParallaxCard> createState() => _ParallaxCardState();
}

class _ParallaxCardState extends State<ParallaxCard> {
  @override
  Widget build(BuildContext context) {
    return Flow(
      delegate: ParallaxFlowDelegate(
        scrollable: Scrollable.of(context),
        listItemContext: context,
        parallaxStrength: widget.parallaxStrength,
        enableRotation: widget.enableRotation,
      ),
      children: [widget.child],
    );
  }
}

class ParallaxFlowDelegate extends FlowDelegate {
  final ScrollableState scrollable;
  final BuildContext listItemContext;
  final double parallaxStrength;
  final bool enableRotation;

  ParallaxFlowDelegate({
    required this.scrollable,
    required this.listItemContext,
    required this.parallaxStrength,
    required this.enableRotation,
  }) : super(repaint: scrollable.position);

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return constraints;
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    // Calcul du parallax offset
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final listItemBox = listItemContext.findRenderObject() as RenderBox;

    final listItemOffset = listItemBox.localToGlobal(
      listItemBox.size.centerLeft(Offset.zero),
      ancestor: scrollableBox,
    );

    final viewportDimension = scrollable.position.viewportDimension;
    final scrollFraction = (listItemOffset.dy / viewportDimension).clamp(-1.0, 1.0);

    // Offset vertical subtil basé sur le scroll
    final verticalAlignment = -scrollFraction * (100 * parallaxStrength);

    // Transformation optionnelle avec légère rotation
    if (enableRotation) {
      final rotationAngle = scrollFraction * 0.02; // Rotation très subtile
      
      final matrix = Matrix4.identity()
        ..translate(0.0, verticalAlignment)
        ..rotateZ(rotationAngle);

      context.paintChild(
        0,
        transform: matrix,
      );
    } else {
      // Juste le parallax vertical
      context.paintChild(
        0,
        transform: Matrix4.translationValues(0.0, verticalAlignment, 0.0),
      );
    }
  }

  @override
  bool shouldRepaint(ParallaxFlowDelegate oldDelegate) {
    return scrollable != oldDelegate.scrollable ||
        listItemContext != oldDelegate.listItemContext ||
        parallaxStrength != oldDelegate.parallaxStrength ||
        enableRotation != oldDelegate.enableRotation;
  }
}
