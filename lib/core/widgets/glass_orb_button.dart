import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'rayon_sweep.dart';

/// GlassOrbButton - l'orbe "Nouvelle seance", direction "Marbre & Lumiere".
///
/// Reecriture complete (l'implementation precedente etait une barre
/// glassmorphism horizontale avec BackdropFilter - contraire a la spec, qui
/// demande un orbe CIRCULAIRE en matiere, sans flou de fond).
///
/// Specs (section 07 de la DA) :
/// - Diametre 212 (168 minimum sur petits ecrans, applique automatiquement
///   si la largeur disponible est inferieure a 212+marge).
/// - Matiere : degrade radial 3 arrets, source lumineuse a 30%/18% - PAS de
///   flou de fond (`BackdropFilter` INTERDIT ici, c'est une matiere, pas du
///   glassmorphism).
/// - Bordure 1px (encre 10% clair / blanc 10% sombre) + filet interne blanc
///   en haut (highlight d'arete).
/// - Arc de progression : 3px, or, extremites rondes, depart a midi, piste a
///   9% d'opacite.
/// - Lueur : ombre portee coloree uniquement (pas de glow additif).
/// - Le Rayon (RayonSweep) : UN SEUL passage a l'apparition du widget, pas
///   de boucle continue.
/// - Presse : echelle 0.96, lueur resserree, retour haptique moyen.
/// - Desactive (onPressed == null) : arc gris, texte attenue, pas de Rayon.
class GlassOrbButton extends StatefulWidget {
  final String text;
  final String? subtitle;
  final double progress; // 0.0 a 1.0
  final VoidCallback? onPressed;
  final IconData icon;
  final bool isActive;

  const GlassOrbButton({
    super.key,
    required this.text,
    this.subtitle,
    this.progress = 0.0,
    this.onPressed,
    this.icon = Icons.add_circle_outline,
    this.isActive = false,
  });

  @override
  State<GlassOrbButton> createState() => _GlassOrbButtonState();
}

class _GlassOrbButtonState extends State<GlassOrbButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final enabled = widget.onPressed != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSide = constraints.maxWidth.isFinite ? constraints.maxWidth : 212.0;
        final diameter = maxSide < 212 ? maxSide.clamp(168.0, 212.0) : 212.0;

        Widget orb = AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.4, -0.64), // source a 30%/18%
                radius: 1.1,
                colors: isDark
                    ? const [Color(0xFF26313F), Color(0xFF161E2B), Color(0xFF0B1017)]
                    : const [Color(0xFFFFFFFF), Color(0xFFF7F4EE), Color(0xFFE7E1D6)],
              ),
              border: Border.all(
                color: (isDark ? Colors.white : AppTheme.lightOnBackground).withValues(alpha: 0.10),
                width: 1,
              ),
              boxShadow: [
                // Lueur : ombre portee coloree, resserree quand pressee -
                // jamais un glow additif superpose.
                BoxShadow(
                  color: (isDark ? Colors.black : AppTheme.lightOnBackground).withValues(alpha: isDark ? 0.6 : 0.14),
                  blurRadius: _pressed ? 20 : 34,
                  offset: Offset(0, _pressed ? 8 : 16),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Filet interne blanc en haut (highlight d'arete).
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: isDark ? 0.10 : 0.6),
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
                CustomPaint(
                  size: Size.square(diameter),
                  painter: _OrbArcPainter(
                    progress: widget.progress.clamp(0.0, 1.0),
                    color: enabled
                        ? (isDark ? AppTheme.accentGoldLine : AppTheme.lightAccentGoldLine)
                        : (isDark ? AppTheme.darkOnSurfaceMuted : AppTheme.lightOnSurfaceMuted),
                    trackOpacity: 0.09,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: widget.isActive
                      ? _buildActiveContent(isDark, enabled)
                      : _buildInactiveContent(isDark, enabled),
                ),
              ],
            ),
          ),
        );

        // Un seul passage du Rayon a l'apparition, desactive si le bouton
        // est desactive (cf. spec "Desactive : ... pas de Rayon").
        //
        // ClipOval obligatoire ici : RayonSweep peint son reflet via un
        // ShaderMask en BlendMode.plus, qui est additif et ignore l'alpha
        // du fond en dehors de la forme visible de l'enfant - sans ce clip,
        // le reflet deborde dans les 4 coins du carre englobant du cercle
        // (bug reel corrige, cf. maquette qui a overflow:hidden sur ce
        // conteneur).
        if (enabled) {
          orb = ClipOval(
            child: RayonSweep(
              trigger: true,
              color: Colors.white.withValues(alpha: isDark ? 0.30 : 0.92),
              child: orb,
            ),
          );
        }

        return Center(
          child: GestureDetector(
            onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
            onTapUp: enabled
                ? (_) {
                    setState(() => _pressed = false);
                    HapticFeedback.mediumImpact();
                    widget.onPressed?.call();
                  }
                : null,
            onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
            child: orb,
          ),
        );
      },
    );
  }

  Widget _buildInactiveContent(bool isDark, bool enabled) {
    final labelColor = enabled
        ? (isDark ? AppTheme.darkOnBackground : AppTheme.lightOnBackground)
        : (isDark ? AppTheme.darkOnSurfaceMuted : AppTheme.lightOnSurfaceMuted);
    final captionColor = isDark ? AppTheme.darkOnSurfaceMuted : AppTheme.lightOnSurfaceMuted;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(widget.icon, size: 34, color: labelColor),
        const SizedBox(height: 8),
        Text('SEANCE', style: AppTheme.labelSecondary(captionColor)),
        const SizedBox(height: 2),
        Text(
          widget.text,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.screenTitle(labelColor).copyWith(fontSize: 20),
        ),
      ],
    );
  }

  Widget _buildActiveContent(bool isDark, bool enabled) {
    final labelColor = isDark ? AppTheme.darkOnBackground : AppTheme.lightOnBackground;
    final captionColor = isDark ? AppTheme.darkOnSurfaceMuted : AppTheme.lightOnSurfaceMuted;
    final gold = isDark ? AppTheme.accentGold : AppTheme.lightAccentGold;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('SEANCE', style: AppTheme.labelSecondary(captionColor)),
        const SizedBox(height: 2),
        Text(
          widget.text,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.screenTitle(labelColor).copyWith(fontSize: 20),
        ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.subtitle!,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.timerNumber(captionColor).copyWith(fontSize: 12),
          ),
        ],
        const SizedBox(height: 4),
        Text('${(widget.progress.clamp(0.0, 1.0) * 100).toInt()} %', style: AppTheme.timerNumber(gold).copyWith(fontSize: 13)),
      ],
    );
  }
}

/// Trace l'arc de progression : 3px, extremites rondes, depart a midi,
/// piste a [trackOpacity] d'opacite - dessine legerement a l'interieur du
/// bord de l'orbe pour ne pas chevaucher la bordure de matiere.
class _OrbArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double trackOpacity;

  const _OrbArcPainter({required this.progress, required this.color, required this.trackOpacity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide / 2) - 6;
    const strokeWidth = 3.0;

    final track = Paint()
      ..color = color.withValues(alpha: trackOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;
    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    const startAngle = -3.1415926535 / 2; // midi
    final sweepAngle = 2 * 3.1415926535 * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, arc);
  }

  @override
  bool shouldRepaint(covariant _OrbArcPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color || oldDelegate.trackOpacity != trackOpacity;
}
