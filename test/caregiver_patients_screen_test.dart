import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/caregiver/models/patient_status_model.dart';
import 'package:app/features/caregiver/widgets/patient_card.dart';
import 'package:app/features/caregiver/screens/caregiver_patients_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CaregiverPatientsScreen Widget Tests', () {
    testWidgets('renders empty state correctly without layout error', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: CaregiverPatientsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Patients'), findsOneWidget);
      expect(find.text('Linked Patients'), findsOneWidget);
      expect(find.byIcon(Icons.monitor_heart_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_add), findsWidgets);
    });

    testWidgets('PatientCard renders status details and triggers onTap', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      final status = PatientStatusModel(
        patientId: 'p_test_1',
        name: 'John Doe',
        avatarUrl: '',
        lastActive: DateTime.now(),
        location: 'Home',
        online: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatientCard(status: status, onTap: () => tapped = true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);

      await tester.tap(find.text('John Doe'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}
