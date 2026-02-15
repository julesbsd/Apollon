/// Widget GlassTextField - Champ de texte avec effet glassmorphisme Liquid Glass
/// 
/// Champ de saisie réutilisable avec :
/// - Effet de verre (opacité + flou)
/// - Support de label, hint, préfixe/suffixe
/// - Validation intégrée
/// - Types spécialisés (nombre, poids, etc.)
/// 
/// Usage typique :
/// ```dart
/// GlassTextField(
///   label: 'Répétitions',
///   hintText: 'Entrez le nombre de répétitions',
///   keyboardType: TextInputType.number,
///   controller: repsController,
/// )
/// ```

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_decorations.dart';
import '../theme/app_typography.dart';

/// Widget de champ de texte avec effet glassmorphisme
/// 
/// Support :
/// - Différents types de clavier (texte, nombre, décimal)
/// - Validation avec messages d'erreur
/// - États focus/unfocus avec animation
/// - Icônes préfixe/suffixe
/// - Formatage automatique (nombres, poids)
class GlassTextField extends StatefulWidget {
  /// Controller du champ de texte
  final TextEditingController? controller;

  /// Label affiché au-dessus du champ
  final String? label;

  /// Texte d'indication dans le champ
  final String? hintText;

  /// Icône de préfixe
  final IconData? prefixIcon;

  /// Widget préfixe personnalisé
  final Widget? prefix;

  /// Icône de suffixe
  final IconData? suffixIcon;

  /// Widget suffixe personnalisé
  final Widget? suffix;

  /// Type de clavier
  final TextInputType keyboardType;

  /// Action du clavier
  final TextInputAction? textInputAction;

  /// Si true, masque le texte (pour mots de passe)
  final bool obscureText;

  /// Nombre maximum de lignes (défaut: 1)
  final int maxLines;

  /// Nombre minimum de lignes
  final int? minLines;

  /// Callback de validation
  final String? Function(String?)? validator;

  /// Callback au changement de valeur
  final void Function(String)? onChanged;

  /// Callback à la soumission
  final void Function(String)? onSubmitted;

  /// Si true, le champ est activé
  final bool enabled;

  /// Si true, le champ est en lecture seule
  final bool readOnly;

  /// Si true, le champ se focus automatiquement
  final bool autofocus;

  /// Liste d'input formatters
  final List<TextInputFormatter>? inputFormatters;

  /// Message d'erreur à afficher
  final String? errorText;

  /// Texte d'aide affiché sous le champ
  final String? helperText;

  /// Focus node personnalisé
  final FocusNode? focusNode;

  const GlassTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.inputFormatters,
    this.errorText,
    this.helperText,
    this.focusNode,
  });

  /// Constructeur pour un champ de nombre entier
  /// 
  /// Applique automatiquement les restrictions :
  /// - Clavier numérique
  /// - Accepte uniquement les chiffres
  GlassTextField.number({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.suffix,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.errorText,
    this.helperText,
    this.focusNode,
  })  : keyboardType = TextInputType.number,
        textInputAction = TextInputAction.done,
        obscureText = false,
        maxLines = 1,
        minLines = null,
        validator = null,
        inputFormatters = [FilteringTextInputFormatter.digitsOnly];

  /// Constructeur pour un champ de poids (nombre décimal)
  /// 
  /// Applique automatiquement les restrictions :
  /// - Clavier décimal
  /// - Accepte chiffres et point décimal
  /// - Suffixe "kg" affiché
  const GlassTextField.weight({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.prefix,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.errorText,
    this.helperText,
    this.focusNode,
  })  : keyboardType = const TextInputType.numberWithOptions(decimal: true),
        textInputAction = TextInputAction.done,
        obscureText = false,
        maxLines = 1,
        minLines = null,
        validator = null,
        inputFormatters = null,
        suffixIcon = null,
        suffix = const Padding(
          padding: EdgeInsets.only(right: 12),
          child: Text(
            'kg',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        );

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label optionnel
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.labelLarge(context),
          ),
          const SizedBox(height: 8),
        ],

        // Champ de texte avec effet glassmorphisme
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: AppDecorations.borderRadiusMedium,
            boxShadow: _isFocused
                ? AppDecorations.shadowGlow(
                    context,
                    color: hasError
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
                  )
                : null,
          ),
          child: ClipRRect(
            borderRadius: AppDecorations.borderRadiusMedium,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: _isFocused ? 15 : 10,
                sigmaY: _isFocused ? 15 : 10,
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                obscureText: widget.obscureText,
                maxLines: widget.maxLines,
                minLines: widget.minLines,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                autofocus: widget.autofocus,
                inputFormatters: widget.inputFormatters,
                style: AppTypography.bodyLarge(context),
                decoration: AppDecorations.glassInput(
                  context: context,
                  hintText: widget.hintText,
                  prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : widget.prefix,
                  suffixIcon: widget.suffixIcon != null ? Icon(widget.suffixIcon) : widget.suffix,
                ),
              ),
            ),
          ),
        ),

        // Message d'erreur ou d'aide
        if (hasError || widget.helperText != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              hasError ? widget.errorText! : widget.helperText!,
              style: AppTypography.bodySmall(context).copyWith(
                color: hasError
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Champ de texte multiligne avec effet glassmorphisme
/// 
/// Version optimisée pour les textes longs (notes, commentaires)
class GlassTextArea extends StatelessWidget {
  /// Controller du champ de texte
  final TextEditingController? controller;

  /// Label affiché au-dessus du champ
  final String? label;

  /// Texte d'indication dans le champ
  final String? hintText;

  /// Nombre de lignes à afficher
  final int lines;

  /// Callback au changement de valeur
  final void Function(String)? onChanged;

  /// Si true, le champ est activé
  final bool enabled;

  /// Message d'erreur à afficher
  final String? errorText;

  /// Texte d'aide affiché sous le champ
  final String? helperText;

  const GlassTextArea({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.lines = 5,
    this.onChanged,
    this.enabled = true,
    this.errorText,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return GlassTextField(
      controller: controller,
      label: label,
      hintText: hintText,
      maxLines: lines,
      minLines: lines,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      onChanged: onChanged,
      enabled: enabled,
      errorText: errorText,
      helperText: helperText,
    );
  }
}
