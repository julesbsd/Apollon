import 'package:flutter/material.dart';

/// Input TextField moderne Material 3
/// Support Dark et Light mode
/// Border radius 24px selon Design System
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool enabled;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.textInputAction,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      minLines: minLines,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      enabled: enabled,
      textInputAction: textInputAction,
      focusNode: focusNode,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: colorScheme.outline, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: colorScheme.outline, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

/// TextField pour saisie numérique (reps, poids)
/// Variant spécialisé pour les nombres
class AppNumberField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final bool isDecimal;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final String? suffix;

  const AppNumberField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.isDecimal = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      keyboardType: TextInputType.numberWithOptions(
        decimal: isDecimal,
        signed: false,
      ),
      prefixIcon: prefixIcon,
      suffixIcon:
          suffixIcon ??
          (suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      suffix!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                )
              : null),
      onChanged: onChanged,
      textInputAction: TextInputAction.done,
    );
  }
}
