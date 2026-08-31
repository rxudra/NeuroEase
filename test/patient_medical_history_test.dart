import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/profile/screens/profile_screen.dart';
import 'package:app/features/profile/services/profile_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Patient Medical History Widget Tests', () {
    testWidgets('renders ProfileScreen with sectioned medical cards', (
      WidgetTester tester,
    ) async {
      ProfileService.instance.initMock();

      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Patient Medical History'), findsOneWidget);
      expect(find.text('Clinical Summary'), findsOneWidget);
      expect(find.text('Diagnosed Conditions'), findsOneWidget);
      expect(find.text('Allergies & Sensitivities'), findsOneWidget);
      expect(find.text('Primary Healthcare Provider'), findsOneWidget);
      expect(find.text('Medical Notes'), findsOneWidget);
      expect(find.text('Emergency Contacts'), findsOneWidget);
    });

    testWidgets('opens edit medical profile modal on edit button tap', (
      WidgetTester tester,
    ) async {
      ProfileService.instance.initMock();

      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      final editBtn = find.byIcon(Icons.edit_outlined).first;
      await tester.tap(editBtn);
      await tester.pumpAndSettle();

      expect(find.text('Edit Medical Profile'), findsOneWidget);
      expect(find.text('Doctor Name'), findsOneWidget);
      expect(find.text('Hospital'), findsOneWidget);
    });
  });
}
