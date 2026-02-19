/// Informations sur la catégorie d'équipement
/// Source: Workout API
/// Exemples: Poids libres, Machine, Poids corporel
class CategoryInfo {
  final String id;
  final String code; // 'FREE_WEIGHT', 'MACHINE', 'BODYWEIGHT'
  final String name; // 'Poids libres', 'Machine', 'Poids corporel'

  CategoryInfo({
    String? id,
    required this.code,
    required this.name,
  }) : id = id ?? code;

  /// Conversion depuis Firestore
  factory CategoryInfo.fromFirestore(Map<String, dynamic> data) {
    return CategoryInfo(
      id: data['id'] as String?,
      code: data['code'] as String? ?? '',
      name: data['name'] as String? ?? '',
    );
  }

  /// Conversion vers Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'code': code,
      'name': name,
    };
  }

  /// Conversion depuis JSON Workout API
  factory CategoryInfo.fromWorkoutApi(Map<String, dynamic> json) {
    return CategoryInfo(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }

  @override
  String toString() => 'CategoryInfo(id: $id, code: $code, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryInfo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
