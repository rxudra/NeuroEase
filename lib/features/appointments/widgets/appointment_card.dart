import 'package:flutter/material.dart';
import '../../appointments/models/appointment_model.dart';
import '../../../core/widgets/app_cards.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({required this.appointment, this.onTap, super.key});

  final AppointmentModel appointment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final timeText = appointment.appointmentTime.format(context);
    final dateText = appointment.appointmentDate
        .toLocal()
        .toIso8601String()
        .split('T')
        .first;
    return AppCard(
      child: ListTile(
        onTap: onTap,
        leading: Icon(Icons.local_hospital, color: color),
        title: Text(
          appointment.doctorName,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('$dateText • $timeText • ${appointment.hospitalName}'),
        trailing: appointment.isCompleted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}
