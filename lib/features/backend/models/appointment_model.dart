class AppointmentModel {
  AppointmentModel({
    required this.id,
    required this.title,
    required this.at,
    this.location = '',
  });

  final String id;
  final String title;
  final DateTime at;
  final String location;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'at': at.toIso8601String(),
    'location': location,
  };
  static AppointmentModel fromMap(Map<String, dynamic> m) => AppointmentModel(
    id: m['id'] ?? '',
    title: m['title'] ?? '',
    at: DateTime.tryParse(m['at'] ?? '') ?? DateTime.now(),
    location: m['location'] ?? '',
  );
}
