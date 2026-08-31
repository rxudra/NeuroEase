import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/health/screens/patient_health_dashboard_screen.dart';
import 'package:app/features/profile/services/profile_service.dart';

void main() {
  group('PatientHealthDashboardScreen Widget Tests', () {
    testWidgets(
      'renders PatientHealthDashboardScreen with physical metrics and medication adherence',
      (tester) async {
        // Initialize mock profile for test fallback
        ProfileService.instance.initMock();

        await tester.pumpWidget(
          const MaterialApp(home: PatientHealthDashboardScreen()),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Health Dashboard'), findsOneWidget);
        expect(find.text('Physical & Body Metrics'), findsOneWidget);
        expect(find.text("Today's Medication & Adherence"), findsOneWidget);
        expect(find.text('Medical Profile'), findsOneWidget);
        expect(find.text('Emergency Contacts'), findsOneWidget);
        expect(find.text('Device Telemetry'), findsOneWidget);
        expect(
          find.text('No Smartwatch or Health Sensors Linked'),
          findsOneWidget,
        );
        expect(find.text('Disconnected'), findsOneWidget);
      },
    );
  });
}
