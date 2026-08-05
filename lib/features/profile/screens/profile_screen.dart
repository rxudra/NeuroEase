import 'package:flutter/material.dart';
import '../../medication/services/medication_service.dart';
import '../models/patient_model.dart';
import '../services/profile_service.dart';
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

  @override
  void initState() {
    super.initState();
    _service.initMock();
  }

  @override
  Widget build(BuildContext context) {
    final PatientModel p = _service.getPatient();
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
            const SizedBox(height: 12),
            SectionTitle(
              title: 'Personal information',
              actionLabel: 'Edit',
              onAction: () {},
            ),
            const SizedBox(height: 8),
            InfoCard(title: 'Phone', value: p.phone),
            const SizedBox(height: 8),
            InfoCard(title: 'Email', value: p.email),
            const SizedBox(height: 8),
            InfoCard(title: 'Address', value: p.address),
            const SizedBox(height: 12),
            SectionTitle(title: 'Medical information'),
            const SizedBox(height: 8),
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
            const SizedBox(height: 12),
            SectionTitle(title: 'Emergency contacts'),
            const SizedBox(height: 8),
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
            const SizedBox(height: 12),
            SectionTitle(title: 'Medical history'),
            const SizedBox(height: 8),
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
