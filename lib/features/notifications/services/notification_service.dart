import 'dart:async';

import '../models/notification_item.dart';

class NotificationService {
  NotificationService._internal() {
    _initMockData();
  }

  static final NotificationService instance = NotificationService._internal();

  final List<NotificationItem> _items = [];

  void _initMockData() {
    _items.addAll([
      NotificationItem(
        id: 'n1',
        title: 'Doctor appointment reminder',
        body: 'Your appointment with Dr. Mehta is tomorrow at 10:00 AM.',
        date: DateTime.now().subtract(const Duration(hours: 4)),
        category: 'Reminders',
      ),
      NotificationItem(
        id: 'n2',
        title: 'Medication due',
        body: 'Time to take your morning medication: Amlodipine.',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        category: 'Medication',
      ),
      NotificationItem(
        id: 'n3',
        title: 'New message from Caregiver',
        body: 'Can you confirm your vitals for today?',
        date: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Messages',
      ),
      NotificationItem(
        id: 'n4',
        title: 'App update available',
        body: 'Version 1.1.0 is available with minor fixes.',
        date: DateTime.now().subtract(const Duration(days: 3)),
        category: 'System',
        read: true,
      ),
    ]);
  }

  Future<List<NotificationItem>> fetch({
    String? category,
    bool unreadOnly = false,
    String? query,
  }) async {
    // Simulate latency
    await Future.delayed(const Duration(milliseconds: 200));
    Iterable<NotificationItem> results = _items;
    if (category != null && category != 'All') {
      results = results.where((n) => n.category == category);
    }
    if (unreadOnly) {
      results = results.where((n) => n.read == false);
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where(
        (n) =>
            n.title.toLowerCase().contains(q) ||
            n.body.toLowerCase().contains(q),
      );
    }
    final sorted = results.toList()..sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  Future<void> markRead(String id) async {
    final item = _items.firstWhere(
      (e) => e.id == id,
      orElse: () => throw StateError('Not found'),
    );
    item.read = true;
    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<void> markUnread(String id) async {
    final item = _items.firstWhere(
      (e) => e.id == id,
      orElse: () => throw StateError('Not found'),
    );
    item.read = false;
    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<void> markAllRead() async {
    for (final n in _items) {
      n.read = true;
    }
    await Future.delayed(const Duration(milliseconds: 100));
  }

  List<String> categories() {
    final set = <String>{'All'};
    for (final n in _items) {
      set.add(n.category);
    }
    return set.toList();
  }
}
