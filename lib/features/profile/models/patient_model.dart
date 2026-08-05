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

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'relationship': relationship,
    'phone': phone,
    'isPrimary': isPrimary,
  };

  static EmergencyContact fromMap(Map<String, dynamic> m) => EmergencyContact(
    id: m['id'] as String? ?? '',
    name: m['name'] as String? ?? '',
    relationship: m['relationship'] as String? ?? '',
    phone: m['phone'] as String? ?? '',
    isPrimary: m['isPrimary'] as bool? ?? false,
  );
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

  Map<String, dynamic> toMap() => {
    'id': id,
    'fullName': fullName,
    'nickname': nickname,
    'dob': dob.toIso8601String(),
    'gender': gender,
    'bloodGroup': bloodGroup,
    'heightCm': heightCm,
    'weightKg': weightKg,
    'phone': phone,
    'email': email,
    'address': address,
    'doctor': doctor,
    'hospital': hospital,
    'allergies': allergies,
    'conditions': conditions,
    'medications': medications,
    'emergencyContacts': emergencyContacts.map((e) => e.toMap()).toList(),
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'photoUrl': photoUrl,
  };

  static PatientModel fromMap(Map<String, dynamic> m) {
    return PatientModel(
      id: m['id'] as String? ?? '',
      fullName: m['fullName'] as String? ?? '',
      nickname: m['nickname'] as String? ?? '',
      dob: DateTime.tryParse(m['dob'] as String? ?? '') ?? DateTime.now(),
      gender: m['gender'] as String? ?? '',
      bloodGroup: m['bloodGroup'] as String? ?? '',
      heightCm: (m['heightCm'] as num?)?.toInt() ?? 0,
      weightKg: (m['weightKg'] as num?)?.toInt() ?? 0,
      phone: m['phone'] as String? ?? '',
      email: m['email'] as String? ?? '',
      address: m['address'] as String? ?? '',
      doctor: m['doctor'] as String? ?? '',
      hospital: m['hospital'] as String? ?? '',
      allergies: List<String>.from(m['allergies'] as List? ?? []),
      conditions: List<String>.from(m['conditions'] as List? ?? []),
      medications: List<String>.from(m['medications'] as List? ?? []),
      emergencyContacts: (m['emergencyContacts'] as List? ?? [])
          .map(
            (e) =>
                EmergencyContact.fromMap(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      notes: m['notes'] as String? ?? '',
      createdAt:
          DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
      photoUrl: m['photoUrl'] as String? ?? '',
    );
  }

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
