class ReminderModel {
  ReminderModel({
    required this.id,
    required this.title,
    this.note = '',
    required this.at,
  });

  final String id;
  final String title;
  final String note;
  final DateTime at;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'note': note,
    'at': at.toIso8601String(),
  };
  static ReminderModel fromMap(Map<String, dynamic> m) => ReminderModel(
    id: m['id'] ?? '',
    title: m['title'] ?? '',
    note: m['note'] ?? '',
    at: DateTime.tryParse(m['at'] ?? '') ?? DateTime.now(),
  );
}
