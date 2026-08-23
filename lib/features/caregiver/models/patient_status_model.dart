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

  Map<String, dynamic> toMap() => {
    'patientId': patientId,
    'name': name,
    'avatarUrl': avatarUrl,
    'lastActive': lastActive?.toIso8601String(),
    'location': location,
    'online': online,
  };

  static PatientStatusModel fromMap(
    Map<String, dynamic> m, {
    String? documentId,
  }) {
    DateTime? parseTime(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      try {
        final dynamic t = val;
        return t.toDate() as DateTime;
      } catch (_) {
        return null;
      }
    }

    return PatientStatusModel(
      patientId: (documentId != null && documentId.isNotEmpty)
          ? documentId
          : (m['patientId'] as String? ?? m['id'] as String? ?? ''),
      name: m['name'] as String? ?? '',
      avatarUrl: m['avatarUrl'] as String? ?? '',
      lastActive: parseTime(m['lastActive']),
      location: m['location'] as String? ?? 'Home',
      online: m['online'] as bool? ?? true,
    );
  }
}
