import 'package:flutter/material.dart';
import '../services/caregiver_service.dart';
import '../widgets/section_header.dart';
import '../widgets/patient_card.dart';
import '../widgets/alert_card.dart';
// imported health_card not used here
import '../widgets/family_card.dart';
import '../widgets/statistic_tile.dart';
import '../widgets/emergency_button.dart';
import '../widgets/empty_state.dart';

class CaregiverHomeScreen extends StatefulWidget {
  const CaregiverHomeScreen({super.key});

  @override
  State<CaregiverHomeScreen> createState() => _CaregiverHomeScreenState();
}

class _CaregiverHomeScreenState extends State<CaregiverHomeScreen> {
  @override
  void initState() {
    super.initState();
    CaregiverService.instance.initMock();
  }

  @override
  Widget build(BuildContext context) {
    final service = CaregiverService.instance;
    final patients = service.getPatients();
    final alerts = service.getAlerts();
    final family = service.getFamily();

    return Scaffold(
      appBar: AppBar(title: const Text('Caregiver Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Priya Sharma',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Primary Caregiver',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
                EmergencyButton(onPressed: () {}),
              ],
            ),
            const SizedBox(height: 12),
            SectionHeader(title: 'Patients'),
            const SizedBox(height: 8),
            if (patients.isEmpty)
              const EmptyState(title: 'No patients')
            else
              Column(
                children: patients
                    .map(
                      (p) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: PatientCard(status: p),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 12),
            SectionHeader(
              title: 'Alerts',
              actionLabel: 'Dismiss all',
              onAction: () {},
            ),
            const SizedBox(height: 8),
            if (alerts.isEmpty)
              const EmptyState(title: 'No alerts')
            else
              Column(
                children: alerts
                    .map(
                      (a) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: AlertCard(
                          alert: a,
                          onDismiss: () {
                            setState(() {
                              CaregiverService.instance.dismissAlert(a.id);
                            });
                          },
                          onView: () {},
                        ),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 12),
            SectionHeader(title: 'Family Members'),
            const SizedBox(height: 8),
            if (family.isEmpty)
              const EmptyState(title: 'No family members')
            else
              Column(
                children: family
                    .map(
                      (m) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: FamilyCard(member: m),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 12),
            SectionHeader(title: 'Quick Stats'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                StatisticTile(title: 'Med Taken', value: '86%'),
                StatisticTile(title: 'Missed', value: '2'),
                StatisticTile(title: 'Appointments', value: '1'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
