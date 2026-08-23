import 'dart:async';
import 'package:flutter/material.dart';

import '../../emergency/screens/emergency_home_screen.dart';
import '../models/alert_model.dart';
import '../models/patient_status_model.dart';
import '../services/caregiver_service.dart';
import '../widgets/alert_card.dart';
import '../widgets/emergency_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/family_card.dart';
import '../widgets/patient_card.dart';
import '../widgets/section_header.dart';
import '../widgets/statistic_tile.dart';

class CaregiverHomeScreen extends StatefulWidget {
  const CaregiverHomeScreen({super.key});

  @override
  State<CaregiverHomeScreen> createState() => _CaregiverHomeScreenState();
}

class _CaregiverHomeScreenState extends State<CaregiverHomeScreen> {
  StreamSubscription<List<AlertModel>>? _alertsSub;
  StreamSubscription<List<PatientStatusModel>>? _patientsSub;

  @override
  void initState() {
    super.initState();
    _alertsSub = CaregiverService.instance.stream.listen((_) {
      if (mounted) setState(() {});
    });
    _patientsSub = CaregiverService.instance.patientsStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _alertsSub?.cancel();
    _patientsSub?.cancel();
    super.dispose();
  }

  void _showLinkPatientDialog() {
    final uidController = TextEditingController();
    final relationshipController = TextEditingController(
      text: 'Primary Caregiver',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Link Patient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the Patient UID to link their profile to your Caregiver Workspace.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: uidController,
              decoration: const InputDecoration(
                labelText: 'Patient UID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: relationshipController,
              decoration: const InputDecoration(
                labelText: 'Relationship (e.g. Father, Daughter)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.family_restroom),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final uid = uidController.text.trim();
              final rel = relationshipController.text.trim();
              if (uid.isNotEmpty) {
                await CaregiverService.instance.linkPatient(
                  uid,
                  relationship: rel.isNotEmpty ? rel : 'Primary Caregiver',
                );
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Link'),
          ),
        ],
      ),
    );
  }

  void _confirmUnlinkPatient(PatientStatusModel p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unlink Patient'),
        content: Text(
          'Are you sure you want to remove ${p.name} from your Caregiver Workspace?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () async {
              await CaregiverService.instance.unlinkPatient(p.patientId);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Unlink'),
          ),
        ],
      ),
    );
  }

  void _showAlertDetailDialog(AlertModel a) {
    CaregiverService.instance.markAlertRead(a.id);
    final isCritical = a.severity >= 4 || a.type == AlertType.fall;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isCritical ? Icons.warning_amber_rounded : Icons.info_outline,
              color: isCritical ? Theme.of(context).colorScheme.error : null,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(a.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (a.patientId.isNotEmpty) ...[
              Text(
                'Patient ID: ${a.patientId}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
            ],
            Text('Details: ${a.details}'),
            const SizedBox(height: 6),
            Text(
              'Time: ${a.time != null ? a.time!.toIso8601String().replaceFirst('T', ' ').substring(0, 16) : 'N/A'}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              'Severity: ${a.severity} / 5',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCritical ? Theme.of(context).colorScheme.error : null,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          if (isCritical)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmergencyHomeScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.sos),
              label: const Text('View Emergency Timeline'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = CaregiverService.instance;
    final caregiver = service.caregiver;
    final patients = service.getPatients();
    final alerts = service.getAlerts();
    final family = service.getFamily();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Link Patient',
            onPressed: _showLinkPatientDialog,
          ),
        ],
      ),
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
                        caregiver.name.isNotEmpty
                            ? caregiver.name
                            : 'Caregiver',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        caregiver.role.isNotEmpty
                            ? caregiver.role
                            : 'Primary Caregiver',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
                EmergencyButton(onPressed: () {}),
              ],
            ),
            const SizedBox(height: 12),
            SectionHeader(
              title: 'Patients',
              actionLabel: '+ Link',
              onAction: _showLinkPatientDialog,
            ),
            const SizedBox(height: 8),
            if (patients.isEmpty)
              const EmptyState(title: 'No linked patients yet')
            else
              Column(
                children: patients
                    .map(
                      (p) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: PatientCard(
                          status: p,
                          onTap: () => _confirmUnlinkPatient(p),
                        ),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 12),
            SectionHeader(
              title: 'Alerts',
              actionLabel: alerts.isNotEmpty ? 'Dismiss all' : null,
              onAction: alerts.isNotEmpty
                  ? () {
                      for (final a in List.from(alerts)) {
                        CaregiverService.instance.dismissAlert(a.id);
                      }
                    }
                  : null,
            ),
            const SizedBox(height: 8),
            if (alerts.isEmpty)
              const EmptyState(title: 'No active alerts')
            else
              Column(
                children: alerts
                    .map(
                      (a) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: AlertCard(
                          alert: a,
                          onDismiss: () {
                            CaregiverService.instance.dismissAlert(a.id);
                          },
                          onView: () => _showAlertDetailDialog(a),
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
              children: [
                StatisticTile(
                  title: 'Linked Patients',
                  value: '${patients.length}',
                ),
                StatisticTile(
                  title: 'Active Alerts',
                  value: '${alerts.length}',
                ),
                const StatisticTile(title: 'Adherence', value: '100%'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
