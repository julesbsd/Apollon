import 'package:flutter/material.dart';

/// AppBar moderne Material 3
/// Support Dark et Light mode
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final PreferredSizeWidget? bottom;

  const AppBarWidget({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
    this.bottom,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Text(title),
      centerTitle: centerTitle,
      actions: actions,
      leading: leading,
      elevation: elevation,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      bottom: bottom,
    );
  }
}

/// SliverAppBar moderne Material 3
/// Pour les scroll views avec effet parallax
class AppSliverAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool pinned;
  final bool floating;
  final double expandedHeight;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;

  const AppSliverAppBar({
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
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      bottom: bottom,
      flexibleSpace: flexibleSpace,
    );
  }
}
