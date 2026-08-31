import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../../auth/auth_service.dart';
import '../../backend/data/firestore_user_repository.dart';
import '../../backend/repositories/user_repository.dart';
import '../../medication/services/medication_service.dart';
import '../../medication/widgets/medication_card.dart' as med_widget;
import '../models/patient_model.dart';
import '../services/profile_service.dart';
import '../widgets/emergency_card.dart';
import '../widgets/health_card.dart';
import '../widgets/info_card.dart';
import '../widgets/medical_timeline.dart';
import '../widgets/profile_header.dart';
import '../widgets/section_title.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _service = ProfileService.instance;
  final UserRepository _userRepo = FirestoreUserRepository();
  bool _loading = true;
  PatientModel? _patient;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
    });
    try {
      final authUser =
          AuthService().currentUser ?? FirebaseAuth.instance.currentUser;
      if (authUser == null) {
        _service.initMock();
        _patient = _service.getPatient();
      } else {
        final uid = authUser.uid;
        final fetched = await _userRepo.getById(uid);
        if (fetched == null) {
          _service.initMock();
          final mock = _service.getPatient();
          final updated = PatientModel(
            id: uid,
            fullName: mock.fullName,
            nickname: mock.nickname,
            dob: mock.dob,
            gender: mock.gender,
            bloodGroup: mock.bloodGroup,
            heightCm: mock.heightCm,
            weightKg: mock.weightKg,
            phone: mock.phone,
            email: mock.email,
            address: mock.address,
            doctor: mock.doctor,
            hospital: mock.hospital,
            allergies: mock.allergies,
            conditions: mock.conditions,
            medications: mock.medications,
            emergencyContacts: mock.emergencyContacts,
            notes: mock.notes,
            createdAt: mock.createdAt,
            photoUrl: mock.photoUrl,
          );
          await _userRepo.save(updated);
          _service.updatePatient(updated);
          _patient = updated;
        } else {
          _service.updatePatient(fetched);
          _patient = fetched;
        }
      }
    } catch (_) {
      _service.initMock();
      _patient = _service.getPatient();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile(PatientModel updated) async {
    try {
      await _userRepo.save(updated);
      _service.updatePatient(updated);
      if (mounted) {
        setState(() => _patient = updated);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medical profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
      }
    }
  }

  void _showEditProfileModal(PatientModel p) {
    final nameCtl = TextEditingController(text: p.fullName);
    final phoneCtl = TextEditingController(text: p.phone);
    final emailCtl = TextEditingController(text: p.email);
    final addrCtl = TextEditingController(text: p.address);
    final doctorCtl = TextEditingController(text: p.doctor);
    final hospitalCtl = TextEditingController(text: p.hospital);
    final bloodCtl = TextEditingController(text: p.bloodGroup);
    final heightCtl = TextEditingController(
      text: p.heightCm > 0 ? '${p.heightCm}' : '',
    );
    final weightCtl = TextEditingController(
      text: p.weightKg > 0 ? '${p.weightKg}' : '',
    );
    final conditionsCtl = TextEditingController(text: p.conditions.join(', '));
    final allergiesCtl = TextEditingController(text: p.allergies.join(', '));

    DateTime? selectedDob = p.dob;
    String formatDob(DateTime? d) {
      if (d == null) return '';
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    }

    final dobCtl = TextEditingController(text: formatDob(selectedDob));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: const Text('Edit Medical Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtl,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: dobCtl,
                  readOnly: true,
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: dialogCtx,
                      initialDate:
                          (selectedDob != null && !selectedDob!.isAfter(now))
                          ? selectedDob!
                          : DateTime(1990, 1, 1),
                      firstDate: DateTime(1900, 1, 1),
                      lastDate: now,
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedDob = picked;
                        dobCtl.text = formatDob(picked);
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: 'DD/MM/YYYY',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailCtl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addrCtl,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: doctorCtl,
                        decoration: const InputDecoration(
                          labelText: 'Doctor Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: hospitalCtl,
                        decoration: const InputDecoration(
                          labelText: 'Hospital',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: bloodCtl,
                        decoration: const InputDecoration(
                          labelText: 'Blood Group',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: heightCtl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Height (cm)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: weightCtl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Weight (kg)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: conditionsCtl,
                  decoration: const InputDecoration(
                    labelText: 'Conditions (comma-separated)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: allergiesCtl,
                  decoration: const InputDecoration(
                    labelText: 'Allergies (comma-separated)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final conditionsList = conditionsCtl.text
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList();
                final allergiesList = allergiesCtl.text
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList();

                final updated = PatientModel(
                  id: p.id,
                  fullName: nameCtl.text.trim(),
                  nickname: p.nickname,
                  dob: selectedDob,
                  gender: p.gender,
                  bloodGroup: bloodCtl.text.trim(),
                  heightCm: int.tryParse(heightCtl.text.trim()) ?? p.heightCm,
                  weightKg: int.tryParse(weightCtl.text.trim()) ?? p.weightKg,
                  phone: phoneCtl.text.trim(),
                  email: emailCtl.text.trim(),
                  address: addrCtl.text.trim(),
                  doctor: doctorCtl.text.trim(),
                  hospital: hospitalCtl.text.trim(),
                  allergies: allergiesList,
                  conditions: conditionsList,
                  medications: p.medications,
                  emergencyContacts: p.emergencyContacts,
                  notes: p.notes,
                  createdAt: p.createdAt,
                  photoUrl: p.photoUrl,
                );
                Navigator.of(dialogCtx).pop(updated);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    ).then((edited) {
      if (edited is PatientModel) {
        _saveProfile(edited);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Patient Medical History')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final p = _patient ?? _service.getPatient();
    final meds = MedicationService.instance.getAll();
    final history = [
      {
        'date': p.createdAt.toIso8601String().split('T').first,
        'title': 'Joined NeuroEase Patient Portal',
        'notes': p.doctor.isNotEmpty
            ? 'Primary Physician: ${p.doctor} (${p.hospital})'
            : 'No primary physician specified',
      },
      if (p.conditions.isNotEmpty)
        {
          'date': p.createdAt.toIso8601String().split('T').first,
          'title': 'Diagnosed Conditions Logged',
          'notes': p.conditions.join(', '),
        },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Medical History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Medical Profile',
            onPressed: () => _showEditProfileModal(p),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeader(patient: p),
            SizedBox(height: AppSpacing.sm),
            InfoCard(
              title: 'Phone',
              value: p.phone.isNotEmpty ? p.phone : 'Not provided',
            ),
            SizedBox(height: AppSpacing.sm),
            InfoCard(
              title: 'Email',
              value: p.email.isNotEmpty ? p.email : 'Not provided',
            ),
            SizedBox(height: AppSpacing.sm),
            InfoCard(
              title: 'Address',
              value: p.address.isNotEmpty ? p.address : 'Not provided',
            ),
            SizedBox(height: AppSpacing.sm),
            InfoCard(
              title: 'Date of Birth',
              value: p.dob != null
                  ? '${p.dob!.day.toString().padLeft(2, '0')}/${p.dob!.month.toString().padLeft(2, '0')}/${p.dob!.year}'
                  : 'Not recorded',
            ),
            SizedBox(height: AppSpacing.md),

            SectionTitle(title: 'Clinical Summary'),
            SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                HealthCard(title: 'BMI', value: _bmi(p).toStringAsFixed(1)),
                HealthCard(
                  title: 'Blood Group',
                  value: p.bloodGroup.isNotEmpty ? p.bloodGroup : '--',
                ),
                HealthCard(
                  title: 'Age',
                  value: p.age != null ? '${p.age}' : 'Not recorded',
                ),
                HealthCard(title: 'Active Meds', value: '${meds.length}'),
              ],
            ),
            SizedBox(height: AppSpacing.md),

            // DIAGNOSED CONDITIONS
            SectionTitle(title: 'Diagnosed Conditions'),
            SizedBox(height: AppSpacing.sm),
            if (p.conditions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No diagnosed medical conditions recorded.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: p.conditions
                    .map(
                      (c) => Chip(
                        avatar: const Icon(
                          Icons.medical_information_outlined,
                          size: 16,
                        ),
                        label: Text(c),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withValues(alpha: 0.4),
                      ),
                    )
                    .toList(),
              ),
            SizedBox(height: AppSpacing.md),

            // ALLERGIES & SENSITIVITIES
            SectionTitle(title: 'Allergies & Sensitivities'),
            SizedBox(height: AppSpacing.sm),
            if (p.allergies.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No known allergies recorded.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: p.allergies
                    .map(
                      (a) => Chip(
                        avatar: const Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: Colors.red,
                        ),
                        label: Text(a),
                        backgroundColor: Colors.red.shade50,
                        side: BorderSide(color: Colors.red.shade200),
                      ),
                    )
                    .toList(),
              ),
            SizedBox(height: AppSpacing.md),

            // PRIMARY PHYSICIAN & HOSPITAL
            SectionTitle(title: 'Primary Healthcare Provider'),
            SizedBox(height: AppSpacing.sm),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.local_hospital_outlined,
                  color: Colors.blue,
                ),
                title: Text(
                  p.doctor.isNotEmpty ? p.doctor : 'Doctor: Not specified',
                ),
                subtitle: Text(
                  p.hospital.isNotEmpty
                      ? p.hospital
                      : 'Hospital/Clinic: Not specified',
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),

            // RELEVANT MEDICAL NOTES
            SectionTitle(title: 'Medical Notes'),
            SizedBox(height: AppSpacing.sm),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  p.notes.isNotEmpty
                      ? p.notes
                      : 'No specific medical notes recorded.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),

            SectionTitle(title: 'Emergency Contacts'),
            SizedBox(height: AppSpacing.sm),
            if (p.emergencyContacts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No emergency contacts configured.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              )
            else
              Column(
                children: p.emergencyContacts
                    .map(
                      (c) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: EmergencyCard(contact: c),
                      ),
                    )
                    .toList(),
              ),
            SizedBox(height: AppSpacing.md),

            SectionTitle(title: 'Medical Event History'),
            SizedBox(height: AppSpacing.sm),
            MedicalTimeline(events: history),
            const SizedBox(height: 16),

            SectionTitle(title: 'Current Prescriptions'),
            const SizedBox(height: 8),
            if (meds.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No current prescriptions recorded.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              )
            else
              Column(
                children: meds
                    .map(
                      (m) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: med_widget.MedicationCard(med: m),
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

  double _bmi(PatientModel p) {
    if (p.heightCm <= 0) return 0.0;
    final m = p.weightKg / ((p.heightCm / 100) * (p.heightCm / 100));
    return m;
  }
}
