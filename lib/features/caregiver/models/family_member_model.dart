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
}
