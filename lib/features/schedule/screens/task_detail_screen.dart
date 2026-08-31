import 'package:flutter/material.dart';
import '../models/schedule_task.dart';
import '../services/schedule_service.dart';
import 'add_task_screen.dart';

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
    _loadTask();
  }

  void _loadTask() {
    final list = ScheduleService.instance.getAll();
    final idx = list.indexWhere((t) => t.id == widget.taskId);
    if (idx >= 0) {
      _task = list[idx];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task details')),
        body: const Center(child: Text('Task not found')),
      );
    }
    final t = _task!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task details'),
        actions: [
          IconButton(onPressed: _edit, icon: const Icon(Icons.edit)),
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

  Future<void> _edit() async {
    if (_task == null) return;
    final updated = await Navigator.of(context).push<ScheduleTask>(
      MaterialPageRoute(builder: (_) => AddTaskScreen(existing: _task)),
    );
    if (updated != null && mounted) {
      setState(() => _task = updated);
    }
  }

  Future<void> _toggleComplete() async {
    await ScheduleService.instance.toggleCompleted(widget.taskId);
    if (mounted) {
      setState(() => _loadTask());
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task?'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ScheduleService.instance.deleteTask(widget.taskId);
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _markMissed() async {
    if (_task != null) {
      await ScheduleService.instance.updateTask(
        _task!.copyWith(completed: false),
      );
      if (mounted) Navigator.of(context).pop();
    }
  }
}
