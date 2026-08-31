import 'package:flutter/material.dart';
import '../../../core/widgets/app_cards.dart';
import '../models/patient_status_model.dart';

class PatientCard extends StatelessWidget {
  const PatientCard({required this.status, this.onTap, super.key});

  final PatientStatusModel status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    debugPrint('[PATIENT DEBUG] PatientCard.build for ${status.patientId}');
    final lastActiveStr = status.lastActive != null
        ? (status.lastActive!.toIso8601String().length >= 16
              ? status.lastActive!.toIso8601String().substring(11, 16)
              : status.lastActive!.toIso8601String())
        : 'N/A';

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            child: Text(status.name.isNotEmpty ? status.name[0] : '?'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  status.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${status.online ? 'Online' : 'Offline'} • Last active $lastActiveStr',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                status.location,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Icon(
                status.online ? Icons.circle : Icons.circle_outlined,
                color: status.online ? Colors.green : Colors.grey,
                size: 12,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
