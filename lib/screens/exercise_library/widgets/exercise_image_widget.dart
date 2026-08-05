import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../core/services/exercise_library_repository.dart';

/// Widget pour afficher l'image d'un exercice avec la stratégie triple
/// 
/// - Top 20 exercices: affichage instantané depuis assets (SVG)
/// - Téléchargés: affichage depuis fichier local (PNG permanent)
/// - Autres: téléchargement depuis API + sauvegarde permanente (PNG)
class ExerciseImageWidget extends StatefulWidget {
  final String exerciseId;
  final double size;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  
  const ExerciseImageWidget({
    super.key,
    required this.exerciseId,
    this.size = 50,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  State<ExerciseImageWidget> createState() {
    return _ExerciseImageWidgetState();
  }
}

class _ExerciseImageWidgetState extends State<ExerciseImageWidget> {
  ImageSource? _imageSource;
  bool _isDownloading = false;
  String? _downloadError;
  bool _initialized = false;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      // Attendre que le frame soit complètement construit
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadImageSource();
        } else {
        }
      });
    }
  }

  /// ListView.builder recycle les elements par position : quand l'exercice
  /// affiche a une position donnee change (nouvel exerciseId) sans que
  /// Flutter ne recree le State (pas de Key stable sur la liste), le State
  /// precedent reste en place avec son ancienne image/erreur tant qu'aucun
  /// didUpdateWidget ne detecte explicitement ce changement et ne relance
  /// le chargement.
  @override
  void didUpdateWidget(covariant ExerciseImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exerciseId != widget.exerciseId) {
      setState(() {
        _imageSource = null;
        _isDownloading = false;
        _downloadError = null;
      });
      // Relancer le meme chargement que celui declenche depuis
      // didChangeDependencies, avec les memes garde-fous (mounted +
      // addPostFrameCallback pour eviter un setState pendant le build).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadImageSource();
        }
      });
    }
  }

  /// Charger la source de l'image
  /// Retourne null si l'exercice n'a pas d'image disponible (hasImage=false)
  Future<void> _loadImageSource() async {
    try {
      final repository = context.read<ExerciseLibraryRepository>();
      final source = await repository.getImageSource(widget.exerciseId);

      if (mounted) {
        if (source == null) {
          // Pas d'image disponible pour cet exercice → afficher avatar de repli
          setState(() {
            _imageSource = null;
            _downloadError = 'Aucune image disponible';
          });
        } else {
          setState(() {
            _imageSource = source;
          });

          // Si remote, télécharger automatiquement
          if (source.isRemote) {
            await _downloadImage(repository);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloadError = e.toString();
        });
      }
    }
  }
  
  /// Télécharger et sauvegarder l'image
  Future<void> _downloadImage(ExerciseLibraryRepository repository) async {
    if (_isDownloading) return;
    
    setState(() {
      _isDownloading = true;
      _downloadError = null;
    });
    
    try {
      final localPath = await repository.downloadImage(widget.exerciseId);
      
      
      if (mounted && localPath != null) {
        setState(() {
          _imageSource = ImageSource.local(localPath);
          _isDownloading = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _isDownloading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloadError = e.toString();
          _isDownloading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
      child: _imageSource == null
          ? _buildLoadingPlaceholder()
          : _buildImageWidget(),
    );
  }

  Widget _buildImageWidget() {
    final source = _imageSource!;
    
    if (source.isAsset) {
      return _buildAssetImage(source.path);
    } else if (source.isLocal) {
      return _buildLocalImage(source.path);
    } else {
      // Remote: afficher loading pendant téléchargement
      return _isDownloading
          ? _buildLoadingPlaceholder()
          : (_downloadError != null
              ? _buildErrorPlaceholder()
              : _buildLoadingPlaceholder());
    }
  }
  
  /// Afficher une image depuis les assets (SVG pré-téléchargés top 20)
  Widget _buildAssetImage(String assetPath) {
    return SvgPicture.asset(
      assetPath,
      width: widget.size == double.infinity ? null : widget.size,
      height: widget.size == double.infinity ? null : widget.size,
      fit: widget.fit,
      placeholderBuilder: (context) => _buildPlaceholder(),
    );
  }
  
  /// Afficher une image depuis le fichier local (SVG téléchargé)
  Widget _buildLocalImage(String localPath) {
    return SvgPicture.file(
      File(localPath),
      width: widget.size == double.infinity ? null : widget.size,
      height: widget.size == double.infinity ? null : widget.size,
      fit: widget.fit,
      placeholderBuilder: (context) => _buildPlaceholder(),
    );
  }
  
  /// Placeholder pendant le chargement
  Widget _buildLoadingPlaceholder() {
    final indicatorSize = widget.size == double.infinity ? 40.0 : widget.size * 0.4;
    return Container(
      width: widget.size == double.infinity ? null : widget.size,
      height: widget.size == double.infinity ? null : widget.size,
      color: Colors.grey[300],
      child: Center(
        child: SizedBox(
          width: indicatorSize,
          height: indicatorSize,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
  
  /// Placeholder vide (pour assets)
  Widget _buildPlaceholder() {
    return Container(
      width: widget.size == double.infinity ? null : widget.size,
      height: widget.size == double.infinity ? null : widget.size,
      color: Colors.grey[200],
    );
  }
  
  /// Placeholder en cas d'erreur
  Widget _buildErrorPlaceholder() {
    final iconSize = widget.size == double.infinity ? 50.0 : widget.size * 0.5;
    return Container(
      width: widget.size == double.infinity ? null : widget.size,
      height: widget.size == double.infinity ? null : widget.size,
      color: Colors.grey[200],
      child: Icon(
        Icons.fitness_center,
        size: iconSize,
        color: Colors.grey[400],
      ),
    );
  }
}

/// Variante pour afficher l'image en cercle (avatar)
class ExerciseImageAvatar extends StatelessWidget {
  final String exerciseId;
  final double radius;
  
  const ExerciseImageAvatar({
    super.key,
    required this.exerciseId,
    this.radius = 25,
  });
  
  @override
  Widget build(BuildContext context) {
    return ExerciseImageWidget(
      exerciseId: exerciseId,
      size: radius * 2,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(radius),
    );
  }
}

/// Variante pour les cards avec container neumorphique
class ExerciseImageContainer extends StatelessWidget {
  final String exerciseId;
  final double size;
  final Color? backgroundColor;
  
  const ExerciseImageContainer({
    super.key,
    required this.exerciseId,
    this.size = 56,
    this.backgroundColor,
  });
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // Neumorphism - Ombre claire en haut à gauche
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.9),
            blurRadius: 8,
            offset: const Offset(-4, -4),
          ),
          // Neumorphism - Ombre sombre en bas à droite
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.6)
                : colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ExerciseImageWidget(
          exerciseId: exerciseId,
          size: size - 16,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// Variante pour les thumbnails dans les listes
/// N'effectue PAS de téléchargement automatique si image non disponible
/// Affiche un emoji en fallback pour éviter les appels API dans les listes
class ExerciseImageThumbnail extends StatefulWidget {
  final String exerciseId;
  final String fallbackEmoji;
  final double size;
  final Color? backgroundColor;
  
  const ExerciseImageThumbnail({
    super.key,
    required this.exerciseId,
    this.fallbackEmoji = '💪',
    this.size = 56,
    this.backgroundColor,
  });

  @override
  State<ExerciseImageThumbnail> createState() => _ExerciseImageThumbnailState();
}

class _ExerciseImageThumbnailState extends State<ExerciseImageThumbnail> {
  ImageSource? _imageSource;
  bool _isLoading = true;
  bool _initialized = false;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      // Attendre que le frame soit complètement construit
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _checkImageAvailability();
        }
      });
    }
  }

  /// ListView.builder recycle les elements par position : quand l'exercice
  /// affiche a une position donnee change (nouvel exerciseId) sans que
  /// Flutter ne recree le State (pas de Key stable sur la liste), le State
  /// precedent reste en place avec son ancienne image tant qu'aucun
  /// didUpdateWidget ne detecte explicitement ce changement et ne relance
  /// la verification.
  @override
  void didUpdateWidget(covariant ExerciseImageThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exerciseId != widget.exerciseId) {
      setState(() {
        _imageSource = null;
        _isLoading = true;
      });
      // Relancer la meme verification que celle declenchee depuis
      // didChangeDependencies, avec les memes garde-fous (mounted +
      // addPostFrameCallback pour eviter un setState pendant le build).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _checkImageAvailability();
        }
      });
    }
  }

  /// Vérifie si une image est disponible (asset ou local uniquement)
  /// Ne télécharge PAS si l'image n'existe pas
  /// Gère aussi le cas hasImage=false (getImageSource retourne null)
  Future<void> _checkImageAvailability() async {
    final repository = context.read<ExerciseLibraryRepository>();
    final source = await repository.getImageSource(widget.exerciseId);

    if (mounted) {
      setState(() {
        // On garde l'image seulement si elle est asset ou local
        // Si remote ou null, on affichera l'emoji
        _imageSource = (source != null && (source.isAsset || source.isLocal))
            ? source
            : null;
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // Neumorphism - Ombre claire en haut à gauche
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.9),
            blurRadius: 8,
            offset: const Offset(-4, -4),
          ),
          // Neumorphism - Ombre sombre en bas à droite
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.6)
                : colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: _buildContent(),
    );
  }
  
  Widget _buildContent() {
    if (_isLoading) {
      return _buildEmojiContent();
    }
    
    if (_imageSource == null) {
      // Pas d'image disponible → afficher emoji
      return _buildEmojiContent();
    }
    
    // Image disponible → afficher
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _imageSource!.isAsset
            ? _buildAssetImage(_imageSource!.path)
            : _buildLocalImage(_imageSource!.path),
      ),
    );
  }
  
  Widget _buildEmojiContent() {
    return Center(
      child: Text(
        widget.fallbackEmoji,
        style: const TextStyle(fontSize: 28),
      ),
    );
  }
  
  Widget _buildAssetImage(String assetPath) {
    return SvgPicture.asset(
      assetPath,
      width: widget.size - 16,
      height: widget.size - 16,
      fit: BoxFit.contain,
    );
  }
  
  Widget _buildLocalImage(String localPath) {
    return SvgPicture.file(
      File(localPath),
      width: widget.size - 16,
      height: widget.size - 16,
      fit: BoxFit.contain,
    );
  }
}
