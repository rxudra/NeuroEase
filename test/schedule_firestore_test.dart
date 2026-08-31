import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/schedule/screens/schedule_home_screen.dart';
import 'package:app/features/schedule/services/schedule_service.dart';
import 'package:app/features/schedule/models/schedule_task.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Schedule & Firestore Persistence Widget Tests', () {
    testWidgets('renders ScheduleHomeScreen with tasks and progress bar', (
      WidgetTester tester,
    ) async {
      ScheduleService.instance.initMock();

      await tester.pumpWidget(const MaterialApp(home: ScheduleHomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Schedule & Reminders'), findsOneWidget);
      expect(find.text('Daily Schedule Overview'), findsOneWidget);
      expect(find.text("Today's Schedule"), findsOneWidget);
      expect(find.text('Upcoming Reminders'), findsOneWidget);
    });

    testWidgets('allows adding a new task via ScheduleService', (
      WidgetTester tester,
    ) async {
      ScheduleService.instance.initMock();

      final now = DateTime.now();
      final newTask = ScheduleTask(
        id: 'test_task_100',
        title: 'Hydration Break',
        description: 'Drink 250ml water',
        category: 'Hydration',
        date: DateTime(now.year, now.month, now.day),
        time: TimeOfDay.now(),
        colorValue: Colors.blue.toARGB32(),
      );

      await ScheduleService.instance.addTask(newTask);

      await tester.pumpWidget(const MaterialApp(home: ScheduleHomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Hydration Break'), findsWidgets);
    });
  });
}
