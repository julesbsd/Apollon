import 'dart:ui';
import 'package:flutter/material.dart';

/// AppBar avec effet Liquid Glass
/// Effet de blur, transparence et glassmorphism
/// Support Dark et Light mode
class LiquidAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final PreferredSizeWidget? bottom;

  const LiquidAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
    this.bottom,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface.withOpacity(0.7),
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: AppBar(
            title: Text(title),
            centerTitle: centerTitle,
            actions: actions,
            leading: leading,
            elevation: elevation,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            bottom: bottom,
          ),
        ),
      ),
    );
  }
}

/// SliverAppBar avec effet Liquid Glass
/// Pour les scroll views avec effet parallax
class LiquidSliverAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool pinned;
  final bool floating;
  final double expandedHeight;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;

  const LiquidSliverAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.pinned = true,
    this.floating = false,
    this.expandedHeight = 200.0,
    this.flexibleSpace,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SliverAppBar(
      title: Text(title),
      centerTitle: centerTitle,
      actions: actions,
      leading: leading,
      pinned: pinned,
      floating: floating,
      expandedHeight: expandedHeight,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      bottom: bottom,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.surface.withOpacity(0.8),
                  colorScheme.surface.withOpacity(0.6),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: flexibleSpace,
          ),
        ),
      ),
    );
  }
}
