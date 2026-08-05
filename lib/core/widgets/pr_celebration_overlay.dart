import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/personal_record.dart';
import '../theme/app_theme.dart';
import 'marble_card.dart';
import 'rayon_sweep.dart';

/// Affiche la célébration des nouveaux Records Personnels (PR)
/// avec un voile plein écran, un cartouche marbre et une pluie
/// d'éclats d'or dessinés à la main (CustomPainter).
///
/// Pourquoi l'abandon des confettis multicolores (package `confetti`) :
/// le rendu précédent utilisait un canon à confettis multicolores
/// (or/rouge/turquoise/bleu/vert/violet/orange, formes en étoile) qui
/// entre en conflit avec la direction artistique "Marbre & Lumière" du
/// reste de l'application : palette resserrée autour de l'or
/// (`accentGold`) et du marbre (`MarbleCard`), pas de couleurs saturées
/// hors-charte. Un feu multicolore attire l'oeil sur les confettis plutôt
/// que sur le chiffre du nouveau record, et rejoue une esthétique
/// générique de fête plutôt que la sobriété premium recherchée ailleurs
/// (Cinzel pour "RECORD", JetBrains Mono pour les valeurs). Le remplacement
/// par 14 éclats d'or rectangulaires (3px max), qui tombent lentement
/// (~900ms) avec une légère rotation, resserre la palette à une seule
/// teinte et fait du balayage RayonSweep (900ms) le seul moment de
/// mouvement large de l'écran.
///
/// Usage :
/// ```dart
/// await showPrCelebration(context, newPRs);
/// ```
Future<void> showPrCelebration(
  BuildContext context,
  List<PersonalRecord> newPRs,
) async {
  if (newPRs.isEmpty) return;

  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'PR Celebration',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _PrCelebrationDialog(newPRs: newPRs);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.elasticOut,
      );
      return ScaleTransition(scale: curved, child: child);
    },
  );
}

class _PrCelebrationDialog extends StatefulWidget {
  final List<PersonalRecord> newPRs;

  const _PrCelebrationDialog({required this.newPRs});

  @override
  State<_PrCelebrationDialog> createState() => _PrCelebrationDialogState();
}

class _PrCelebrationDialogState extends State<_PrCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _cardAnimController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Éclats d'or : 14 petits rectangles avec position/rotation/retard
  // aléatoires mais fixes (générés une seule fois à l'ouverture, pas à
  // chaque frame) pour une chute lente d'environ 900ms.
  static const int _shardCount = 14;
  late final List<_GoldShard> _shards;

  @override
  void initState() {
    super.initState();

    final random = math.Random();
    _shards = List.generate(_shardCount, (i) => _GoldShard.random(random));

    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(
      parent: _cardAnimController,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _cardAnimController,
        curve: Curves.easeOut,
      ),
    );

    _cardAnimController.forward();

    // Un unique retour haptique fort à l'ouverture de la célébration.
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _cardAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // ── Voile plein écran ──────────────────────────────────────
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              color: (isDark
                      ? AppTheme.darkOnBackground
                      : AppTheme.lightOnBackground)
                  .withValues(alpha: 0.88),
            ),
          ),
        ),

        // ── Pluie d'éclats d'or ─────────────────────────────────────
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _cardAnimController,
              builder: (_, _) => CustomPaint(
                painter: _GoldShardsPainter(
                  shards: _shards,
                  progress: _cardAnimController.value,
                  color: isDark ? AppTheme.accentGold : AppTheme.lightAccentGold,
                ),
              ),
            ),
          ),
        ),

        // ── Cartouche principal ──────────────────────────────────
        Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: RayonSweep(
                duration: const Duration(milliseconds: 900),
                child: _buildCartouche(context, theme, isDark),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartouche(BuildContext context, ThemeData theme, bool isDark) {
    final gold = isDark ? AppTheme.accentGold : AppTheme.lightAccentGold;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        // Bordure or 40% autour du cartouche : MarbleCard n'expose pas de
        // paramètre pour personnaliser la couleur de sa propre bordure
        // interne (elle est câblée sur primary/blanc), donc on désactive
        // celle-ci (`showBorder: false`) et on la superpose ici via un
        // Container englobant au même rayon (24px).
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: gold.withValues(alpha: 0.40),
              width: 1.5,
            ),
          ),
          child: MarbleCard(
          showBorder: false,
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'RECORD',
                style: GoogleFonts.cinzel(
                  fontSize: widget.newPRs.length == 1 ? 30 : 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.18 * (widget.newPRs.length == 1 ? 30 : 22),
                  color: gold,
                ),
              ),
              const SizedBox(height: 20),
              for (final pr in widget.newPRs) ...[
                _buildPrItem(pr, theme, isDark),
                const SizedBox(height: 14),
              ],
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: gold,
                    foregroundColor: Colors.black,
                  ),
                  child: Text(
                    'Continuer',
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrItem(PersonalRecord pr, ThemeData theme, bool isDark) {
    final weightStr = pr.weight == pr.weight.truncateToDouble()
        ? '${pr.weight.toInt()} kg'
        : '${pr.weight.toStringAsFixed(1)} kg';
    final mutedColor =
        (isDark ? AppTheme.darkOnBackground : AppTheme.lightOnBackground)
            .withValues(alpha: 0.5);

    return Column(
      children: [
        // Nom de l'exercice
        Text(
          pr.exerciseName.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.14 * 11,
            color: mutedColor,
          ),
        ),
        const SizedBox(height: 8),
        // NB : la consigne demande d'afficher l'ancienne valeur barrée
        // au-dessus de la nouvelle. C'est une impossibilité réelle avec le
        // modèle actuel : `PersonalRecord` (lib/core/models/personal_record.dart)
        // ne porte aucun champ `previousWeight`/`previousValue`, et
        // `StatisticsService.detectAndSaveNewPR` (qui produit ces objets)
        // ne renvoie que le nouveau PR, pas l'ancien qu'il a battu. Afficher
        // une ancienne valeur inventée serait trompeur ; ce bloc est donc
        // volontairement omis tant que la donnée n'existe pas côté service.
        Text(
          weightStr,
          style: GoogleFonts.jetBrainsMono(
            fontSize: widget.newPRs.length == 1 ? 56 : 46,
            fontWeight: FontWeight.w800,
            color: isDark ? AppTheme.accentGold : AppTheme.lightAccentGold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${pr.reps} rép.',
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: mutedColor,
          ),
        ),
      ],
    );
  }
}

