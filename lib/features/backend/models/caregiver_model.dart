class CaregiverModel {
  CaregiverModel({
    required this.id,
    required this.name,
    this.phone = '',
    this.email = '',
  });

  final String id;
  final String name;
  final String phone;
  final String email;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
  };
  static CaregiverModel fromMap(Map<String, dynamic> m) => CaregiverModel(
    id: m['id'] ?? '',
    name: m['name'] ?? '',
    phone: m['phone'] ?? '',
    email: m['email'] ?? '',
  );
}
