class CaregiverModel {
  CaregiverModel({
    required this.id,
    required this.name,
    this.phone = '',
    this.role = 'Caregiver',
    this.avatarUrl = '',
  });

  final String id;
  String name;
  String phone;
  String role;
  String avatarUrl;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'role': role,
    'avatarUrl': avatarUrl,
  };

  static CaregiverModel fromMap(Map<String, dynamic> m, {String? documentId}) {
    return CaregiverModel(
      id: (documentId != null && documentId.isNotEmpty)
          ? documentId
          : (m['id'] as String? ?? ''),
      name: m['name'] as String? ?? '',
      phone: m['phone'] as String? ?? '',
      role: m['role'] as String? ?? 'Caregiver',
      avatarUrl: m['avatarUrl'] as String? ?? '',
    );
  }
}
