import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// MarbleCard - carte "Marbre & Lumiere", veinage par degrades superposes.
///
/// GARDE-FOU (spec design, section 07) : reservee a UNE seule carte par
/// ecran - celle qui porte le sens (progression, record, bilan de seance).
/// Ne pas l'utiliser pour des listes ou des tuiles repetitives : AppCard
/// standard est le bon choix pour ces cas.
///
/// Implementation : DEUX degrades lineaires superposes (112deg et 24deg,
/// tres basse opacite) simulent le veinage du marbre - aucune image,
/// aucune texture bitmap, aucun bruit. Contrairement a la version
/// glassmorphism precedente, ce widget ne pose PAS de `BackdropFilter`
/// (flou de fond couteux et explicitement exclu par la spec pour ce
/// composant).
class MarbleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool showBorder;
  final double? width;
  final double? height;

  const MarbleCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.showBorder = true,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final r = BorderRadius.circular(AppTheme.radiusXL);

    final baseColor = isDark ? const Color(0xFF121826) : const Color(0xFFF8F5EF);
    final veinLight1 = isDark
        ? const [Color(0xE626313F), Color(0xE610162A), Color(0xE6222C3A)]
        : const [Color(0xE6FFFFFF), Color(0x8CEDE8DE), Color(0xD9FFFFFF)];
    final goldVein = isDark ? const Color(0xFFD9B978) : const Color(0xFFB08D57);
    final outline = isDark ? AppTheme.outlineSubtleDark : AppTheme.outlineSubtleLight;
    final goldBorder = (isDark ? AppTheme.accentGoldLine : AppTheme.lightAccentGoldLine).withValues(alpha: 0.30);

    final cardContent = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(borderRadius: r, boxShadow: AppTheme.shadowElev2(theme.brightness)),
      child: ClipRRect(
        borderRadius: r,
        child: Stack(
          children: [
            // Fond plein (base ardoise/marbre).
            Positioned.fill(child: ColoredBox(color: baseColor)),
            // Veinage 1 : degrade 112deg, tres basse opacite.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: const Alignment(-0.7, -1),
                    end: const Alignment(0.7, 1),
                    colors: veinLight1,
                    stops: const [0.0, 0.44, 1.0],
                  ),
                ),
              ),
            ),
            // Veinage 2 : filet d'or diffus a 24deg, tres basse opacite,
            // decoratif uniquement (jamais porteur de sens - cf. accentGoldGlow).
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: const Alignment(-1, -0.3),
                    end: const Alignment(1, 0.3),
                    colors: [
                      goldVein.withValues(alpha: isDark ? 0.13 : 0.16),
                      goldVein.withValues(alpha: 0),
                    ],
                    stops: const [0.0, 0.56],
                  ),
                ),
              ),
            ),
            // Bordure : filet or tres discret + trait de separation standard.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: showBorder ? Border.all(color: goldBorder, width: 1.5) : Border.all(color: outline, width: 1),
                  borderRadius: r,
                ),
              ),
            ),
            Padding(
              padding: padding ?? const EdgeInsets.all(20),
              child: child,
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, borderRadius: r, child: cardContent),
      );
    }

    return cardContent;
  }
}
