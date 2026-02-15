/// Widgets réutilisables avec effet glassmorphisme Liquid Glass
/// 
/// Ce fichier exporte tous les widgets custom du Design System Apollon.
/// 
/// Widgets disponibles :
/// - GlassCard : carte avec effet de verre
/// - GlassButton : boutons (primary, secondary, outlined, text)
/// - GlassIconButton : bouton icon circulaire
/// - GlassTextField : champ de texte avec effet glassmorphisme
/// - GlassTextArea : champ de texte multiligne
/// - GlassBottomSheet : modal bottom sheet avec effet de verre
/// - GlassSelectionBottomSheet : bottom sheet avec recherche
/// - GlassChip : chip avec effet glassmorphisme
/// - GlassFilterChip : chip filtrable pour sélection
/// - GlassChipGroup : groupe de chips avec gestion de sélection
/// - GlassStatusChip : chip de statut avec indicateur coloré
/// 
/// Usage :
/// ```dart
/// import 'package:apollon/core/widgets/glass_widgets.dart';
/// 
/// // Utiliser les widgets
/// GlassCard(
///   padding: EdgeInsets.all(16),
///   child: Text('Contenu'),
/// )
/// ```

library glass_widgets;

export 'glass_card.dart';
export 'glass_button.dart';
export 'glass_text_field.dart';
export 'glass_bottom_sheet.dart';
export 'glass_chip.dart';
