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
}
