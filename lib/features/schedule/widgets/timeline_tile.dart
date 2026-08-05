import 'package:flutter/material.dart';
import '../models/schedule_task.dart';

class TimelineTile extends StatelessWidget {
  const TimelineTile({required this.task, super.key});

  final ScheduleTask task;

  @override
  Widget build(BuildContext context) {
    final color = Color(task.colorValue);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            task.time.format(context),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Container(
          width: 12,
          alignment: Alignment.topCenter,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (task.description.isNotEmpty) Text(task.description),
            ],
          ),
        ),
      ],
    );
  }
}
