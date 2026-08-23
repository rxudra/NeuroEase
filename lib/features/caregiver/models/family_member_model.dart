class FamilyMemberModel {
  FamilyMemberModel({
    required this.id,
    required this.name,
    this.relationship = '',
    this.phone = '',
    this.role = '',
  });

  final String id;
  String name;
  String relationship;
  String phone;
  String role;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'relationship': relationship,
    'phone': phone,
    'role': role,
  };

  static FamilyMemberModel fromMap(
    Map<String, dynamic> m, {
    String? documentId,
  }) {
    return FamilyMemberModel(
      id: (documentId != null && documentId.isNotEmpty)
          ? documentId
          : (m['id'] as String? ?? ''),
      name: m['name'] as String? ?? '',
      relationship: m['relationship'] as String? ?? '',
      phone: m['phone'] as String? ?? '',
      role: m['role'] as String? ?? '',
    );
  }
}
