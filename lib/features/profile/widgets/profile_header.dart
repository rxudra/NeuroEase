import 'package:flutter/material.dart';
import '../../../core/widgets/app_cards.dart';
import 'avatar_widget.dart';
import '../models/patient_model.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.patient, super.key});

  final PatientModel patient;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Hero(
            tag: patient.id,
            child: AvatarWidget(photoUrl: patient.photoUrl, radius: 44),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.fullName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${patient.age} yrs'),
                    const SizedBox(width: 12),
                    Chip(label: Text(patient.bloodGroup)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 6),
                    Text('Emergency'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
