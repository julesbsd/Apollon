import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// EmptyStateCard
/// --------------
/// Cartouche d'etat vide selon la spec E6-g :
/// - filet horizontal 22x1px en [AppTheme.accentGoldLine] au-dessus du titre,
/// - titre Cinzel 500 / 20,
/// - phrase Manrope 400 / 13,
/// - lien optionnel Manrope 700 / 13 en [AppTheme.primaryBlue],
/// - bordure accentGoldLine a 32% d'opacite, radius 14.
///
/// Manrope/Cinzel sont charges via GoogleFonts : ce sont les fontes de la
/// direction artistique demandee pour ces cartouches, distinctes de l'Inter du
/// corps applicatif.
class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.title,
    required this.message,
    this.linkLabel,
    this.onLinkTap,
  });

  final String title;
  final String message;
  final String? linkLabel;
  final VoidCallback? onLinkTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldLine = isDark ? AppTheme.accentGoldLine : AppTheme.lightAccentGoldLine;
    final primaryBlue = isDark ? AppTheme.primaryBlue : AppTheme.lightPrimaryBlue;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: goldLine.withValues(alpha: 0.32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Filet d'or horizontal 22x1px.
          Container(width: 22, height: 1, color: goldLine),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          if (linkLabel != null) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: onLinkTap,
              child: Text(
                linkLabel!,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: primaryBlue,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
