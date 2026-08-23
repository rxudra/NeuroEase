import 'dart:async';
import 'package:flutter/material.dart';

import '../../auth/auth_gate.dart';
import '../../auth/auth_service.dart';
import '../../emergency/screens/emergency_home_screen.dart';
import '../models/alert_model.dart';
import '../models/family_member_model.dart';
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
  StreamSubscription<List<FamilyMemberModel>>? _familySub;

  @override
  void initState() {
    super.initState();
    _alertsSub = CaregiverService.instance.stream.listen((_) {
      if (mounted) setState(() {});
    });
    _patientsSub = CaregiverService.instance.patientsStream.listen((_) {
      if (mounted) setState(() {});
    });
    _familySub = CaregiverService.instance.familyStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _alertsSub?.cancel();
    _patientsSub?.cancel();
    _familySub?.cancel();
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

  void _showAddEditFamilyMemberDialog([FamilyMemberModel? existing]) {
    final isEditing = existing != null;
    final nameController = TextEditingController(text: existing?.name ?? '');
    final relController = TextEditingController(
      text: existing?.relationship ?? '',
    );
    final phoneController = TextEditingController(text: existing?.phone ?? '');
    String roleValue =
        (existing?.role == 'Primary' || existing?.role == 'Secondary')
        ? existing!.role
        : 'Primary';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Family Member' : 'Add Family Member'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: relController,
                  decoration: const InputDecoration(
                    labelText: 'Relationship (e.g. Daughter, Son, Spouse)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.family_restroom),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: roleValue,
                  decoration: const InputDecoration(
                    labelText: 'Priority / Role',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.star_outline),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Primary', child: Text('Primary')),
                    DropdownMenuItem(
                      value: 'Secondary',
                      child: Text('Secondary'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => roleValue = val);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final rel = relController.text.trim();
                final phone = phoneController.text.trim();
                if (name.isNotEmpty) {
                  final member = FamilyMemberModel(
                    id:
                        existing?.id ??
                        'fam_${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    relationship: rel.isNotEmpty ? rel : 'Family Member',
                    phone: phone,
                    role: roleValue,
                  );
                  if (isEditing) {
                    await CaregiverService.instance.updateFamilyMember(member);
                  } else {
                    await CaregiverService.instance.addFamilyMember(member);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteFamilyMember(FamilyMemberModel m) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Family Member'),
        content: Text(
          'Are you sure you want to delete ${m.name} from your Family Members?',
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
              await CaregiverService.instance.deleteFamilyMember(m.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete'),
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
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log out',
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthGate()),
                  (route) => false,
                );
              }
            },
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
            SectionHeader(
              title: 'Family Members',
              actionLabel: '+ Add',
              onAction: () => _showAddEditFamilyMemberDialog(),
            ),
            const SizedBox(height: 8),
            if (family.isEmpty)
              const EmptyState(title: 'No family members')
            else
              Column(
                children: family
                    .map(
                      (m) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: FamilyCard(
                          member: m,
                          onEdit: () => _showAddEditFamilyMemberDialog(m),
                          onDelete: () => _confirmDeleteFamilyMember(m),
                        ),
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
