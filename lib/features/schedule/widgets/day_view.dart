import 'package:flutter/material.dart';
import '../models/schedule_task.dart';
import 'timeline_tile.dart';

class DayView extends StatelessWidget {
  const DayView({required this.tasks, super.key});

  final List<ScheduleTask> tasks;

  @override
  Widget build(BuildContext context) {
    final hours = List.generate(17, (i) => 6 + i); // 6AM - 10PM
    return Column(
      children: hours.map((h) {
        final hourTasks = tasks.where((t) => t.time.hour == h).toList();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$h:00', style: Theme.of(context).textTheme.labelSmall),
              ...hourTasks.map((t) => TimelineTile(task: t)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
