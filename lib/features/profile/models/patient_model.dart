class EmergencyContact {
  EmergencyContact({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phone,
    this.isPrimary = false,
  });

  final String id;
  final String name;
  final String relationship;
  final String phone;
  final bool isPrimary;
}

class PatientModel {
  PatientModel({
    required this.id,
    required this.fullName,
    this.nickname = '',
    required this.dob,
    this.gender = '',
    this.bloodGroup = '',
    this.heightCm = 0,
    this.weightKg = 0,
    this.phone = '',
    this.email = '',
    this.address = '',
    this.doctor = '',
    this.hospital = '',
    List<String>? allergies,
    List<String>? conditions,
    List<String>? medications,
    List<EmergencyContact>? emergencyContacts,
    this.notes = '',
    DateTime? createdAt,
    this.photoUrl = '',
  }) : allergies = allergies ?? <String>[],
       conditions = conditions ?? <String>[],
       medications = medications ?? <String>[],
       emergencyContacts = emergencyContacts ?? <EmergencyContact>[],
       createdAt = createdAt ?? DateTime.now();

  final String id;
  final String fullName;
  final String nickname;
  final DateTime dob;
  final String gender;
  final String bloodGroup;
  final int heightCm;
  final int weightKg;
  final String phone;
  final String email;
  final String address;
  final String doctor;
  final String hospital;
  final List<String> allergies;
  final List<String> conditions;
  final List<String> medications;
  final List<EmergencyContact> emergencyContacts;
  final String notes;
  final DateTime createdAt;
  final String photoUrl;

  int get age {
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }
}
