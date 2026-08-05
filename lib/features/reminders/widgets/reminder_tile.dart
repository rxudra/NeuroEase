import 'package:flutter/material.dart';
import '../models/reminder_model.dart';

class ReminderTile extends StatelessWidget {
  const ReminderTile({required this.reminder, super.key});

  final ReminderModel reminder;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            reminder.time.format(context),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reminder.title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (reminder.description.isNotEmpty) Text(reminder.description),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (reminder.completed)
          const Icon(Icons.check_circle, color: Colors.green),
      ],
    );
  }
}
