import '../../notifications/models/notification_item.dart';

abstract class NotificationRepository {
  Stream<List<NotificationItem>> streamForUser(String uid);
  Future<List<NotificationItem>> getAll(String uid);
  Future<void> add(String uid, NotificationItem notification);
  Future<void> update(String uid, NotificationItem notification);
  Future<void> markRead(String uid, String notificationId);
  Future<void> markUnread(String uid, String notificationId);
  Future<void> markAllRead(String uid);
  Future<void> dismiss(String uid, String notificationId);
  Future<void> delete(String uid, String notificationId);
}
