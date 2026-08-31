import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/notifications/models/notification_item.dart';
import 'package:app/features/notifications/services/notification_service.dart';
import 'package:app/features/backend/repositories/notification_repository.dart';

class FakeNotificationRepository implements NotificationRepository {
  final List<NotificationItem> stored = [];
  final StreamController<List<NotificationItem>> _controller =
      StreamController<List<NotificationItem>>.broadcast();

  @override
  Stream<List<NotificationItem>> streamForUser(String uid) =>
      _controller.stream;

  @override
  Future<List<NotificationItem>> getAll(String uid) async => List.from(stored);

  @override
  Future<void> add(String uid, NotificationItem notification) async {
    stored.insert(0, notification);
    _controller.add(List.from(stored));
  }

  @override
  Future<void> update(String uid, NotificationItem notification) async {
    final idx = stored.indexWhere((n) => n.id == notification.id);
    if (idx >= 0) stored[idx] = notification;
    _controller.add(List.from(stored));
  }

  @override
  Future<void> markRead(String uid, String notificationId) async {
    final idx = stored.indexWhere((n) => n.id == notificationId);
    if (idx >= 0) stored[idx].isRead = true;
    _controller.add(List.from(stored));
  }

  @override
  Future<void> markUnread(String uid, String notificationId) async {
    final idx = stored.indexWhere((n) => n.id == notificationId);
    if (idx >= 0) stored[idx].isRead = false;
    _controller.add(List.from(stored));
  }

  @override
  Future<void> markAllRead(String uid) async {
    for (final n in stored) {
      n.isRead = true;
    }
    _controller.add(List.from(stored));
  }

  @override
  Future<void> dismiss(String uid, String notificationId) async {
    final idx = stored.indexWhere((n) => n.id == notificationId);
    if (idx >= 0) stored[idx].isDismissed = true;
    _controller.add(List.from(stored));
  }

  @override
  Future<void> delete(String uid, String notificationId) async {
    stored.removeWhere((n) => n.id == notificationId);
    _controller.add(List.from(stored));
  }
}

void main() {
  group('NotificationService unit tests', () {
    late FakeNotificationRepository repo;
    late NotificationService service;

    setUp(() {
      repo = FakeNotificationRepository();
      service = NotificationService.custom(repository: repo);
    });

    test(
      'addNotification adds to items and calculates unreadCount correctly',
      () async {
        expect(service.items.length, 0);
        expect(service.unreadCount, 0);

        final notif = NotificationItem(
          id: '1',
          title: 'Title 1',
          body: 'Body 1',
          date: DateTime.now(),
          category: 'Medication',
          read: false,
        );

        await service.addNotification(notif);
        expect(service.items.length, 1);
        expect(service.unreadCount, 1);
      },
    );

    test('markRead and markAllRead updates isRead state', () async {
      final notif1 = NotificationItem(
        id: '1',
        title: 'Title 1',
        body: 'Body 1',
        date: DateTime.now(),
        category: 'Medication',
        read: false,
      );
      final notif2 = NotificationItem(
        id: '2',
        title: 'Title 2',
        body: 'Body 2',
        date: DateTime.now(),
        category: 'Reminders',
        read: false,
      );

      await service.addNotification(notif1);
      await service.addNotification(notif2);
      expect(service.unreadCount, 2);

      await service.markRead('1');
      expect(service.unreadCount, 1);

      await service.markAllRead();
      expect(service.unreadCount, 0);
    });

    test('dismiss hides item from items list and unreadCount', () async {
      final notif = NotificationItem(
        id: '1',
        title: 'Title 1',
        body: 'Body 1',
        date: DateTime.now(),
        category: 'Medication',
        read: false,
      );

      await service.addNotification(notif);
      expect(service.items.length, 1);

      await service.dismiss('1');
      expect(service.items.length, 0);
      expect(service.unreadCount, 0);
    });

    test('fetch applies category and query filtering', () async {
      final notif1 = NotificationItem(
        id: '1',
        title: 'Amlodipine due',
        body: 'Take 5mg',
        date: DateTime.now().subtract(const Duration(minutes: 10)),
        category: 'Medication',
      );
      final notif2 = NotificationItem(
        id: '2',
        title: 'Doctor Appt',
        body: 'Dr Mehta',
        date: DateTime.now(),
        category: 'Reminders',
      );

      await service.addNotification(notif1);
      await service.addNotification(notif2);

      final medItems = await service.fetch(category: 'Medication');
      expect(medItems.length, 1);
      expect(medItems.first.id, '1');

      final searchItems = await service.fetch(query: 'Mehta');
      expect(searchItems.length, 1);
      expect(searchItems.first.id, '2');
    });
  });
}
