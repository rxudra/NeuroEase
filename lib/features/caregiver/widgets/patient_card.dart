import 'package:flutter/material.dart';
import '../../../core/widgets/app_cards.dart';
import '../models/patient_status_model.dart';

class PatientCard extends StatelessWidget {
  const PatientCard({required this.status, this.onTap, super.key});

  final PatientStatusModel status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final lastActiveStr = status.lastActive != null
        ? (status.lastActive!.toIso8601String().length >= 16
              ? status.lastActive!.toIso8601String().substring(11, 16)
              : status.lastActive!.toIso8601String())
        : 'N/A';

    return AppCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Text(status.name.isNotEmpty ? status.name[0] : '?'),
        ),
        title: Text(
          status.name,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${status.online ? 'Online' : 'Offline'} • Last active $lastActiveStr',
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(status.location),
            const SizedBox(height: 4),
            Icon(
              status.online ? Icons.circle : Icons.circle_outlined,
              color: status.online ? Colors.green : Colors.grey,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }
}
