import 'dart:async';
import 'package:flutter/material.dart';

import '../../auth/auth_gate.dart';
import '../../auth/auth_service.dart';
import '../../emergency/screens/emergency_home_screen.dart';
import '../../health/screens/caregiver_patient_health_screen.dart';
import '../../notifications/models/notification_item.dart';
import '../../notifications/screens/caregiver_notifications_screen.dart';
import '../../notifications/services/notification_service.dart';
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
import 'caregiver_patient_detail_screen.dart';
import 'caregiver_profile_screen.dart';

class CaregiverHomeScreen extends StatefulWidget {
  const CaregiverHomeScreen({super.key});

  @override
  State<CaregiverHomeScreen> createState() => _CaregiverHomeScreenState();
}

class _CaregiverHomeScreenState extends State<CaregiverHomeScreen> {
  StreamSubscription<List<AlertModel>>? _alertsSub;
  StreamSubscription<List<PatientStatusModel>>? _patientsSub;
  StreamSubscription<List<FamilyMemberModel>>? _familySub;
  StreamSubscription<List<NotificationItem>>? _notifSub;

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
    _notifSub = NotificationService.instance.stream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _alertsSub?.cancel();
    _patientsSub?.cancel();
    _familySub?.cancel();
    _notifSub?.cancel();
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
        title: const Text('Link Patient Profile'),
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
              label: const Text('View Emergency Response'),
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
    final unreadNotifs = NotificationService.instance.unreadCount;

    final hasCriticalAlert = alerts.any(
      (a) => a.severity >= 4 || a.type == AlertType.fall,
    );
    final activePatientsCount = patients.where((p) => p.online).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Dashboard'),
        actions: [
          // NOTIFICATIONS BADGE SHORTCUT
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                tooltip: 'Caregiver Notifications',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CaregiverNotificationsScreen(),
                    ),
                  );
                },
              ),
              if (unreadNotifs > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadNotifs > 99 ? '99+' : '$unreadNotifs',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            tooltip: 'Link Patient',
            onPressed: _showLinkPatientDialog,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
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
            // CRITICAL SOS WARNING BANNER IF ACTIVE ALERTS EXIST
            if (hasCriticalAlert) ...[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EmergencyHomeScreen(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade400, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red.shade800,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Critical Emergency Alert Active!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Patient SOS or fall alert recorded. Tap to view emergency response.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.red.shade800,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // CAREGIVER PROFILE & GREETING HEADER
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CaregiverProfileScreen(),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      caregiver.name.isNotEmpty
                          ? caregiver.name[0].toUpperCase()
                          : 'C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        caregiver.name.isNotEmpty
                            ? caregiver.name
                            : 'Caregiver',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        caregiver.role.isNotEmpty
                            ? caregiver.role
                            : 'Primary Caregiver',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                // WIRED EMERGENCY SOS BUTTON
                EmergencyButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EmergencyHomeScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // QUICK ACTION SHORTCUTS BAR
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ActionChip(
                    avatar: const Icon(
                      Icons.health_and_safety_outlined,
                      size: 18,
                    ),
                    label: const Text('Patient Health Dashboard'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CaregiverPatientHealthScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(
                      Icons.notifications_none_rounded,
                      size: 18,
                    ),
                    label: Text('Notifications ($unreadNotifs)'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CaregiverNotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.person_add_outlined, size: 18),
                    label: const Text('Link Patient'),
                    onPressed: _showLinkPatientDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // WORKSPACE STATISTICS
            SectionHeader(title: 'Workspace Statistics'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: StatisticTile(
                    title: 'Linked Patients',
                    value: '${patients.length}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatisticTile(
                    title: 'Active Alerts',
                    value: '${alerts.length}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatisticTile(
                    title: 'Active Status',
                    value: '$activePatientsCount / ${patients.length}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // LINKED PATIENTS SECTION
            SectionHeader(
              title: 'Linked Patients',
              actionLabel: '+ Link Patient',
              onAction: _showLinkPatientDialog,
            ),
            const SizedBox(height: 8),
            if (patients.isEmpty)
              const EmptyState(
                title: 'No linked patients in your workspace yet.',
              )
            else
              Column(
                children: patients
                    .map(
                      (p) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: PatientCard(
                          status: p,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CaregiverPatientDetailScreen(
                                  patientStatus: p,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 20),

            // ACTIVE ALERTS SECTION
            SectionHeader(
              title: 'Active Alerts',
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
              const EmptyState(title: 'No active alerts for linked patients')
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
            const SizedBox(height: 20),

            // FAMILY MEMBERS SECTION
            SectionHeader(
              title: 'Family Members',
              actionLabel: '+ Add',
              onAction: () => _showAddEditFamilyMemberDialog(),
            ),
            const SizedBox(height: 8),
            if (family.isEmpty)
              const EmptyState(title: 'No family members recorded')
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
