/// Widget GlassBottomSheet - Modal bottom sheet avec effet glassmorphisme
/// 
/// Bottom sheet réutilisable avec :
/// - Effet de verre sur toute la surface
/// - Poignée de glissement (drag handle)
/// - Support de scroll automatique
/// - Hauteur configurable
/// 
/// Usage typique :
/// ```dart
/// GlassBottomSheet.show(
///   context: context,
///   title: 'Sélectionner un exercice',
///   child: ExerciseListWidget(),
/// )
/// ```

import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_decorations.dart';
import '../theme/app_typography.dart';

/// Widget de bottom sheet avec effet glassmorphisme
/// 
/// Affiche une feuille modale en bas de l'écran avec :
/// - Fond vitré avec flou d'arrière-plan
/// - Poignée de glissement visuelle
/// - Titre optionnel
/// - Actions optionnelles (boutons en haut à droite)
/// - Support de scroll pour contenu long
class GlassBottomSheet extends StatelessWidget {
  /// Contenu du bottom sheet
  final Widget child;

  /// Titre optionnel affiché en haut
  final String? title;

  /// Actions optionnelles (boutons) affichées en haut à droite
  final List<Widget>? actions;

  /// Hauteur maximale du bottom sheet (défaut: 80% de l'écran)
  final double? maxHeight;

  /// Si true, le bottom sheet peut être élargi en plein écran
  final bool isExpandable;

  /// Si true, affiche la poignée de glissement
  final bool showDragHandle;

  /// Si true, le contenu peut scroller
  final bool scrollable;

  /// Padding interne du contenu
  final EdgeInsetsGeometry? contentPadding;

  const GlassBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.maxHeight,
    this.isExpandable = false,
    this.showDragHandle = true,
    this.scrollable = true,
    this.contentPadding,
  });

  /// Affiche le bottom sheet avec effet glassmorphisme
  /// 
  /// Utilise showModalBottomSheet avec configuration optimisée
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    List<Widget>? actions,
    double? maxHeight,
    bool isExpandable = false,
    bool showDragHandle = true,
    bool scrollable = true,
    EdgeInsetsGeometry? contentPadding,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (context) => GlassBottomSheet(
        title: title,
        actions: actions,
        maxHeight: maxHeight,
        isExpandable: isExpandable,
        showDragHandle: showDragHandle,
        scrollable: scrollable,
        contentPadding: contentPadding,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final effectiveMaxHeight = maxHeight ?? screenHeight * 0.8;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: effectiveMaxHeight + bottomPadding,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(32),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.surface.withOpacity(0.85)
                  : Theme.of(context).colorScheme.surface.withOpacity(0.90),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                if (showDragHandle) _buildDragHandle(context),

                // Header avec titre et actions
                if (title != null || actions != null) _buildHeader(context),

                // Contenu principal
                Flexible(
                  child: Padding(
                    padding: contentPadding ??
                        EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 16 + bottomPadding,
                        ),
                    child: scrollable
                        ? SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: child,
                          )
                        : child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 16),
      child: Row(
        children: [
          // Titre
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: AppTypography.titleLarge(context),
              ),
            ),

          // Actions
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

/// Bottom sheet de sélection avec recherche
/// 
/// Version spécialisée incluant :
/// - Barre de recherche intégrée
/// - Liste filtrable d'items
/// - Gestion de la sélection
class GlassSelectionBottomSheet<T> extends StatefulWidget {
  /// Liste des items à afficher
  final List<T> items;

  /// Builder pour afficher chaque item
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// Callback de sélection d'item
  final void Function(T item)? onItemSelected;

  /// Fonction de recherche (retourne true si l'item correspond à la query)
  final bool Function(T item, String query) searchFilter;

  /// Titre du bottom sheet
  final String? title;

  /// Placeholder de la barre de recherche
  final String? searchHint;

  /// Si true, ferme le bottom sheet après sélection
  final bool closeOnSelection;

  const GlassSelectionBottomSheet({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.searchFilter,
    this.onItemSelected,
    this.title,
    this.searchHint,
    this.closeOnSelection = true,
  });

  /// Affiche le bottom sheet de sélection
  static Future<T?> show<T>({
    required BuildContext context,
    required List<T> items,
    required Widget Function(BuildContext context, T item) itemBuilder,
    required bool Function(T item, String query) searchFilter,
    void Function(T item)? onItemSelected,
    String? title,
    String? searchHint,
    bool closeOnSelection = true,
  }) {
    return GlassBottomSheet.show<T>(
      context: context,
      title: title,
      scrollable: false,
      contentPadding: EdgeInsets.zero,
      child: GlassSelectionBottomSheet<T>(
        items: items,
        itemBuilder: itemBuilder,
        searchFilter: searchFilter,
        onItemSelected: onItemSelected,
        searchHint: searchHint,
        closeOnSelection: closeOnSelection,
      ),
    );
  }

  @override
  State<GlassSelectionBottomSheet<T>> createState() =>
      _GlassSelectionBottomSheetState<T>();
}

class _GlassSelectionBottomSheetState<T>
    extends State<GlassSelectionBottomSheet<T>> {
  late TextEditingController _searchController;
  late List<T> _filteredItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => widget.searchFilter(item, query))
            .toList();
      }
    });
  }

  void _handleItemSelected(T item) {
    widget.onItemSelected?.call(item);
    if (widget.closeOnSelection) {
      Navigator.of(context).pop(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Barre de recherche
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: widget.searchHint ?? 'Rechercher...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: AppDecorations.borderRadiusMedium,
              ),
              filled: true,
            ),
          ),
        ),

        const Divider(height: 1),

        // Liste des résultats
        Flexible(
          child: _filteredItems.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun résultat',
                          style: AppTypography.bodyLarge(context).copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _filteredItems.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    return InkWell(
                      onTap: () => _handleItemSelected(item),
                      child: widget.itemBuilder(context, item),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
