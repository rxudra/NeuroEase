import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/health/screens/caregiver_patient_health_screen.dart';
import 'package:app/features/caregiver/models/patient_status_model.dart';
import 'package:app/features/caregiver/services/caregiver_service.dart';

void main() {
  group('CaregiverPatientHealthScreen Widget Tests', () {
    testWidgets(
      'renders CaregiverPatientHealthScreen layout for linked patient',
      (tester) async {
        CaregiverService.instance.initMock();

        final mockPatient = PatientStatusModel(
          patientId: 'p1',
          name: 'Rudra Kumar',
          avatarUrl: '',
          lastActive: DateTime.now(),
          location: 'Home',
          online: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: CaregiverPatientHealthScreen(
              initialPatientStatus: mockPatient,
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Patient Health Dashboard'), findsOneWidget);
        expect(find.text('Physical & Body Metrics'), findsOneWidget);
        expect(find.text('Medication Schedule & Monitor'), findsOneWidget);
        expect(find.text('Medical Profile'), findsOneWidget);
        expect(find.text('Emergency Contacts'), findsOneWidget);
        expect(find.text('Device Telemetry'), findsOneWidget);
        expect(find.text('Disconnected'), findsOneWidget);
      },
    );

    testWidgets('renders empty state when no linked patients exist', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: CaregiverPatientHealthScreen()),
      );
      await tester.pump();

      expect(find.text('Patient Health Dashboard'), findsOneWidget);
    });
  });
}
