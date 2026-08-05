class PatientStatusModel {
  PatientStatusModel({
    required this.patientId,
    required this.name,
    this.avatarUrl = '',
    this.lastActive,
    this.location = 'Home',
    this.online = true,
  });

  final String patientId;
  String name;
  String avatarUrl;
  DateTime? lastActive;
  String location;
  bool online;
}