/// Description figée d'un éclat d'or (position/rotation/retard),
/// générée une seule fois à l'ouverture de la célébration.
class _GoldShard {
  final double startXFraction; // position horizontale de depart (0..1)
  final double driftXFraction; // derive horizontale sur la chute
  final double startDelay; // fraction du timeline avant que l'eclat n'apparaisse
  final double rotationTurns; // rotation totale sur la chute
  final double size; // taille du cote (<= 3px)

  const _GoldShard({
    required this.startXFraction,
    required this.driftXFraction,
    required this.startDelay,
    required this.rotationTurns,
    required this.size,
  });

  factory _GoldShard.random(math.Random random) {
    return _GoldShard(
      startXFraction: random.nextDouble(),
      driftXFraction: (random.nextDouble() - 0.5) * 0.15,
      startDelay: random.nextDouble() * 0.3,
      rotationTurns: 0.5 + random.nextDouble() * 1.5,
      size: 1.5 + random.nextDouble() * 1.5, // 1.5 a 3.0 px
    );
  }
}

/// CustomPainter qui dessine les 14 éclats d'or en chute lente, en
/// remplacement du canon à confettis multicolores précédent (voir la
/// documentation en tête de fichier pour le pourquoi de ce choix).
class _GoldShardsPainter extends CustomPainter {
  final List<_GoldShard> shards;
  final double progress; // 0..1 sur les 900ms de _cardAnimController
  final Color color;

  _GoldShardsPainter({required this.shards, required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    for (final shard in shards) {
      // Chaque éclat démarre après son propre retard puis chute sur le
      // reste de la timeline, avec un fondu en sortie.
      final localT = ((progress - shard.startDelay) / (1 - shard.startDelay))
          .clamp(0.0, 1.0);
      if (localT <= 0) continue;

      final dy = localT * size.height * 0.6;
      final dx = (shard.startXFraction + shard.driftXFraction * localT) *
          size.width;
      final opacity = (1 - localT).clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(shard.rotationTurns * 2 * math.pi * localT);
      paint.color = color.withValues(alpha: opacity);
      final half = shard.size / 2;
      canvas.drawRect(
        Rect.fromLTWH(-half, -half, shard.size, shard.size),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _GoldShardsPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
