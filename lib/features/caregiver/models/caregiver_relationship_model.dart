class CaregiverRelationshipModel {
  CaregiverRelationshipModel({
    required this.id,
    required this.caregiverId,
    required this.patientId,
    this.relationship = 'Primary Caregiver',
    this.createdAt,
  });

  final String id;
  final String caregiverId;
  final String patientId;
  final String relationship;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'caregiverId': caregiverId,
    'patientId': patientId,
    'relationship': relationship,
    'createdAt': createdAt?.toIso8601String(),
  };

  static CaregiverRelationshipModel fromMap(
    Map<String, dynamic> m, {
    String? documentId,
  }) {
    DateTime? parseTime(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      try {
        final dynamic t = val;
        return t.toDate() as DateTime;
      } catch (_) {
        return null;
      }
    }

    return CaregiverRelationshipModel(
      id: (documentId != null && documentId.isNotEmpty)
          ? documentId
          : (m['id'] as String? ?? ''),
      caregiverId: m['caregiverId'] as String? ?? '',
      patientId: m['patientId'] as String? ?? '',
      relationship: m['relationship'] as String? ?? 'Primary Caregiver',
      createdAt: parseTime(m['createdAt']),
    );
  }
}
