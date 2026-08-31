import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/caregiver/screens/caregiver_profile_screen.dart';
import 'package:app/features/caregiver/services/caregiver_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CaregiverProfileScreen Widget Tests', () {
    testWidgets('renders CaregiverProfileScreen layout and elements', (
      WidgetTester tester,
    ) async {
      CaregiverService.instance.initMock();

      await tester.pumpWidget(
        const MaterialApp(home: CaregiverProfileScreen()),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Caregiver Profile'), findsOneWidget);
      expect(find.text('Account Details'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.text('Patients'), findsOneWidget);
      expect(find.text('Alerts'), findsOneWidget);
      expect(find.text('Family'), findsOneWidget);
    });

    testWidgets('displays edit profile dialog when edit button is tapped', (
      WidgetTester tester,
    ) async {
      CaregiverService.instance.initMock();

      await tester.pumpWidget(
        const MaterialApp(home: CaregiverProfileScreen()),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final editIcon = find.byIcon(Icons.edit_outlined);
      expect(editIcon, findsOneWidget);

      await tester.tap(editIcon);
      await tester.pumpAndSettle();

      expect(find.text('Edit Caregiver Profile'), findsOneWidget);
      expect(find.text('Full Name'), findsWidgets);
      expect(find.text('Caregiver Role'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });
  });
}
