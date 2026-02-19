/// Informations sur un muscle cible
/// Source: Workout API
class MuscleInfo {
  final String id;
  final String code; // 'CHEST', 'BICEPS', etc.
  final String name; // 'Pectoraux', 'Biceps', etc.

  MuscleInfo({
    String? id,
    required this.code,
    required this.name,
  }) : id = id ?? code;

  /// Conversion depuis Firestore
  factory MuscleInfo.fromFirestore(Map<String, dynamic> data) {
    return MuscleInfo(
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
  factory MuscleInfo.fromWorkoutApi(Map<String, dynamic> json) {
    return MuscleInfo(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }

  @override
  String toString() => 'MuscleInfo(id: $id, code: $code, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MuscleInfo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
