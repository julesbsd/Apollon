import 'muscle_info.dart';
import 'type_info.dart';
import 'category_info.dart';

/// Modèle représentant un exercice du catalogue Workout API
/// Collection Firestore: 'exercises_library'
/// 
/// Cette classe contient la version enrichie des exercices avec:
/// - Description technique complète
/// - Classification détaillée (muscles primaires/secondaires, types, catégories)
/// - Support lazy loading des images
class ExerciseLibrary {
  final String id; // UUID from Workout API
  final String code; // Unique code (ex: 'BARBELL_BENCH_PRESS')
  final String name; // "Développé couché barre"
  final String description; // Description technique complète

  // Muscles
  final List<MuscleInfo> primaryMuscles;
  final List<MuscleInfo> secondaryMuscles;

  // Classification
  final List<TypeInfo> types;
  final List<CategoryInfo> categories;

  // Metadata
  final DateTime syncedAt; // Date import depuis API
  final String source; // "workout-api"
  final bool hasImage; // Image disponible?

  const ExerciseLibrary({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.types,
    required this.categories,
    required this.syncedAt,
    required this.source,
    this.hasImage = false,
  });

  /// Conversion depuis Firestore
  factory ExerciseLibrary.fromFirestore(Map<String, dynamic> data) {
    // Helper pour parser les muscles depuis différents formats
    List<MuscleInfo> parseMuscles(dynamic musclesData) {
      if (musclesData == null) return [];
      if (musclesData is List) {
        if (musclesData.isEmpty) return [];
        // Si c'est une liste de strings
        if (musclesData.first is String) {
          return musclesData
              .map((m) => MuscleInfo(
                    code: m.toString().toUpperCase().replaceAll(' ', '_'),
                    name: m.toString(),
                  ))
              .toList();
        }
        // Si c'est une liste de maps
        return musclesData
            .map((m) => MuscleInfo.fromFirestore(m as Map<String, dynamic>))
            .toList();
      }
      if (musclesData is String) {
        return [
          MuscleInfo(
            code: musclesData.toUpperCase().replaceAll(' ', '_'),
            name: musclesData,
          )
        ];
      }
      return [];
    }

    // Helper pour parser les catégories
    List<CategoryInfo> parseCategories(dynamic categoriesData) {
      if (categoriesData == null) return [];
      if (categoriesData is List) {
        if (categoriesData.isEmpty) return [];
        if (categoriesData.first is String) {
          return categoriesData
              .map((c) => CategoryInfo(
                    code: c.toString().toUpperCase().replaceAll(' ', '_'),
                    name: c.toString(),
                  ))
              .toList();
        }
        return categoriesData
            .map((c) => CategoryInfo.fromFirestore(c as Map<String, dynamic>))
            .toList();
      }
      if (categoriesData is String) {
        return [
          CategoryInfo(
            code: categoriesData.toUpperCase().replaceAll(' ', '_'),
            name: categoriesData,
          )
        ];
      }
      return [];
    }

    // Helper pour parser les types
    List<TypeInfo> parseTypes(dynamic typesData) {
      if (typesData == null) {
        return [TypeInfo(code: 'FREE_WEIGHT', name: 'Poids libres')];
      }
      if (typesData is List) {
        if (typesData.isEmpty) {
          return [TypeInfo(code: 'FREE_WEIGHT', name: 'Poids libres')];
        }
        // Si c'est une liste de strings
        if (typesData.first is String) {
          return typesData
              .map((t) => TypeInfo(
                    code: t.toString().toUpperCase().replaceAll(' ', '_'),
                    name: t.toString(),
                  ))
              .toList();
        }
        // Si c'est une liste de maps
        return typesData
            .map((t) => TypeInfo.fromFirestore(t as Map<String, dynamic>))
            .toList();
      }
      if (typesData is String) {
        return [
          TypeInfo(
            code: typesData.toUpperCase().replaceAll(' ', '_'),
            name: typesData,
          )
        ];
      }
      return [TypeInfo(code: 'FREE_WEIGHT', name: 'Poids libres')];
    }

    // Helper pour parser la date
    DateTime parseDate(dynamic dateData) {
      if (dateData == null) return DateTime.now();
      if (dateData is String) return DateTime.parse(dateData);
      if (dateData is DateTime) return dateData;
      // Firestore Timestamp
      try {
        return (dateData as dynamic).toDate() as DateTime;
      } catch (e) {
        return DateTime.now();
      }
    }

    return ExerciseLibrary(
      id: data['id'] as String? ?? '',
      code: data['code'] as String? ?? data['id'] as String? ?? '',
      name: data['name'] as String? ?? 'Sans nom',
      description: data['description'] as String? ?? '',
      primaryMuscles: parseMuscles(data['primaryMuscles']),
      secondaryMuscles: parseMuscles(data['secondaryMuscles']),
      types: parseTypes(data['types']),
      categories: parseCategories(data['categories']),
      syncedAt: parseDate(data['syncedAt'] ?? data['createdAt']),
      source: data['source'] as String? ?? 'workout-api',
      hasImage: data['hasImage'] as bool? ?? false,
    );
  }

  /// Conversion vers Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'primaryMuscles': primaryMuscles.map((m) => m.toFirestore()).toList(),
      'secondaryMuscles':
          secondaryMuscles.map((m) => m.toFirestore()).toList(),
      'types': types.map((t) => t.toFirestore()).toList(),
      'categories': categories.map((c) => c.toFirestore()).toList(),
      'syncedAt': syncedAt.toIso8601String(),
      'source': source,
      'hasImage': hasImage,
    };
  }

  /// Conversion depuis JSON Workout API
  factory ExerciseLibrary.fromWorkoutApi(Map<String, dynamic> json) {
    return ExerciseLibrary(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      primaryMuscles: (json['primaryMuscles'] as List)
          .map((m) => MuscleInfo.fromWorkoutApi(m as Map<String, dynamic>))
          .toList(),
      secondaryMuscles: (json['secondaryMuscles'] as List?)
              ?.map((m) => MuscleInfo.fromWorkoutApi(m as Map<String, dynamic>))
              .toList() ??
          [],
      types: (json['types'] as List)
          .map((t) => TypeInfo.fromWorkoutApi(t as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List)
          .map((c) => CategoryInfo.fromWorkoutApi(c as Map<String, dynamic>))
          .toList(),
      syncedAt: DateTime.now(),
      source: 'workout-api',
      hasImage: false,
    );
  }

  /// Créer une copie avec modification
  ExerciseLibrary copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    List<MuscleInfo>? primaryMuscles,
    List<MuscleInfo>? secondaryMuscles,
    List<TypeInfo>? types,
    List<CategoryInfo>? categories,
    DateTime? syncedAt,
    String? source,
    bool? hasImage,
  }) {
    return ExerciseLibrary(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      primaryMuscles: primaryMuscles ?? this.primaryMuscles,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      types: types ?? this.types,
      categories: categories ?? this.categories,
      syncedAt: syncedAt ?? this.syncedAt,
      source: source ?? this.source,
      hasImage: hasImage ?? this.hasImage,
    );
  }

  /// Obtenir les muscles primaires sous forme de texte
  String get primaryMusclesText =>
      primaryMuscles.map((m) => m.name).join(', ');

  /// Obtenir les muscles secondaires sous forme de texte
  String get secondaryMusclesText =>
      secondaryMuscles.map((m) => m.name).join(', ');

  /// Obtenir les catégories sous forme de texte
  String get categoriesText => categories.map((c) => c.name).join(', ');

  @override
  String toString() {
    return 'ExerciseLibrary(id: $id, code: $code, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExerciseLibrary && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
