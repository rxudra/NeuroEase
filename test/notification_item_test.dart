import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/notifications/models/notification_item.dart';

void main() {
  group('NotificationItem tests', () {
    test('serialization toMap and fromMap works correctly', () {
      final now = DateTime.now();
      final item = NotificationItem(
        id: 'n100',
        userId: 'u123',
        title: 'Medication Alert',
        body: 'Time to take aspirin',
        date: now,
        category: 'Medication',
        read: false,
        isDismissed: false,
        metadata: {'dose': '500mg'},
      );

      final map = item.toMap();
      expect(map['id'], 'n100');
      expect(map['userId'], 'u123');
      expect(map['title'], 'Medication Alert');
      expect(map['body'], 'Time to take aspirin');
      expect(map['category'], 'Medication');
      expect(map['read'], false);
      expect(map['isRead'], false);
      expect(map['isDismissed'], false);
      expect(map['metadata'], {'dose': '500mg'});

      final reconstructed = NotificationItem.fromMap(map, documentId: 'n100');
      expect(reconstructed.id, 'n100');
      expect(reconstructed.userId, 'u123');
      expect(reconstructed.title, 'Medication Alert');
      expect(reconstructed.body, 'Time to take aspirin');
      expect(reconstructed.category, 'Medication');
      expect(reconstructed.read, false);
      expect(reconstructed.isRead, false);
      expect(reconstructed.isDismissed, false);
      expect(reconstructed.metadata, {'dose': '500mg'});
    });

    test('fromMap backward compatibility defaults for legacy documents', () {
      final legacyMap = <String, dynamic>{
        'title': 'Doctor Appointment',
        'details': 'Tomorrow at 9 AM',
        'createdAt': '2026-08-27T10:00:00.000Z',
        'type': 'Reminders',
      };

      final item = NotificationItem.fromMap(legacyMap, documentId: 'legacy_1');
      expect(item.id, 'legacy_1');
      expect(item.userId, '');
      expect(item.title, 'Doctor Appointment');
      expect(item.body, 'Tomorrow at 9 AM');
      expect(item.category, 'Reminders');
      expect(item.read, false);
      expect(item.isRead, false);
      expect(item.isDismissed, false);
      expect(item.metadata, null);
    });

    test('isRead setter modifies read property', () {
      final item = NotificationItem(
        id: 'n1',
        title: 'Title',
        body: 'Body',
        date: DateTime.now(),
        category: 'System',
      );
      expect(item.read, false);
      item.isRead = true;
      expect(item.read, true);
      expect(item.isRead, true);
    });
  });
}
