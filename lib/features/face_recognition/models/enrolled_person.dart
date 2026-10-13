/// Supported relationships for dementia-friendly person enrollment.
/// Gender is NEVER inferred from facial appearance; the user explicitly selects a relationship.
class PersonRelationship {
  static const String mom = 'Mom';
  static const String dad = 'Dad';
  static const String brother = 'Brother';
  static const String sister = 'Sister';
  static const String caregiver = 'Caregiver';
  static const String doctor = 'Doctor';
  static const String other = 'Other';

  static const List<String> all = [
    mom,
    dad,
    brother,
    sister,
    caregiver,
    doctor,
    other,
  ];
}

/// An enrolled family member or care team profile stored locally on device.
class EnrolledPerson {
  const EnrolledPerson({
    required this.id,
    required this.name,
    required this.relationship,
    required this.enrolledAt,
  });

  final String id;
  final String name;
  final String relationship;
  final DateTime enrolledAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'relationship': relationship,
        'enrolledAt': enrolledAt.toIso8601String(),
      };

  factory EnrolledPerson.fromJson(Map<String, dynamic> json) {
    return EnrolledPerson(
      id: json['id'] as String,
      name: json['name'] as String,
      relationship: json['relationship'] as String,
      enrolledAt: DateTime.parse(json['enrolledAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnrolledPerson &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          relationship == other.relationship;

  @override
  int get hashCode => Object.hash(id, name, relationship);
}
