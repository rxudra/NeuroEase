import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/spacing.dart';

import '../../medication/services/medication_service.dart';
import '../models/patient_model.dart';
import '../services/profile_service.dart';
import '../../auth/auth_service.dart';
import '../../backend/data/firestore_user_repository.dart';
import '../../backend/repositories/user_repository.dart';
import '../widgets/profile_header.dart';
import '../widgets/section_title.dart';
import '../widgets/info_card.dart';
import '../widgets/health_card.dart';
import '../widgets/emergency_card.dart';
import '../widgets/medical_timeline.dart';
import '../../medication/widgets/medication_card.dart' as med_widget;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _service = ProfileService.instance;
  final UserRepository _userRepo = FirestoreUserRepository();
  bool _loading = true;
  String? _error;
  PatientModel? _patient;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final authUser =
          AuthService().currentUser ?? FirebaseAuth.instance.currentUser;
      if (authUser == null) {
        // fallback to mock
        _service.initMock();
        _patient = _service.getPatient();
      } else {
        final uid = authUser.uid;
        final fetched = await _userRepo.getById(uid);
        if (fetched == null) {
          // If user doc doesn't exist, fallback to mock and set id to uid
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
          _patient = updated;
          await _userRepo.save(updated);
        } else {
          _patient = fetched;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile(PatientModel updated) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _userRepo.save(updated);
      setState(() => _patient = updated);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(body: Center(child: Text('Error: $_error')));
    }

    final PatientModel p = _patient ?? _service.getPatient();
    final meds = MedicationService.instance.getUpcomingForDate(DateTime.now());

    final history = [
      {
        'date': '2026-07-12',
        'title': 'Hospital visit',
        'notes': 'Routine checkup',
      },
      {'date': '2025-11-02', 'title': 'Surgery', 'notes': 'Appendix removal'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Patient Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeader(patient: p),
            SizedBox(height: AppSpacing.md),
            SectionTitle(
              title: 'Personal information',
              actionLabel: 'Edit',
              onAction: () async {
                final edited = await showDialog<PatientModel>(
                  context: context,
                  builder: (ctx) {
                    final nameCtl = TextEditingController(text: p.fullName);
                    final phoneCtl = TextEditingController(text: p.phone);
                    final emailCtl = TextEditingController(text: p.email);
                    final addrCtl = TextEditingController(text: p.address);
                    return AlertDialog(
                      title: const Text('Edit profile'),
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextField(
                              controller: nameCtl,
                              decoration: const InputDecoration(
                                labelText: 'Full name',
                              ),
                            ),
                            TextField(
                              controller: phoneCtl,
                              decoration: const InputDecoration(
                                labelText: 'Phone',
                              ),
                            ),
                            TextField(
                              controller: emailCtl,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                              ),
                            ),
                            TextField(
                              controller: addrCtl,
                              decoration: const InputDecoration(
                                labelText: 'Address',
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            final updated = PatientModel(
                              id: p.id,
                              fullName: nameCtl.text.trim(),
                              nickname: p.nickname,
                              dob: p.dob,
                              gender: p.gender,
                              bloodGroup: p.bloodGroup,
                              heightCm: p.heightCm,
                              weightKg: p.weightKg,
                              phone: phoneCtl.text.trim(),
                              email: emailCtl.text.trim(),
                              address: addrCtl.text.trim(),
                              doctor: p.doctor,
                              hospital: p.hospital,
                              allergies: p.allergies,
                              conditions: p.conditions,
                              medications: p.medications,
                              emergencyContacts: p.emergencyContacts,
                              notes: p.notes,
                              createdAt: p.createdAt,
                              photoUrl: p.photoUrl,
                            );
                            Navigator.of(ctx).pop(updated);
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    );
                  },
                );
                if (edited != null) {
                  await _saveProfile(edited);
                }
              },
            ),
            SizedBox(height: AppSpacing.sm),
            InfoCard(title: 'Phone', value: p.phone),
            SizedBox(height: AppSpacing.sm),
            InfoCard(title: 'Email', value: p.email),
            SizedBox(height: AppSpacing.sm),
            InfoCard(title: 'Address', value: p.address),
            SizedBox(height: AppSpacing.md),
            SectionTitle(title: 'Medical information'),
            SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                HealthCard(title: 'BMI', value: _bmi(p).toStringAsFixed(1)),
                HealthCard(title: 'Blood Group', value: p.bloodGroup),
                HealthCard(title: 'Age', value: '${p.age}'),
                HealthCard(title: 'Medications', value: '${meds.length}'),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            SectionTitle(title: 'Emergency contacts'),
            SizedBox(height: AppSpacing.sm),
            Column(
              children: p.emergencyContacts
                  .map(
                    (c) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: EmergencyCard(contact: c),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: AppSpacing.md),
            SectionTitle(title: 'Medical history'),
            SizedBox(height: AppSpacing.sm),
            MedicalTimeline(events: history),
            const SizedBox(height: 12),
            SectionTitle(title: 'Current medications'),
            const SizedBox(height: 8),
            if (meds.isEmpty)
              const SizedBox()
            else
              Column(
                children: meds
                    .map(
                      (m) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: med_widget.MedicationCard(med: m),
                      ),
                    )
                    .toList(),
              ),
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
