/// Informations sur le type d'exercice
/// Source: Workout API
/// Exemples: Isolation, Polyarticulaire (Compound)
class TypeInfo {
  final String id;
  final String code; // 'ISOLATION', 'COMPOUND'
  final String name; // 'Isolation', 'Polyarticulaire'

  TypeInfo({
    String? id,
    required this.code,
    required this.name,
  }) : id = id ?? code;

  /// Conversion depuis Firestore
  factory TypeInfo.fromFirestore(Map<String, dynamic> data) {
    return TypeInfo(
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
  factory TypeInfo.fromWorkoutApi(Map<String, dynamic> json) {
    return TypeInfo(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }

  @override
  String toString() => 'TypeInfo(id: $id, code: $code, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TypeInfo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
