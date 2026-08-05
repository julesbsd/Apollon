import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// RayonSweep
/// ----------
/// Widget decoratif qui fait traverser une fine bande lumineuse (glow)
/// sur la surface de son enfant, de gauche a droite, en un seul passage
/// a chaque activation du parametre [trigger].
///
/// Choix d'implementation :
/// - Un unique [AnimationController] pilote la progression du balayage
///   (0.0 -> 1.0), avec la courbe [Curves.easeInOutCubic] imposee par la
///   consigne pour un mouvement fluide et naturel (acceleration puis
///   deceleration).
/// - La bande est rendue via [ShaderMask] + [LinearGradient] : on peint un
///   degrade transparent-couleur-transparent dont on deplace la position
///   (stops) en fonction de la valeur d'animation, plutot que de deplacer
///   un widget avec [Transform.translate] sur un calque separe. Cette
///   approche evite tout `BackdropFilter` (couteux en performance, cf.
///   consigne) et reste tres legere car [ShaderMask] ne recompose que le
///   shader, pas de flou gaussien.
/// - Une legere inclinaison (skew) de 18 degres est simulee en decalant la
///   position horizontale du degrade en fonction de la coordonnee
///   verticale via un [GradientTransform] custom (matrice de cisaillement),
///   ce qui donne l'effet d'une bande inclinee sans recourir a un
///   [Transform] sur un ClipRRect separe (plus simple et moins couteux
///   qu'un empilement de calques).
/// - Un seul passage par activation : on ecoute les changements de
///   [trigger] (true -> declenche un `forward` depuis 0, avec `reset()`
///   prealable) ; il n'y a PAS de repetition automatique (`repeat()` n'est
///   jamais appele), conformement a la consigne "pas de boucle par
///   defaut".
/// - Respect de `MediaQuery.of(context).disableAnimations` : si ce
///   parametre d'accessibilite est actif, on saute directement
///   l'animation (le controller est place a sa valeur finale sans jouer
///   les frames intermediaires), afin de ne pas perturber les
///   utilisateurs sensibles aux animations tout en gardant le rendu
///   final coherent (pas de bande visible bloquee au milieu).
///
/// Couleur par defaut :
/// - Theme clair : blanc a 92% d'opacite (aspect "reflet lumineux").
/// - Theme sombre : or a 30% d'opacite. Note : la consigne mentionne un
///   token `accentGoldGlow` du theme applicatif ; ce token n'existe pas
///   dans `lib/core/theme/` (ni dans `AppTheme`, ni dans l'ancien systeme
///   `AppColors`/`AppDecorations`) au moment de l'implementation. On
///   utilise donc une constante locale `_defaultGoldGlow` (or,
///   0xFFFFC94A) comme valeur de repli documentee, en attendant qu'un tel
///   token soit ajoute au design system.
class RayonSweep extends StatefulWidget {
  const RayonSweep({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 620),
    this.color,
    this.trigger = true,
  });

  /// Widget sur lequel le rayon lumineux doit balayer.
  final Widget child;

  /// Duree d'un passage complet du rayon.
  final Duration duration;

  /// Couleur du rayon. Si `null`, une couleur par defaut est choisie selon
  /// le theme (clair/sombre) - voir doc de la classe.
  final Color? color;

  /// Bascule qui declenche un nouveau passage. Un changement de valeur de
  /// `trigger` (y compris false -> true ou true -> false) demarre un
  /// unique passage du rayon, sans boucle.
  final bool trigger;

  @override
  State<RayonSweep> createState() => _RayonSweepState();
}

