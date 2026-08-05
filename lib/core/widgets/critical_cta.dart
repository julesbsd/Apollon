import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'rayon_sweep.dart';

/// CriticalCta
/// -----------
/// Bouton d'action critique "Terminer la seance" selon la spec E6-e :
/// - hauteur 68, contenu sur deux lignes (titre + sous-titre),
/// - degrade vertical clair #1B5F97 -> #0E3A62 / sombre #3F86C6 -> #255F97,
/// - filet d'or sur l'arete haute qui s'illumine au clic (RayonSweep declenche
///   sur l'appui),
/// - etat desactive : pas de filet d'or, degrade grise, libelle de rappel
///   ('Ajoute une serie pour terminer') passe via [disabledLabel].
///
/// Purement presentationnel : [onPressed] porte l'action metier existante
/// (aucune logique de navigation/etat n'est encodee ici).
class CriticalCta extends StatefulWidget {
  const CriticalCta({
    super.key,
    required this.enabled,
    required this.title,
    required this.subtitle,
    required this.disabledLabel,
    required this.onPressed,
  });

  final bool enabled;
  final String title;
  final String subtitle;
  final String disabledLabel;
  final VoidCallback onPressed;

  @override
  State<CriticalCta> createState() => _CriticalCtaState();
}

class _CriticalCtaState extends State<CriticalCta> {
  // Bascule de declenchement du RayonSweep : un flip a chaque appui illumine
  // le filet d'or (passage unique, cf. contrat RayonSweep).
  bool _sweep = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabled = widget.enabled;
    final goldLine = isDark ? AppTheme.accentGoldLine : AppTheme.lightAccentGoldLine;
    // Texte du CTA : blanc en clair (fond bleu fonce #0E3A62), encre sombre
    // en mode sombre (fond bleu clair #3F86C6) - le blanc y tomberait a
    // 3,x:1 de contraste, sous le seuil AA. Ratios verifies dans la DA.
    final onCta = isDark ? const Color(0xFF08101B) : Colors.white;

    final gradientColors = enabled
        ? (isDark
            ? const [Color(0xFF3F86C6), Color(0xFF255F97)]
            : const [Color(0xFF1B5F97), Color(0xFF0E3A62)])
        // Desactive : degrade grise, sans filet d'or.
        : [
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.18),
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
          ];

    final content = Container(
      height: 68,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
        // Filet d'or sur l'arete haute, uniquement a l'etat actif.
        border: enabled
            ? Border(
                top: BorderSide(color: goldLine, width: 1.5),
              )
            : null,
      ),
      child: enabled
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: onCta,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    color: onCta.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          : Text(
              widget.disabledLabel,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
    );

    return Opacity(
      opacity: enabled ? 1 : 1,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          onTap: enabled
              ? () {
                  setState(() => _sweep = !_sweep); // illumine le filet
                  widget.onPressed();
                }
              : null,
          // Le filet d'or s'illumine au clic via un passage RayonSweep unique.
          child: enabled
              ? RayonSweep(
                  trigger: _sweep,
                  color: AppTheme.accentGold.withValues(alpha: 0.35),
                  child: content,
                )
              : content,
        ),
      ),
    );
  }
}
