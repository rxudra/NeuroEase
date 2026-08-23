class EmergencyContactModel {
  EmergencyContactModel({
    required this.id,
    required this.name,
    this.relationship = '',
    this.phone = '',
    this.priority = 1,
    this.avatarUrl = '',
  });

  final String id;
  String name;
  String relationship;
  String phone;
  int priority;
  String avatarUrl;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'relationship': relationship,
    'phone': phone,
    'priority': priority,
    'avatarUrl': avatarUrl,
  };

  static EmergencyContactModel fromMap(Map<String, dynamic> m) {
    return EmergencyContactModel(
      id: m['id'] as String? ?? '',
      name: m['name'] as String? ?? '',
      relationship: m['relationship'] as String? ?? '',
      phone: m['phone'] as String? ?? '',
      priority: (m['priority'] as num?)?.toInt() ?? 1,
      avatarUrl: m['avatarUrl'] as String? ?? '',
    );
  }
}
