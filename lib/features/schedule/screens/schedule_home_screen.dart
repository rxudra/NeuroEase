import 'package:flutter/material.dart';
import '../../profile/services/profile_service.dart';
import '../services/schedule_service.dart';
import '../widgets/month_calendar.dart';
import '../widgets/completion_progress.dart';
import '../widgets/section_header.dart';
import '../widgets/schedule_card.dart';
import '../widgets/quick_action_tile.dart';
import '../widgets/empty_state.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';

class ScheduleHomeScreen extends StatefulWidget {
  const ScheduleHomeScreen({super.key});

  @override
  State<ScheduleHomeScreen> createState() => _ScheduleHomeScreenState();
}

class _ScheduleHomeScreenState extends State<ScheduleHomeScreen> {
  DateTime _selected = DateTime.now();

  @override
  void initState() {
    super.initState();
    ScheduleService.instance.initMock();
    ProfileService.instance.initMock();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ScheduleService.instance.getTasksForDate(_selected);
    final upcoming = ScheduleService.instance.getUpcoming(3);
    final completion = ScheduleService.instance.completionForDate(_selected);

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today • ${_selected.toLocal().toIso8601String().split('T').first}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Good morning',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            CompletionProgress(percent: completion),
            const SizedBox(height: 12),
            MonthCalendar(onDaySelected: (d) => setState(() => _selected = d)),
            const SizedBox(height: 12),
            SectionHeader(
              title: "Today's Schedule",
              actionLabel: 'Add',
              onAction: () => _openAdd(context),
            ),
            const SizedBox(height: 8),
            if (tasks.isEmpty)
              const EmptyState(
                title: 'No tasks for today',
                subtitle: 'Tap Quick Add to create one',
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
            const SizedBox(height: 12),
            SectionHeader(
              title: 'Upcoming',
              actionLabel: 'View all',
              onAction: () {},
            ),
            const SizedBox(height: 8),
            Column(
              children: upcoming
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
            const SizedBox(height: 12),
            SectionHeader(title: 'Quick Add'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                QuickActionTile(
                  icon: Icons.medication,
                  label: 'Medication',
                  onTap: () => _openAdd(context, prefill: 'Medication'),
                ),
                QuickActionTile(
                  icon: Icons.local_hospital,
                  label: 'Appointment',
                  onTap: () => _openAdd(context, prefill: 'Doctor Visit'),
                ),
                QuickActionTile(
                  icon: Icons.task,
                  label: 'Task',
                  onTap: () => _openAdd(context, prefill: 'Personal'),
                ),
                QuickActionTile(
                  icon: Icons.local_drink,
                  label: 'Water',
                  onTap: () => _openAdd(context, prefill: 'Hydration'),
                ),
                QuickActionTile(
                  icon: Icons.fitness_center,
                  label: 'Exercise',
                  onTap: () => _openAdd(context, prefill: 'Exercise'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openAdd(BuildContext context, {String? prefill}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddTaskScreen(prefillCategory: prefill),
      ),
    );
    if (mounted) setState(() {});
  }

  void _openDetails(BuildContext context, String id) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: id)),
    );
    if (mounted) setState(() {});
  }
}

