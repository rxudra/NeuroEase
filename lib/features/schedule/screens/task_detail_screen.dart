import 'package:flutter/material.dart';
import '../models/schedule_task.dart';
import '../services/schedule_service.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({required this.taskId, super.key});

  final String taskId;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  ScheduleTask? _task;

  @override
  void initState() {
    super.initState();
    _task = ScheduleService.instance.getAll().firstWhere(
      (t) => t.id == widget.taskId,
      orElse: () => ScheduleTask(
        id: 'na',
        title: 'Unknown',
        category: 'Personal',
        date: DateTime.now(),
        time: TimeOfDay.now(),
        colorValue: Colors.blue.toARGB32(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_task == null) {
      return const Scaffold(body: Center(child: Text('Task not found')));
    }
    final t = _task!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task details'),
        actions: [
          IconButton(onPressed: _delete, icon: const Icon(Icons.delete)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('${t.time.format(context)} • ${t.category}'),
            const SizedBox(height: 12),
            Text(t.description),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _toggleComplete,
                    child: Text(
                      t.completed ? 'Mark Incomplete' : 'Mark Completed',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _markMissed,
                  child: const Text('Mark Missed'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleComplete() {
    ScheduleService.instance.toggleCompleted(widget.taskId);
    setState(
      () => _task = ScheduleService.instance.getAll().firstWhere(
        (t) => t.id == widget.taskId,
      ),
    );
  }

  void _delete() {
    ScheduleService.instance.deleteTask(widget.taskId);
    Navigator.of(context).pop();
  }

  void _markMissed() {
    ScheduleService.instance.updateTask(_task!.copyWith(completed: false));
    Navigator.of(context).pop();
  }
}
