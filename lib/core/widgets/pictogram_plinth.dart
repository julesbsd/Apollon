import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// PictogramPlinth
/// ---------------
/// Socle en degrade ardoise place SOUS un pictogramme d'exercice. La consigne
/// interdit de poser un pictogramme directement sur `surface`/`surfaceVariant` :
/// ce widget fournit le fond dedie.
///
/// Caracteristiques (consigne E6-a) :
/// - Degrade ardoise [AppTheme.pictogramPlinthTop] -> [pictogramPlinthBottom].
/// - Inclinaison du degrade a 160deg par defaut (168deg pour le bandeau large
///   d'en-tete, via [angleDegrees]).
/// - Filet interne blanc en haut (lisere lumineux) simulant une arete eclairee.
/// - Rayon parametrable : 11 pour la vignette 58x58, 16 pour le bandeau 186px.
///
/// Le socle utilise une ardoise legerement differente par theme
/// ([AppTheme.pictogramPlinthTopLight]/[pictogramPlinthTopDark], idem pour
/// Bottom) - assez proche pour rester un fond neutre constant, assez
/// distincte pour ne pas trancher avec la surface environnante.
class PictogramPlinth extends StatelessWidget {
  const PictogramPlinth({
    super.key,
    required this.child,
    this.radius = 11,
    this.angleDegrees = 160,
    this.width,
    this.height,
    this.padding,
  });

  final Widget child;
  final double radius;
  final double angleDegrees;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  /// Convertit un angle en degres (convention CSS : 0deg = vers le haut, sens
  /// horaire) en couple begin/end pour un [LinearGradient] Flutter.
  static (Alignment, Alignment) _alignmentsFor(double degrees) {
    final rad = (degrees - 90) * math.pi / 180.0;
    final dx = math.cos(rad);
    final dy = math.sin(rad);
    return (Alignment(-dx, -dy), Alignment(dx, dy));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (begin, end) = _alignmentsFor(angleDegrees);
    final r = BorderRadius.circular(radius);
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: r,
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: [
            isDark ? AppTheme.pictogramPlinthTopDark : AppTheme.pictogramPlinthTopLight,
            isDark ? AppTheme.pictogramPlinthBottomDark : AppTheme.pictogramPlinthBottomLight,
          ],
        ),
        // Filet interne blanc en haut : arete eclairee du socle (14% clair, 12% sombre).
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.14), width: 1),
        ),
      ),
      child: ClipRRect(borderRadius: r, child: child),
    );
  }
}

/// Pastille carree identifiant un groupe musculaire (consigne E6-b).
/// 7px de cote, radius 2, remplie de la teinte du groupe
/// ([AppTheme.colorForMuscleCode]). Jamais utilisee en aplat de fond : c'est un
/// simple marqueur pose a cote du libelle.
class MuscleGroupDot extends StatelessWidget {
  const MuscleGroupDot({super.key, required this.muscleCode, this.size = 7});

  final String? muscleCode;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.colorForMuscleCode(muscleCode),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
