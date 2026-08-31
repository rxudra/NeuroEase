import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/shared_empty_state.dart';
import '../../backend/data/firestore_user_repository.dart';
import '../../backend/repositories/user_repository.dart';
import '../../medication/models/medication_model.dart';
import '../../medication/services/medication_service.dart';
import '../../profile/models/patient_model.dart';
import '../../profile/services/profile_service.dart';

class PatientHealthDashboardScreen extends StatefulWidget {
  const PatientHealthDashboardScreen({super.key});

  @override
  State<PatientHealthDashboardScreen> createState() =>
      _PatientHealthDashboardScreenState();
}

class _PatientHealthDashboardScreenState
    extends State<PatientHealthDashboardScreen> {
  final UserRepository _userRepo = FirestoreUserRepository();
  bool _loading = true;
  String? _errorMessage;
  PatientModel? _patient;
  StreamSubscription<List<MedicationModel>>? _medSub;

  @override
  void initState() {
    super.initState();
    _medSub = MedicationService.instance.stream.listen((_) {
      if (mounted) setState(() {});
    });
    _loadData();
  }

  @override
  void dispose() {
    _medSub?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      User? user;
      try {
        user = FirebaseAuth.instance.currentUser;
      } catch (_) {
        user = null;
      }
      if (user != null) {
        final fetched = await _userRepo.getById(user.uid);
        if (mounted) {
          setState(() {
            _patient = fetched ?? ProfileService.instance.getPatient();
            _loading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _patient = ProfileService.instance.getPatient();
            _loading = false;
          });
        }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh health data',
          ),
        ],
      ),
      body: _loading
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
                      'Failed to load health profile',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : _patient == null
          ? const SharedEmptyState(
              title: 'No Health Profile',
              subtitle: 'Could not locate health profile information.',
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SECTION 1: PATIENT BODY METRICS CARD
                    _buildBodyMetricsCard(context, _patient!),
                    const SizedBox(height: 16),

                    // SECTION 2: REAL MEDICATION ADHERENCE CARD
                    _buildMedicationAdherenceCard(context),
                    const SizedBox(height: 16),

                    // SECTION 3: MEDICAL CONDITIONS & ALLERGIES CARD
                    _buildMedicalDetailsCard(context, _patient!),
                    const SizedBox(height: 16),

                    // SECTION 4: EMERGENCY CONTACTS CARD
                    _buildEmergencyContactsCard(context, _patient!),
                    const SizedBox(height: 16),

                    // SECTION 5: WEARABLE & SENSOR TELEMETRY STATUS
                    _buildDeviceTelemetryCard(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBodyMetricsCard(BuildContext context, PatientModel p) {
    final bmi = _calculateBmi(p.heightCm, p.weightKg);
    final bmiCat = _bmiCategory(bmi);
    final ageStr = p.age != null ? '${p.age} years' : 'Not recorded';

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
                    value: p.heightCm > 0 ? '${p.heightCm} cm' : 'N/A',
                    icon: Icons.height,
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    context,
                    label: 'Weight',
                    value: p.weightKg > 0 ? '${p.weightKg} kg' : 'N/A',
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
                    value: p.bloodGroup.isNotEmpty ? p.bloodGroup : 'N/A',
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
                    value: p.gender.isNotEmpty ? p.gender : 'N/A',
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
    final activeMeds = MedicationService.instance.getActiveForDate(now);

    int totalDoses = 0;
    int takenDoses = 0;

    final List<_DoseItem> doses = [];

    for (final m in activeMeds) {
      for (final t in m.times) {
        totalDoses++;
        final taken = MedicationService.instance.isTaken(m, t, now);
        if (taken) takenDoses++;
        doses.add(_DoseItem(med: m, time: t, isTaken: taken));
      }
    }

    doses.sort((a, b) {
      final aMin = a.time.hour * 60 + a.time.minute;
      final bMin = b.time.hour * 60 + b.time.minute;
      return aMin.compareTo(bMin);
    });

    final adherencePct = totalDoses > 0 ? (takenDoses / totalDoses) : 1.0;
    final pctString = '${(adherencePct * 100).round()}%';

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
                  "Today's Medication & Adherence",
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
                    color: adherencePct == 1.0
                        ? Colors.green.shade50
                        : Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$pctString Adherence',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: adherencePct == 1.0
                          ? Colors.green.shade800
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$takenDoses of $totalDoses doses completed',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: totalDoses > 0 ? adherencePct : 1.0,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          color: adherencePct == 1.0
                              ? Colors.green
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (doses.isEmpty)
              const Text(
                'No medications scheduled for today.',
                style: TextStyle(color: Colors.grey),
              )
            else
              Column(
                children: doses.map((item) {
                  final t = item.time;
                  final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
                  final minute = t.minute.toString().padLeft(2, '0');
                  final period = t.period == DayPeriod.am ? 'AM' : 'PM';
                  final timeText = '$hour:$minute $period';

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: IconButton(
                      icon: Icon(
                        item.isTaken
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: item.isTaken ? Colors.green : Colors.grey,
                        size: 24,
                      ),
                      onPressed: () {
                        setState(() {
                          MedicationService.instance.toggleTaken(
                            item.med,
                            item.time,
                            now,
                          );
                        });
                      },
                    ),
                    title: Text(
                      item.med.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: item.isTaken
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Text(
                      '${item.med.dosage} ${item.med.type} • Scheduled for $timeText${item.med.foodInstruction.isNotEmpty ? " (${item.med.foodInstruction})" : ""}',
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: item.isTaken
                            ? Colors.green.shade50
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.isTaken ? 'Taken' : 'Pending',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: item.isTaken
                              ? Colors.green.shade800
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalDetailsCard(BuildContext context, PatientModel p) {
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
            if (p.doctor.isNotEmpty || p.hospital.isNotEmpty) ...[
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
                            p.doctor,
                            p.hospital,
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
            if (p.conditions.isNotEmpty) ...[
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
                children: p.conditions
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
            if (p.allergies.isNotEmpty) ...[
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
                children: p.allergies
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
            if (p.conditions.isEmpty &&
                p.allergies.isEmpty &&
                p.notes.isEmpty &&
                p.doctor.isEmpty)
              const Text(
                'No detailed medical conditions or allergies recorded.',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactsCard(BuildContext context, PatientModel p) {
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
            if (p.emergencyContacts.isEmpty)
              const Text(
                'No emergency contacts linked.',
                style: TextStyle(color: Colors.grey),
              )
            else
              Column(
                children: p.emergencyContacts.map((c) {
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
              'Real-time vital signs (heart rate, SpO2, blood pressure) require a paired health sensor. Fake/simulated metrics are disabled to preserve medical accuracy.',
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

class _DoseItem {
  _DoseItem({required this.med, required this.time, required this.isTaken});

  final MedicationModel med;
  final TimeOfDay time;
  final bool isTaken;
}
