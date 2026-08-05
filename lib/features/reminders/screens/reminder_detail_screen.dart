import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import '../services/reminder_service.dart';

class ReminderDetailScreen extends StatefulWidget {
  const ReminderDetailScreen({required this.reminderId, super.key});

  final String reminderId;

  @override
  State<ReminderDetailScreen> createState() => _ReminderDetailScreenState();
}

class _ReminderDetailScreenState extends State<ReminderDetailScreen> {
  ReminderModel? _rem;

  @override
  void initState() {
    super.initState();
    _rem = ReminderService.instance.getAll().firstWhere(
      (r) => r.id == widget.reminderId,
      orElse: () => ReminderModel(
        id: 'na',
        title: 'Unknown',
        category: 'Custom',
        date: DateTime.now(),
        time: TimeOfDay.now(),
        colorValue: Colors.blue.toARGB32(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_rem == null) {
      return const Scaffold(body: Center(child: Text('Reminder not found')));
    }
    final r = _rem!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder details'),
        actions: [
          IconButton(onPressed: _delete, icon: const Icon(Icons.delete)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(r.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              '${r.date.toLocal().toIso8601String().split('T').first} • ${r.time.format(context)}',
            ),
            const SizedBox(height: 12),
            Text(r.description),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _toggleComplete,
                    child: Text(
                      r.completed ? 'Mark Incomplete' : 'Mark Completed',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _skip, child: const Text('Skip')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleComplete() {
    ReminderService.instance.toggleComplete(widget.reminderId);
    setState(
      () => _rem = ReminderService.instance.getAll().firstWhere(
        (r) => r.id == widget.reminderId,
      ),
    );
  }

  void _delete() {
    ReminderService.instance.delete(widget.reminderId);
    Navigator.of(context).pop();
  }

  void _skip() {
    ReminderService.instance.update(_rem!.copyWith(completed: false));
    Navigator.of(context).pop();
  }
}
