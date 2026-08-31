import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/caregiver/screens/caregiver_home_screen.dart';
import 'package:app/features/caregiver/services/caregiver_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CaregiverHomeScreen Widget Tests', () {
    testWidgets(
      'renders CaregiverHomeScreen with sections, statistics, and quick action chips',
      (WidgetTester tester) async {
        CaregiverService.instance.initMock();

        await tester.pumpWidget(const MaterialApp(home: CaregiverHomeScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Caregiver Dashboard'), findsOneWidget);
        expect(find.text('Workspace Statistics'), findsOneWidget);
        expect(find.text('Linked Patients'), findsWidgets);
        expect(find.text('Active Alerts'), findsWidgets);
        expect(find.text('Family Members'), findsOneWidget);
        expect(find.text('Patient Health Dashboard'), findsOneWidget);
      },
    );

    testWidgets('opens Link Patient Profile dialog on action tap', (
      WidgetTester tester,
    ) async {
      CaregiverService.instance.initMock();

      await tester.pumpWidget(const MaterialApp(home: CaregiverHomeScreen()));
      await tester.pumpAndSettle();

      final linkBtn = find.text('+ Link Patient').first;
      await tester.tap(linkBtn);
      await tester.pumpAndSettle();

      expect(find.text('Link Patient Profile'), findsOneWidget);
      expect(find.text('Patient UID'), findsOneWidget);
    });
  });
}
