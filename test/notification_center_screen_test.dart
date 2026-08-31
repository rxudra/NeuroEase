import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/notifications/screens/notification_center_screen.dart';
import 'package:app/features/notifications/services/notification_service.dart';
import 'package:app/features/notifications/models/notification_item.dart';

void main() {
  group('NotificationCenterScreen Widget Tests', () {
    testWidgets('renders empty state when no notifications exist', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: NotificationCenterScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('No notifications'), findsOneWidget);
    });

    testWidgets(
      'renders notification items when added to NotificationService',
      (tester) async {
        await NotificationService.instance.addNotification(
          NotificationItem(
            id: 't1',
            title: 'Amlodipine Time',
            body: 'Take 1 pill',
            date: DateTime.now(),
            category: 'Medication',
          ),
        );

        await tester.pumpWidget(
          const MaterialApp(home: NotificationCenterScreen()),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Amlodipine Time'), findsOneWidget);
        expect(find.text('Take 1 pill'), findsOneWidget);

        // Clean up
        await NotificationService.instance.delete('t1');
      },
    );
  });
}
