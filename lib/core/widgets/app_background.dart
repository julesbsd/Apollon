import 'package:flutter/material.dart';

/// Background moderne avec gradient subtil
/// Supporte Dark et Light mode
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.background,
            colorScheme.surface,
          ],
        ),
      ),
      child: child,
    );
  }
}
