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
}
