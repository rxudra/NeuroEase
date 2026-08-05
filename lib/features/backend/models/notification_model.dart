class NotificationModel {
  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.at,
    this.read = false,
    this.category = 'General',
  });

  final String id;
  final String title;
  final String body;
  final DateTime at;
  final bool read;
  final String category;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'body': body,
    'at': at.toIso8601String(),
    'read': read,
    'category': category,
  };
  static NotificationModel fromMap(Map<String, dynamic> m) => NotificationModel(
    id: m['id'] ?? '',
    title: m['title'] ?? '',
    body: m['body'] ?? '',
    at: DateTime.tryParse(m['at'] ?? '') ?? DateTime.now(),
    read: m['read'] as bool? ?? false,
    category: m['category'] ?? 'General',
  );
}