class _RayonSweepState extends State<RayonSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _initialSweepDone = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    // NB : le premier passage eventuel (si trigger est deja actif au
    // montage) est declenche dans didChangeDependencies plutot qu'ici,
    // car MediaQuery.of(context) ne peut pas etre consulte depuis
    // initState() (l'arbre InheritedWidget n'est pas encore disponible).
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialSweepDone) {
      _initialSweepDone = true;
      if (widget.trigger) {
        _runSweep();
      }
    }
  }

  @override
  void didUpdateWidget(covariant RayonSweep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    // Tout changement de `trigger` relance un unique passage.
    if (oldWidget.trigger != widget.trigger) {
      _runSweep();
    }
  }

  void _runSweep() {
    final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations) {
      // On saute l'animation : pas de frames intermediaires jouees, on
      // place directement le controller a l'etat final (rayon disparu).
      _controller.value = 1.0;
      return;
    }
    // reset() garantit qu'un seul passage se joue (pas de cumul/boucle),
    // meme si un passage precedent etait encore en cours.
    _controller
      ..stop()
      ..reset()
      ..forward();
  }

  Color _resolveColor(BuildContext context) {
    if (widget.color != null) return widget.color!;
    final brightness = Theme.of(context).brightness;
    if (brightness == Brightness.dark) {
      return AppTheme.accentGoldGlowDark.withValues(alpha: 0.30);
    }
    return Colors.white.withValues(alpha: 0.92);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _resolveColor(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOutCubic.transform(_controller.value);
        return ShaderMask(
          blendMode: BlendMode.plus,
          shaderCallback: (Rect bounds) {
            return _SweepGradient(
              progress: t,
              color: color,
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Degrade lineaire representant la bande lumineuse inclinee.
///
/// La largeur de bande varie entre 30 et 58px (interpolee sur la course du
/// balayage) et l'inclinaison de 18 degres est appliquee via une matrice
/// de cisaillement (skew) dans [createShader], sans widget de rotation
/// supplementaire.
class _SweepGradient extends LinearGradient {
  _SweepGradient({required this.progress, required this.color})
      : super(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            color.withValues(alpha: 0.0),
            color,
            color.withValues(alpha: 0.0),
          ],
        );

  final double progress;
  final Color color;

  static const double _minBandWidthPx = 30.0;
  static const double _maxBandWidthPx = 58.0;
  static const double _skewDegrees = 18.0;

  @override
  Shader createShader(Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    if (width <= 0) {
      return super.createShader(rect, textDirection: textDirection);
    }

    // Largeur de bande interpolee (leger "respire" entre 30 et 58px sur la
    // course du balayage, pic au milieu du passage).
    final bandWidthPx = _minBandWidthPx +
        (_maxBandWidthPx - _minBandWidthPx) * math.sin(progress * math.pi);
    final bandWidthFraction = (bandWidthPx / width).clamp(0.0, 1.0);

    // La position centrale du rayon va de -bandWidth a (1 + bandWidth) afin
    // que le rayon entre et sorte completement de la surface.
    final center = -bandWidthFraction + progress * (1 + 2 * bandWidthFraction);
    final left = (center - bandWidthFraction / 2).clamp(-1.0, 2.0);
    final right = (center + bandWidthFraction / 2).clamp(-1.0, 2.0);
    final mid = ((left + right) / 2).clamp(-1.0, 2.0);

    final stops = <double>[
      _normalizeStop(left),
      _normalizeStop(mid),
      _normalizeStop(right),
    ];

    final skewedGradient = LinearGradient(
      begin: begin,
      end: end,
      colors: colors,
      stops: stops,
      transform: _SkewGradientTransform(degrees: _skewDegrees),
    );

    return skewedGradient.createShader(rect, textDirection: textDirection);
  }

  double _normalizeStop(double value) {
    // Les stops d'un Gradient doivent rester dans [0, 1] ; on clamse les
    // valeurs hors bornes vers 0 ou 1 tout en gardant l'ordre croissant.
    return value.clamp(0.0, 1.0);
  }
}

/// Applique un cisaillement horizontal au degrade pour simuler
/// l'inclinaison de 18 degres de la bande lumineuse.
class _SkewGradientTransform extends GradientTransform {
  const _SkewGradientTransform({required this.degrees});

  final double degrees;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final skew = math.tan(degrees * math.pi / 180);
    // Cisaillement autour du centre du rectangle pour garder la bande
    // centree visuellement pendant le balayage.
    final matrix = Matrix4.identity()
      ..translateByDouble(bounds.center.dx, bounds.center.dy, 0.0, 1.0)
      ..multiply(Matrix4(
        1.0, 0.0, 0.0, 0.0,
        skew, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0,
      ))
      ..translateByDouble(-bounds.center.dx, -bounds.center.dy, 0.0, 1.0);
    return matrix;
  }
}
