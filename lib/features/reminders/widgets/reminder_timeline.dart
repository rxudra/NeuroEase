import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import 'reminder_tile.dart';

class ReminderTimeline extends StatelessWidget {
  const ReminderTimeline({required this.reminders, super.key});

  final List<ReminderModel> reminders;

  @override
  Widget build(BuildContext context) {
    if (reminders.isEmpty) return const SizedBox();
    return Column(
      children: reminders
          .map(
            (r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ReminderTile(reminder: r),
            ),
          )
          .toList(),
    );
  }
}
