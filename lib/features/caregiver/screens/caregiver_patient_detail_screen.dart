import 'package:flutter/material.dart';

import '../../ai_assistant/models/memory_model.dart';
import '../../backend/data/firestore_emergency_event_service.dart';
import '../../backend/data/firestore_medication_service.dart';
import '../../backend/data/firestore_memory_service.dart';
import '../../backend/data/firestore_schedule_service.dart';
import '../../backend/data/firestore_user_repository.dart';
import '../../emergency/models/emergency_event_model.dart';
import '../../medication/models/medication_model.dart';
import '../../profile/models/patient_model.dart';
import '../../schedule/models/schedule_task.dart';
import '../models/caregiver_relationship_model.dart';
import '../models/patient_status_model.dart';
import '../services/caregiver_service.dart';

class CaregiverPatientDetailScreen extends StatefulWidget {
  const CaregiverPatientDetailScreen({required this.patientStatus, super.key});

  final PatientStatusModel patientStatus;

  @override
  State<CaregiverPatientDetailScreen> createState() =>
      _CaregiverPatientDetailScreenState();
}

class _CaregiverPatientDetailScreenState
    extends State<CaregiverPatientDetailScreen> {
  final _userRepo = FirestoreUserRepository();
  final _medService = FirestoreMedicationService();
  final _scheduleService = FirestoreScheduleService();
  final _emergencyService = FirestoreEmergencyEventService();
  final _memoryService = FirestoreMemoryService();

  PatientModel? _patientProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _userRepo.getById(widget.patientStatus.patientId);
      if (mounted) {
        setState(() {
          _patientProfile = profile;
          _isLoadingProfile = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  String _getRelationship() {
    final links = CaregiverService.instance.getRelationshipLinks();
    final link = links.firstWhere(
      (l) => l.patientId == widget.patientStatus.patientId,
      orElse: () => CaregiverRelationshipModel(
        id: '',
        caregiverId: '',
        patientId: widget.patientStatus.patientId,
        relationship: 'Primary Caregiver',
      ),
    );
    return link.relationship.isNotEmpty
        ? link.relationship
        : 'Primary Caregiver';
  }

  void _confirmUnlink() {
    final displayName = _patientProfile?.fullName.isNotEmpty == true
        ? _patientProfile!.fullName
        : widget.patientStatus.name;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unlink Patient'),
        content: Text(
          'Are you sure you want to remove $displayName from your Caregiver Workspace?',
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
              final nav = Navigator.of(context);
              Navigator.pop(ctx);
              await CaregiverService.instance.unlinkPatient(
                widget.patientStatus.patientId,
              );
              if (mounted) {
                nav.pop();
              }
            },
            child: const Text('Unlink'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientId = widget.patientStatus.patientId;
    final displayName = _patientProfile?.fullName.isNotEmpty == true
        ? _patientProfile!.fullName
        : (widget.patientStatus.name.isNotEmpty
              ? widget.patientStatus.name
              : 'Patient Profile');

    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'unlink') _confirmUnlink();
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'unlink',
                child: Row(
                  children: [
                    Icon(Icons.link_off, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Unlink Patient', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECTION 1 — PATIENT HEADER
            _buildPatientHeader(context, displayName),
            const SizedBox(height: 16),

            // SECTION 2 — MEDICAL PROFILE
            _buildMedicalProfile(context),
            const SizedBox(height: 16),

            // SECTION 3 — EMERGENCY & SAFETY
            _buildEmergencySection(context, patientId),
            const SizedBox(height: 16),

            // SECTION 4 — MEDICATIONS
            _buildMedicationsSection(context, patientId),
            const SizedBox(height: 16),

            // SECTION 5 — TODAY / UPCOMING SCHEDULE
            _buildScheduleSection(context, patientId),
            const SizedBox(height: 16),

            // SECTION 6 — MEMORY JOURNAL
            _buildMemorySection(context, patientId),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeader(BuildContext context, String displayName) {
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
    final relationship = _getRelationship();

    return Card(
      elevation: 0,
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          relationship,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        widget.patientStatus.online
                            ? Icons.circle
                            : Icons.circle_outlined,
                        size: 10,
                        color: widget.patientStatus.online
                            ? Colors.green
                            : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.patientStatus.online ? 'Online' : 'Offline',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: widget.patientStatus.online
                              ? Colors.green
                              : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Location: ${widget.patientStatus.location}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalProfile(BuildContext context) {
    if (_isLoadingProfile) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final p = _patientProfile;
    if (p == null) {
      return _buildSectionCard(
        context,
        title: 'Medical Profile',
        icon: Icons.medical_services_outlined,
        child: const Text('No profile metadata available.'),
      );
    }

    final ageStr = p.dob != DateTime.fromMillisecondsSinceEpoch(0)
        ? '${p.age} years'
        : 'Not recorded';

    return _buildSectionCard(
      context,
      title: 'Medical Profile',
      icon: Icons.medical_services_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  context,
                  label: 'Age',
                  value: ageStr,
                  icon: Icons.cake_outlined,
                ),
              ),
              Expanded(
                child: _buildInfoTile(
                  context,
                  label: 'Blood Group',
                  value: p.bloodGroup.isNotEmpty ? p.bloodGroup : 'N/A',
                  icon: Icons.water_drop_outlined,
                ),
              ),
              Expanded(
                child: _buildInfoTile(
                  context,
                  label: 'Gender',
                  value: p.gender.isNotEmpty ? p.gender : 'N/A',
                  icon: Icons.person_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (p.doctor.isNotEmpty || p.hospital.isNotEmpty) ...[
            _buildInfoRow(
              context,
              label: 'Doctor / Clinic',
              value: [
                p.doctor,
                p.hospital,
              ].where((s) => s.isNotEmpty).join(' • '),
              icon: Icons.local_hospital_outlined,
            ),
            const SizedBox(height: 8),
          ],
          if (p.conditions.isNotEmpty) ...[
            _buildChipsRow(
              context,
              label: 'Diagnosed Conditions',
              items: p.conditions,
              chipColor: Colors.blue.shade50,
              textColor: Colors.blue.shade900,
            ),
            const SizedBox(height: 8),
          ],
          if (p.allergies.isNotEmpty) ...[
            _buildChipsRow(
              context,
              label: 'Known Allergies',
              items: p.allergies,
              chipColor: Colors.amber.shade50,
              textColor: Colors.amber.shade900,
            ),
            const SizedBox(height: 8),
          ],
          if (p.notes.isNotEmpty) ...[
            Text(
              'Medical Notes',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(p.notes, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }

  Widget _buildEmergencySection(BuildContext context, String patientId) {
    return StreamBuilder<List<EmergencyEventModel>>(
      stream: _emergencyService.streamForUser(patientId),
      builder: (context, snapshot) {
        final events = snapshot.data ?? [];
        final hasActiveSos = events.any(
          (e) => e.type == EmergencyEventType.sosTriggered,
        );

        return _buildSectionCard(
          context,
          title: 'Emergency & Safety',
          icon: Icons.warning_amber_rounded,
          iconColor: hasActiveSos
              ? Colors.red
              : Theme.of(context).colorScheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasActiveSos)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '🚨 ACTIVE EMERGENCY SOS TRIGGERED',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: Colors.red.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (events.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No recent emergency events recorded.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                Column(
                  children: events.take(3).map((e) {
                    final timeStr = e.time != null
                        ? e.time!
                              .toIso8601String()
                              .substring(0, 16)
                              .replaceAll('T', ' ')
                        : 'Recent';
                    final isSos = e.type == EmergencyEventType.sosTriggered;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: isSos
                            ? Colors.red.shade100
                            : Colors.orange.shade100,
                        child: Icon(
                          isSos ? Icons.sos : Icons.warning,
                          color: isSos ? Colors.red : Colors.orange,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        e.details.isNotEmpty ? e.details : e.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('Time: $timeStr'),
                    );
                  }).toList(),
                ),

              if (_patientProfile?.emergencyContacts.isNotEmpty == true) ...[
                const Divider(height: 24),
                Text(
                  'Emergency Contacts',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Column(
                  children: _patientProfile!.emergencyContacts.map((c) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(child: Icon(Icons.phone)),
                      title: Text('${c.name} (${c.relationship})'),
                      subtitle: Text(c.phone),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMedicationsSection(BuildContext context, String patientId) {
    return StreamBuilder<List<MedicationModel>>(
      stream: _medService.streamForUser(patientId),
      builder: (context, snapshot) {
        final meds = snapshot.data ?? [];

        return _buildSectionCard(
          context,
          title: 'Active Medications',
          icon: Icons.medication_outlined,
          child: meds.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No medications recorded for this patient.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : Column(
                  children: meds.map((m) {
                    final timesStr = m.times
                        .map(
                          (t) =>
                              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
                        )
                        .join(', ');
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.medication,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        m.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Dosage: ${m.dosage} ${m.type} • ${m.frequency}\nTimes: $timesStr${m.foodInstruction.isNotEmpty ? " • ${m.foodInstruction}" : ""}',
                      ),
                    );
                  }).toList(),
                ),
        );
      },
    );
  }

  Widget _buildScheduleSection(BuildContext context, String patientId) {
    return StreamBuilder<List<ScheduleTask>>(
      stream: _scheduleService.streamForUser(patientId),
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];

        return _buildSectionCard(
          context,
          title: 'Schedule & Upcoming Tasks',
          icon: Icons.calendar_today_outlined,
          child: tasks.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No upcoming tasks recorded.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : Column(
                  children: tasks.take(5).map((t) {
                    final timeDisplay = t.time.format(context);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        t.completed
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: t.completed ? Colors.green : Colors.grey,
                      ),
                      title: Text(
                        t.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: t.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text('$timeDisplay • ${t.category}'),
                    );
                  }).toList(),
                ),
        );
      },
    );
  }

  Widget _buildMemorySection(BuildContext context, String patientId) {
    return StreamBuilder<List<MemoryModel>>(
      stream: _memoryService.streamForUser(patientId),
      builder: (context, snapshot) {
        final memories = snapshot.data ?? [];

        return _buildSectionCard(
          context,
          title: 'Recent Memories',
          icon: Icons.book_outlined,
          child: memories.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No memory journal entries recorded.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : Column(
                  children: memories.take(5).map((m) {
                    final timeStr = m.time != null
                        ? m.time!.toIso8601String().substring(0, 10)
                        : 'Recorded';
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple.shade50,
                        child: Icon(
                          Icons.auto_stories,
                          color: Colors.purple.shade700,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        m.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${m.details}\n$timeStr • Category: ${m.category}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
        );
      },
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
    Color? iconColor,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColor ?? Theme.of(context).colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChipsRow(
    BuildContext context, {
    required String label,
    required List<String> items,
    required Color chipColor,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: chipColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
