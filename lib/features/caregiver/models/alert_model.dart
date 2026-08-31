enum AlertType {
  missedMedication,
  missedReminder,
  lowActivity,
  fall,
  batteryLow,
  offline,
}

class AlertModel {
  AlertModel({
    required this.id,
    required this.title,
    this.type = AlertType.missedMedication,
    this.details = '',
    this.time,
    this.severity = 1,
    this.isRead = false,
    this.isDismissed = false,
    this.patientId = '',
  });

  final String id;
  String title;
  AlertType type;
  String details;
  DateTime? time;
  int severity; // 1-5
  bool isRead;
  bool isDismissed;
  String patientId;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'type': type.name,
    'details': details,
    'time': time?.toIso8601String(),
    'timestamp': time?.toIso8601String(),
    'severity': severity,
    'isRead': isRead,
    'isDismissed': isDismissed,
    'patientId': patientId,
  };

  static AlertModel fromMap(Map<String, dynamic> m, {String? documentId}) {
    AlertType parseType(String? name) {
      if (name == null) return AlertType.missedMedication;
      try {
        return AlertType.values.firstWhere(
          (e) => e.name == name || e.toString() == name,
        );
      } catch (_) {
        return AlertType.missedMedication;
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

    return AlertModel(
      id: (documentId != null && documentId.isNotEmpty)
          ? documentId
          : (m['id'] as String? ?? ''),
      title: m['title'] as String? ?? '',
      type: parseType(m['type'] as String?),
      details: m['details'] as String? ?? '',
      time: parseTime(m['time'] ?? m['createdAt'] ?? m['timestamp']),
      severity: (m['severity'] as num?)?.toInt() ?? 1,
      isRead: m['isRead'] as bool? ?? false,
      isDismissed: m['isDismissed'] as bool? ?? false,
      patientId: m['patientId'] as String? ?? '',
    );
  }
}
