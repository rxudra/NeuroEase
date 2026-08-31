import 'dart:async';
import 'package:flutter/material.dart';

import '../../profile/services/profile_service.dart';
import '../models/schedule_task.dart';
import '../services/schedule_service.dart';
import '../widgets/completion_progress.dart';
import '../widgets/empty_state.dart';
import '../widgets/month_calendar.dart';
import '../widgets/schedule_card.dart';
import '../widgets/section_header.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';

class ScheduleHomeScreen extends StatefulWidget {
  const ScheduleHomeScreen({super.key});

  @override
  State<ScheduleHomeScreen> createState() => _ScheduleHomeScreenState();
}

class _ScheduleHomeScreenState extends State<ScheduleHomeScreen> {
  DateTime _selected = DateTime.now();
  StreamSubscription<List<ScheduleTask>>? _scheduleSub;

  @override
  void initState() {
    super.initState();
    ScheduleService.instance.initMock();
    ProfileService.instance.initMock();
    _scheduleSub = ScheduleService.instance.stream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _scheduleSub?.cancel();
    super.dispose();
  }

  void _openAdd(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddTaskScreen()));
  }

  void _openDetails(BuildContext context, String id) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: id)));
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ScheduleService.instance.getTasksForDate(_selected);
    final upcoming = ScheduleService.instance.getUpcoming(3);
    final completion = ScheduleService.instance.completionForDate(_selected);

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule & Reminders')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date • ${_selected.toLocal().toIso8601String().split('T').first}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Daily Schedule Overview',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            CompletionProgress(percent: completion),
            const SizedBox(height: 12),
            MonthCalendar(onDaySelected: (d) => setState(() => _selected = d)),
            const SizedBox(height: 12),
            SectionHeader(
              title: "Today's Schedule",
              actionLabel: '+ Add Task',
              onAction: () => _openAdd(context),
            ),
            const SizedBox(height: 8),
            if (tasks.isEmpty)
              const EmptyState(
                title: 'No tasks scheduled for this day',
                subtitle: 'Tap + Add Task to create a reminder',
              )
            else
              Column(
                children: tasks
                    .map(
                      (t) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: ScheduleCard(
                          task: t,
                          onTap: () => _openDetails(context, t.id),
                        ),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 16),
            SectionHeader(title: 'Upcoming Reminders'),
            const SizedBox(height: 8),
            if (upcoming.isEmpty)
              const EmptyState(title: 'No upcoming reminders')
            else
              Column(
                children: upcoming
                    .map(
                      (t) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: const Icon(Icons.calendar_today_outlined),
                          title: Text(t.title),
                          subtitle: Text(
                            '${t.time.format(context)} • ${t.category}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openDetails(context, t.id),
                        ),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAdd(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}
