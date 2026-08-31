import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/notifications/screens/caregiver_notifications_screen.dart';
import 'package:app/features/notifications/services/notification_service.dart';
import 'package:app/features/notifications/models/notification_item.dart';

void main() {
  group('CaregiverNotificationsScreen Widget Tests', () {
    testWidgets('renders empty state when caregiver has no notifications', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: CaregiverNotificationsScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('No notifications'), findsOneWidget);
    });

    testWidgets('renders caregiver notification with patient metadata', (
      tester,
    ) async {
      final notif = NotificationItem(
        id: 'cg1',
        title: 'Medication Missed',
        body: 'Amlodipine missed at 8:00 AM',
        date: DateTime.now(),
        category: 'Medication',
        metadata: {'patientName': 'Rudra Kumar'},
      );

      await NotificationService.instance.addNotification(notif);

      await tester.pumpWidget(
        const MaterialApp(home: CaregiverNotificationsScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Medication Missed'), findsOneWidget);
      expect(find.text('Amlodipine missed at 8:00 AM'), findsOneWidget);
      expect(find.text('Rudra Kumar'), findsOneWidget);

      // Clean up
      await NotificationService.instance.delete('cg1');
    });

    testWidgets('filters notifications via search input', (tester) async {
      final notif1 = NotificationItem(
        id: 'cg2',
        title: 'Daily Vitals Alert',
        body: 'Vitals updated for Asha Devi',
        date: DateTime.now(),
        category: 'System',
        metadata: {'patientName': 'Asha Devi'},
      );
      final notif2 = NotificationItem(
        id: 'cg3',
        title: 'Check In',
        body: 'Patient completed evening checkin',
        date: DateTime.now(),
        category: 'Reminders',
      );

      await NotificationService.instance.addNotification(notif1);
      await NotificationService.instance.addNotification(notif2);

      await tester.pumpWidget(
        const MaterialApp(home: CaregiverNotificationsScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Daily Vitals Alert'), findsOneWidget);
      expect(find.text('Check In'), findsOneWidget);

      // Enter search term
      await tester.enterText(find.byType(TextField), 'Vitals');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Daily Vitals Alert'), findsOneWidget);
      expect(find.text('Check In'), findsNothing);

      // Clean up
      await NotificationService.instance.delete('cg2');
      await NotificationService.instance.delete('cg3');
    });
  });
}
