import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import '../services/reminder_service.dart';
import 'add_reminder_screen.dart';

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
    _loadReminder();
  }

  void _loadReminder() {
    final list = ReminderService.instance.getAll();
    final idx = list.indexWhere((r) => r.id == widget.reminderId);
    if (idx >= 0) {
      _rem = list[idx];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_rem == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reminder details')),
        body: const Center(child: Text('Reminder not found')),
      );
    }
    final r = _rem!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder details'),
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

  Future<void> _edit() async {
    if (_rem == null) return;
    final updated = await Navigator.of(context).push<ReminderModel>(
      MaterialPageRoute(builder: (_) => AddReminderScreen(existing: _rem)),
    );
    if (updated != null && mounted) {
      setState(() => _rem = updated);
    }
  }

  void _toggleComplete() {
    ReminderService.instance.toggleComplete(widget.reminderId);
    if (mounted) {
      setState(() => _loadReminder());
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reminder?'),
        content: const Text('Are you sure you want to delete this reminder?'),
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
      await ReminderService.instance.delete(widget.reminderId);
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _skip() async {
    if (_rem != null) {
      await ReminderService.instance.update(_rem!.copyWith(completed: false));
      if (mounted) Navigator.of(context).pop();
    }
  }
}
