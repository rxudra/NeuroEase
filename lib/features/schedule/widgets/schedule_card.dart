import 'package:flutter/material.dart';
import '../../../core/widgets/app_cards.dart';
import '../models/schedule_task.dart';

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({required this.task, this.onTap, super.key});

  final ScheduleTask task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(task.colorValue);
    return AppCard(
      child: ListTile(
        onTap: onTap,
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(_iconFor(task.category), color: color)],
        ),
        title: Text(
          task.title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('${task.time.format(context)} • ${task.category}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (task.completed)
              const Icon(Icons.check_circle, color: Colors.green)
            else
              const Icon(Icons.radio_button_unchecked),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String category) {
    switch (category.toLowerCase()) {
      case 'medication':
        return Icons.medication;
      case 'doctor visit':
      case 'appointment':
        return Icons.local_hospital;
      case 'exercise':
        return Icons.directions_run;
      case 'meals':
        return Icons.restaurant;
      case 'sleep':
        return Icons.hotel;
      case 'hydration':
        return Icons.local_drink;
      default:
        return Icons.event;
    }
  }
}
