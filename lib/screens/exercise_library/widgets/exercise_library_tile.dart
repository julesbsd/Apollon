import 'package:flutter/material.dart';
import '../../../core/models/exercise_library.dart';
import 'exercise_image_widget.dart';

/// Widget Tile pour afficher un exercice du catalogue
/// 
/// Features:
/// - Image avec stratégie hybride (top 20 assets, autres lazy loading)
/// - Nom et description courte
/// - Muscles primaires
/// - Container neumorphique pour l'image
class ExerciseLibraryTile extends StatelessWidget {
  final ExerciseLibrary exercise;
  final VoidCallback? onTap;

  const ExerciseLibraryTile({
    super.key,
    required this.exercise,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image avec stratégie hybride (top 20 assets, autres API)
              ExerciseImageContainer(
                exerciseId: exercise.id,
                size: 80,
              ),
              const SizedBox(width: 12),

              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom de l'exercice
                    Text(
                      exercise.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Muscles primaires
                    Text(
                      exercise.primaryMusclesText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Catégories (équipement)
                    Text(
                      exercise.categoriesText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Icône chevron
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
