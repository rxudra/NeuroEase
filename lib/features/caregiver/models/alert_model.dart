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
  });

  final String id;
  String title;
  AlertType type;
  String details;
  DateTime? time;
  int severity; // 1-5
}
