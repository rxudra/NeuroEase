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
                    Text(
                      patient.age != null
                          ? '${patient.age} yrs'
                          : 'Not recorded',
                    ),
                    const SizedBox(width: 12),
                    Chip(label: Text(patient.bloodGroup)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
