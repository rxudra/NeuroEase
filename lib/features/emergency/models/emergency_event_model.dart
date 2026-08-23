enum EmergencyEventType {
  fall,
  sosTriggered,
  sosCancelled,
  locationShared,
  contactNotified,
}

class EmergencyEventModel {
  EmergencyEventModel({
    required this.id,
    required this.type,
    required this.title,
    this.details = '',
    this.time,
  });

  final String id;
  EmergencyEventType type;
  String title;
  String details;
  DateTime? time;

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.name,
    'title': title,
    'details': details,
    'time': time?.toIso8601String(),
  };

  static EmergencyEventModel fromMap(Map<String, dynamic> m) {
    EmergencyEventType parseType(String? name) {
      if (name == null) return EmergencyEventType.sosTriggered;
      try {
        return EmergencyEventType.values.firstWhere(
          (e) => e.name == name || e.toString() == name,
        );
      } catch (_) {
        return EmergencyEventType.sosTriggered;
      }
    }

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

    return EmergencyEventModel(
      id: m['id'] as String? ?? '',
      type: parseType(m['type'] as String?),
      title: m['title'] as String? ?? '',
      details: m['details'] as String? ?? '',
      time: parseTime(m['time']),
    );
  }
}
