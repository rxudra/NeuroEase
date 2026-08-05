import 'package:flutter/material.dart';
import '../../../core/widgets/app_cards.dart';
import '../models/reminder_model.dart';

class ReminderCard extends StatelessWidget {
  const ReminderCard({required this.reminder, this.onTap, super.key});

  final ReminderModel reminder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(reminder.colorValue);
    return AppCard(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(_iconFor(reminder.category), color: Colors.white),
        ),
        title: Text(
          reminder.title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${reminder.time.format(context)} • ${reminder.category}',
        ),
        trailing: reminder.completed
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
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
        return Icons.fitness_center;
      case 'meals':
        return Icons.restaurant;
      case 'sleep':
        return Icons.hotel;
      case 'hydration':
        return Icons.local_drink;
      default:
        return Icons.alarm;
    }
  }
}
