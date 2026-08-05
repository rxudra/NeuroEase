class NotificationItem {
  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.category,
    this.read = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime date;
  final String category;
  bool read;
}
