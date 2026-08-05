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
}
