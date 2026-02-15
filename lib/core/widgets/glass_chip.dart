/// Widget GlassChip - Chip avec effet glassmorphisme Liquid Glass
/// 
/// Chips réutilisables avec :
/// - Effet de verre
/// - Support de sélection
/// - Icônes optionnelles
/// - Callbacks de suppression
/// 
/// Usage typique :
/// ```dart
/// GlassChip(
///   label: 'Pectoraux',
///   backgroundColor: AppColors.muscleGroupColors['pectoraux'],
///   onTap: () => print('Selected'),
/// )
/// ```

import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_decorations.dart';
import '../theme/app_typography.dart';

/// Widget de chip avec effet glassmorphisme
/// 
/// Support :
/// - État sélectionné/non sélectionné
/// - Icônes leading/trailing
/// - Callback de suppression
/// - Couleur de fond personnalisée
/// - Animation au tap
class GlassChip extends StatefulWidget {
  /// Label du chip
  final String label;

  /// Callback au tap
  final VoidCallback? onTap;

  /// Callback à la suppression (affiche icône delete si fourni)
  final VoidCallback? onDeleted;

  /// Icône à gauche du label
  final IconData? leadingIcon;

  /// Widget à gauche du label
  final Widget? avatar;

  /// Si true, le chip est sélectionné
  final bool isSelected;

  /// Couleur de fond personnalisée
  final Color? backgroundColor;

  /// Couleur du label
  final Color? labelColor;

  /// Taille du chip
  final double height;

  /// Padding horizontal du chip
  final double horizontalPadding;

  const GlassChip({
    super.key,
    required this.label,
    this.onTap,
    this.onDeleted,
    this.leadingIcon,
    this.avatar,
    this.isSelected = false,
    this.backgroundColor,
    this.labelColor,
    this.height = 36,
    this.horizontalPadding = 12,
  });

  @override
  State<GlassChip> createState() => _GlassChipState();
}

class _GlassChipState extends State<GlassChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
      widget.onTap!();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    if (widget.backgroundColor != null) {
      return widget.isSelected
          ? widget.backgroundColor!
          : widget.backgroundColor!.withOpacity(0.3);
    }

    return widget.isSelected
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5);
  }

  Color _getLabelColor(BuildContext context) {
    if (widget.labelColor != null) {
      return widget.labelColor!;
    }

    return widget.isSelected
        ? Theme.of(context).colorScheme.onPrimaryContainer
        : Theme.of(context).colorScheme.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor(context);
    final labelColor = _getLabelColor(context);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.height / 2),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              height: widget.height,
              padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(widget.height / 2),
                border: Border.all(
                  color: widget.isSelected
                      ? labelColor.withOpacity(0.2)
                      : Colors.transparent,
                  width: 1,
                ),
                boxShadow: widget.isSelected
                    ? AppDecorations.shadowLight(context)
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar ou icône leading
                  if (widget.avatar != null) ...[
                    widget.avatar!,
                    const SizedBox(width: 8),
                  ] else if (widget.leadingIcon != null) ...[
                    Icon(
                      widget.leadingIcon,
                      size: 18,
                      color: labelColor,
                    ),
                    const SizedBox(width: 6),
                  ],

                  // Label
                  Text(
                    widget.label,
                    style: AppTypography.labelMedium(context).copyWith(
                      color: labelColor,
                      fontWeight:
                          widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),

                  // Bouton de suppression
                  if (widget.onDeleted != null) ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: widget.onDeleted,
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: labelColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Chip filtrable pour sélection multiple
/// 
/// Version spécialisée incluant :
/// - Gestion automatique de l'état sélectionné
/// - Callback avec valeur de sélection
/// - Animation de sélection
class GlassFilterChip<T> extends StatelessWidget {
  /// Label du chip
  final String label;

  /// Valeur associée au chip
  final T value;

  /// Valeur actuellement sélectionnée
  final T? selectedValue;

  /// Callback de sélection
  final void Function(T value)? onSelected;

  /// Icône à gauche du label
  final IconData? icon;

  /// Couleur de fond personnalisée
  final Color? backgroundColor;

  const GlassFilterChip({
    super.key,
    required this.label,
    required this.value,
    required this.selectedValue,
    this.onSelected,
    this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedValue;

    return GlassChip(
      label: label,
      isSelected: isSelected,
      leadingIcon: icon,
      backgroundColor: backgroundColor,
      onTap: onSelected != null ? () => onSelected!(value) : null,
    );
  }
}

/// Groupe de chips pour sélection multiple
/// 
/// Affiche une liste de chips avec gestion automatique :
/// - Wrap automatique sur plusieurs lignes
/// - Gestion de sélection unique ou multiple
/// - Espacement configuré
class GlassChipGroup<T> extends StatelessWidget {
  /// Liste des items à afficher
  final List<T> items;

  /// Builder pour afficher chaque chip
  final Widget Function(BuildContext context, T item, bool isSelected) chipBuilder;

  /// Valeur(s) actuellement sélectionnée(s)
  final Set<T> selectedValues;

  /// Callback de sélection
  final void Function(T value)? onSelected;

  /// Si true, permet la sélection multiple
  final bool multipleSelection;

  /// Espacement entre les chips
  final double spacing;

  /// Espacement vertical entre les lignes
  final double runSpacing;

  const GlassChipGroup({
    super.key,
    required this.items,
    required this.chipBuilder,
    required this.selectedValues,
    this.onSelected,
    this.multipleSelection = false,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  void _handleSelection(T value) {
    if (onSelected != null) {
      onSelected!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: items.map((item) {
        final isSelected = selectedValues.contains(item);
        return GestureDetector(
          onTap: () => _handleSelection(item),
          child: chipBuilder(context, item, isSelected),
        );
      }).toList(),
    );
  }
}

/// Chip de statut avec indicateur coloré
/// 
/// Version spécialisée pour afficher un statut :
/// - Point coloré à gauche
/// - Label descriptif
/// - Couleur automatique selon le statut
class GlassStatusChip extends StatelessWidget {
  /// Label du chip
  final String label;

  /// Couleur du statut (point à gauche)
  final Color statusColor;

  /// Si true, affiche le point de statut
  final bool showStatusIndicator;

  const GlassStatusChip({
    super.key,
    required this.label,
    required this.statusColor,
    this.showStatusIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    return GlassChip(
      label: label,
      avatar: showStatusIndicator
          ? Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            )
          : null,
      backgroundColor: statusColor.withOpacity(0.15),
      labelColor: statusColor,
    );
  }
}
