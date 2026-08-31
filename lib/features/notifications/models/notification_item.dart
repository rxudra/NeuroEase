class NotificationItem {
  NotificationItem({
    required this.id,
    this.userId = '',
    required this.title,
    required this.body,
    required this.date,
    required this.category,
    this.read = false,
    this.isDismissed = false,
    this.metadata,
  });

  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime date;
  final String category;
  bool read;
  bool isDismissed;
  final Map<String, dynamic>? metadata;

  bool get isRead => read;
  set isRead(bool value) => read = value;

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'title': title,
    'body': body,
    'date': date.toIso8601String(),
    'category': category,
    'read': read,
    'isRead': read,
    'isDismissed': isDismissed,
    if (metadata != null) 'metadata': metadata,
  };

  static NotificationItem fromMap(
    Map<String, dynamic> m, {
    String? documentId,
  }) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      try {
        final dynamic t = val;
        return t.toDate() as DateTime;
      } catch (_) {
        return DateTime.now();
      }
    }

    final resolvedRead =
        (m['isRead'] as bool?) ?? (m['read'] as bool?) ?? false;

    return NotificationItem(
      id: (documentId != null && documentId.isNotEmpty)
          ? documentId
          : (m['id'] as String? ?? ''),
      userId: m['userId'] as String? ?? '',
      title: m['title'] as String? ?? '',
      body: m['body'] as String? ?? m['details'] as String? ?? '',
      date: parseDate(
        m['date'] ?? m['createdAt'] ?? m['timestamp'] ?? m['time'],
      ),
      category: m['category'] as String? ?? m['type'] as String? ?? 'System',
      read: resolvedRead,
      isDismissed: m['isDismissed'] as bool? ?? false,
      metadata: m['metadata'] is Map<String, dynamic>
          ? m['metadata'] as Map<String, dynamic>
          : null,
    );
  }
}
