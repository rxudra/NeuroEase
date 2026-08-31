import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/widgets/shared_empty_state.dart';
import '../models/patient_status_model.dart';
import '../services/caregiver_service.dart';
import '../widgets/patient_card.dart';
import 'caregiver_patient_detail_screen.dart';

import '../../health/screens/caregiver_patient_health_screen.dart';

class CaregiverPatientsScreen extends StatefulWidget {
  const CaregiverPatientsScreen({super.key});

  @override
  State<CaregiverPatientsScreen> createState() =>
      _CaregiverPatientsScreenState();
}

class _CaregiverPatientsScreenState extends State<CaregiverPatientsScreen> {
  StreamSubscription<List<PatientStatusModel>>? _patientsSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint(
        '[PATIENT DEBUG] Post frame callback triggered for CaregiverPatientsScreen',
      );
    });
    _patientsSub = CaregiverService.instance.patientsStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
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

  void _handlePatientTap(PatientStatusModel p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CaregiverPatientDetailScreen(patientStatus: p),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[PATIENT DEBUG] screen build started');
    debugPrintStack();
    final patients = CaregiverService.instance.getPatients();

    debugPrint('[PATIENT DEBUG] patients count = ${patients.length}');
    debugPrint(
      '[PATIENT DEBUG] patient IDs = ${patients.map((p) => p.patientId).toList()}',
    );

    if (patients.isEmpty) {
      debugPrint('[PATIENT DEBUG] building empty state');
    } else {
      for (final p in patients) {
        debugPrint(
          '[PATIENT DEBUG] building patient card = ${p.patientId} (${p.name})',
        );
      }
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Patients',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.monitor_heart_outlined),
                  tooltip: 'Health Dashboard',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CaregiverPatientHealthScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.person_add),
                  tooltip: 'Link Patient',
                  onPressed: _showLinkPatientDialog,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 0,
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 28,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Linked Patients',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${patients.length} patient${patients.length == 1 ? "" : "s"} linked to workspace',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 36),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onPressed: _showLinkPatientDialog,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Link'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (patients.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            const SharedEmptyState(
                              title: 'No linked patients yet',
                              subtitle:
                                  'Link a patient using their Patient UID to monitor their well-being.',
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _showLinkPatientDialog,
                              icon: const Icon(Icons.person_add),
                              label: const Text('Link Patient'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: patients
                          .map(
                            (p) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: PatientCard(
                                status: p,
                                onTap: () => _handlePatientTap(p),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
