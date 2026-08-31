import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/widgets/shared_empty_state.dart';
import '../../backend/data/firestore_emergency_event_service.dart';
import '../../backend/data/firestore_medication_service.dart';
import '../../backend/data/firestore_user_repository.dart';
import '../../backend/repositories/emergency_event_repository.dart';
import '../../backend/repositories/medication_repository.dart';
import '../../backend/repositories/user_repository.dart';
import '../../caregiver/models/patient_status_model.dart';
import '../../caregiver/services/caregiver_service.dart';
import '../../emergency/models/emergency_event_model.dart';
import '../../medication/models/medication_model.dart';
import '../../profile/models/patient_model.dart';

class CaregiverPatientHealthScreen extends StatefulWidget {
  const CaregiverPatientHealthScreen({super.key, this.initialPatientStatus});

  final PatientStatusModel? initialPatientStatus;

  @override
  State<CaregiverPatientHealthScreen> createState() =>
      _CaregiverPatientHealthScreenState();
}

class _CaregiverPatientHealthScreenState
    extends State<CaregiverPatientHealthScreen> {
  final UserRepository _userRepo = FirestoreUserRepository();
  final MedicationRepository _medRepo = FirestoreMedicationService();
  final EmergencyEventRepository _emergencyRepo =
      FirestoreEmergencyEventService();

  late List<PatientStatusModel> _linkedPatients;
  PatientStatusModel? _selectedPatientStatus;

  bool _loading = true;
  String? _errorMessage;
  PatientModel? _patientProfile;
  List<MedicationModel> _medications = [];
  List<EmergencyEventModel> _emergencyEvents = [];

  StreamSubscription<List<MedicationModel>>? _medSub;
  StreamSubscription<List<EmergencyEventModel>>? _emergencySub;

  @override
  void initState() {
    super.initState();
    _linkedPatients = CaregiverService.instance.getPatients();
    if (widget.initialPatientStatus != null) {
      _selectedPatientStatus = widget.initialPatientStatus;
    } else if (_linkedPatients.isNotEmpty) {
      _selectedPatientStatus = _linkedPatients.first;
    }
    _loadPatientHealthData();
  }

  @override
  void dispose() {
    _medSub?.cancel();
    _emergencySub?.cancel();
    super.dispose();
  }

  Future<void> _loadPatientHealthData() async {
    _medSub?.cancel();
    _emergencySub?.cancel();

    final selected = _selectedPatientStatus;
    if (selected == null || selected.patientId.isEmpty) {
      if (mounted) {
        setState(() {
          _loading = false;
          _patientProfile = null;
          _medications = [];
          _emergencyEvents = [];
        });
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final patientId = selected.patientId;

    try {
      final profile = await _userRepo.getById(patientId);

      _medSub = _medRepo
          .streamForUser(patientId)
          .listen(
            (meds) {
              if (mounted) {
                setState(() {
                  _medications = meds;
                });
              }
            },
            onError: (err) {
              debugPrint('[CaregiverHealth] Med stream error: $err');
            },
          );

      _emergencySub = _emergencyRepo
          .streamForUser(patientId)
          .listen(
            (events) {
              if (mounted) {
                setState(() {
                  _emergencyEvents = events;
                });
              }
            },
            onError: (err) {
              debugPrint('[CaregiverHealth] Emergency stream error: $err');
            },
          );

      if (mounted) {
        setState(() {
          _patientProfile = profile;
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _loading = false;
      });
    }
  }

  double _calculateBmi(int heightCm, int weightKg) {
    if (heightCm <= 0 || weightKg <= 0) return 0.0;
    final hM = heightCm / 100.0;
    return weightKg / (hM * hM);
  }

  String _bmiCategory(double bmi) {
    if (bmi <= 0) return 'Not recorded';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal weight';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  @override
  Widget build(BuildContext context) {
    final patients = CaregiverService.instance.getPatients();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Health Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatientHealthData,
            tooltip: 'Refresh patient data',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // PATIENT SELECTOR DROPDOWN (If multiple linked patients)
            if (patients.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_pin_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedPatientStatus?.patientId,
                          items: patients.map((p) {
                            final name = p.name.isNotEmpty
                                ? p.name
                                : 'Patient (${p.patientId.substring(0, 5)})';
                            return DropdownMenuItem<String>(
                              value: p.patientId,
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val == null) return;
                            final sel = patients.firstWhere(
                              (p) => p.patientId == val,
                              orElse: () => patients.first,
                            );
                            setState(() {
                              _selectedPatientStatus = sel;
                            });
                            _loadPatientHealthData();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Failed to load patient health dashboard',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _loadPatientHealthData,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : (patients.isEmpty && _selectedPatientStatus == null)
                  ? const SharedEmptyState(
                      title: 'No Linked Patients',
                      subtitle:
                          'Link a patient in your Caregiver Workspace to monitor their health dashboard.',
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPatientHealthData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // SECTION 1: EMERGENCY SAFETY BANNER IF SOS ACTIVE
                            _buildEmergencyBanner(context),

                            // SECTION 2: PHYSICAL & BODY METRICS
                            _buildBodyMetricsCard(context),
                            const SizedBox(height: 16),

                            // SECTION 3: MEDICATION ADHERENCE & SCHEDULE
                            _buildMedicationAdherenceCard(context),
                            const SizedBox(height: 16),

                            // SECTION 4: MEDICAL CONDITIONS & ALLERGIES
                            _buildMedicalDetailsCard(context),
                            const SizedBox(height: 16),

                            // SECTION 5: EMERGENCY CONTACTS
                            _buildEmergencyContactsCard(context),
                            const SizedBox(height: 16),

                            // SECTION 6: TELEMETRY BADGE
                            _buildDeviceTelemetryCard(context),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyBanner(BuildContext context) {
    final hasActiveSos = _emergencyEvents.any(
      (e) => e.type == EmergencyEventType.sosTriggered,
    );
    if (!hasActiveSos) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🚨 ACTIVE EMERGENCY SOS DETECTED',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Check patient status or alerts tab immediately.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyMetricsCard(BuildContext context) {
    final p = _patientProfile;
    final height = p?.heightCm ?? 0;
    final weight = p?.weightKg ?? 0;
    final bmi = _calculateBmi(height, weight);
    final bmiCat = _bmiCategory(bmi);
    final ageStr = (p != null && p.age != null)
        ? '${p.age} years'
        : 'Not recorded';

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
                  Icons.monitor_weight_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Physical & Body Metrics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    context,
                    label: 'Height',
                    value: height > 0 ? '$height cm' : 'N/A',
                    icon: Icons.height,
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    context,
                    label: 'Weight',
                    value: weight > 0 ? '$weight kg' : 'N/A',
                    icon: Icons.scale_outlined,
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    context,
                    label: 'BMI',
                    value: bmi > 0 ? bmi.toStringAsFixed(1) : 'N/A',
                    subtitle: bmiCat,
                    icon: Icons.calculate_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    context,
                    label: 'Blood Group',
                    value: (p?.bloodGroup.isNotEmpty == true)
                        ? p!.bloodGroup
                        : 'N/A',
                    icon: Icons.water_drop_outlined,
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    context,
                    label: 'Age',
                    value: ageStr,
                    icon: Icons.cake_outlined,
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    context,
                    label: 'Gender',
                    value: (p?.gender.isNotEmpty == true) ? p!.gender : 'N/A',
                    icon: Icons.person_outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationAdherenceCard(BuildContext context) {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day);
    final activeMeds = _medications.where((m) {
      final start = DateTime(
        m.startDate.year,
        m.startDate.month,
        m.startDate.day,
      );
      final end = DateTime(m.endDate.year, m.endDate.month, m.endDate.day);
      return !target.isBefore(start) && !target.isAfter(end);
    }).toList();

    int totalDoses = 0;
    for (final m in activeMeds) {
      totalDoses += m.times.length;
    }

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
                  Icons.medication_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  "Medication Schedule & Monitor",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${activeMeds.length} Active',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              '$totalDoses daily scheduled dose${totalDoses == 1 ? "" : "s"} across ${activeMeds.length} active medication${activeMeds.length == 1 ? "" : "s"}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            if (activeMeds.isEmpty)
              const Text(
                'No active medications recorded for this patient.',
                style: TextStyle(color: Colors.grey),
              )
            else
              Column(
                children: activeMeds.map((m) {
                  final timesStr = m.times
                      .map(
                        (t) =>
                            '${t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod}:${t.minute.toString().padLeft(2, '0')} ${t.period == DayPeriod.am ? 'AM' : 'PM'}',
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
                      '${m.dosage} ${m.type} • ${m.frequency}\nTimes: $timesStr${m.foodInstruction.isNotEmpty ? " • ${m.foodInstruction}" : ""}',
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalDetailsCard(BuildContext context) {
    final p = _patientProfile;
    final doctor = p?.doctor ?? '';
    final hospital = p?.hospital ?? '';
    final conditions = p?.conditions ?? [];
    final allergies = p?.allergies ?? [];
    final notes = p?.notes ?? '';

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
                  Icons.medical_services_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Medical Profile',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            if (doctor.isNotEmpty || hospital.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(
                    Icons.local_hospital_outlined,
                    size: 18,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attending Doctor / Hospital',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                        Text(
                          [
                            doctor,
                            hospital,
                          ].where((s) => s.isNotEmpty).join(' • '),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (conditions.isNotEmpty) ...[
              Text(
                'Diagnosed Conditions',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: conditions
                    .map(
                      (c) => Chip(
                        label: Text(c),
                        backgroundColor: Colors.blue.shade50,
                        labelStyle: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 12,
                        ),
                        side: BorderSide.none,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],
            if (allergies.isNotEmpty) ...[
              Text(
                'Known Allergies',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: allergies
                    .map(
                      (a) => Chip(
                        label: Text(a),
                        backgroundColor: Colors.amber.shade50,
                        labelStyle: TextStyle(
                          color: Colors.amber.shade900,
                          fontSize: 12,
                        ),
                        side: BorderSide.none,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],
            if (notes.isNotEmpty) ...[
              Text(
                'Medical Notes',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(notes, style: Theme.of(context).textTheme.bodyMedium),
            ],
            if (conditions.isEmpty &&
                allergies.isEmpty &&
                notes.isEmpty &&
                doctor.isEmpty)
              const Text(
                'No detailed medical conditions or allergies recorded.',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactsCard(BuildContext context) {
    final contacts = _patientProfile?.emergencyContacts ?? [];

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
                  Icons.phone_in_talk_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Emergency Contacts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            if (contacts.isEmpty)
              const Text(
                'No emergency contacts linked.',
                style: TextStyle(color: Colors.grey),
              )
            else
              Column(
                children: contacts.map((c) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.contact_phone_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      '${c.name} (${c.relationship})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(c.phone),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceTelemetryCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.watch_off_outlined,
                  color: Colors.grey,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Device Telemetry',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Disconnected',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            const Text(
              'No Smartwatch or Health Sensors Linked',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Real-time vital signs (heart rate, SpO2, blood pressure) require a paired health sensor on the patient device. Fake/simulated metrics are disabled to preserve medical accuracy.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String label,
    required String value,
    String? subtitle,
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
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
