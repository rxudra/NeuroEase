import 'package:flutter/material.dart';
import '../services/reminder_service.dart';
import '../widgets/section_header.dart';
import '../widgets/reminder_progress_card.dart';
import '../widgets/reminder_card.dart';
import '../widgets/reminder_timeline.dart';
import '../widgets/empty_state.dart';
import 'add_reminder_screen.dart';
import 'reminder_detail_screen.dart';

class ReminderHomeScreen extends StatefulWidget {
  const ReminderHomeScreen({super.key});

  @override
  State<ReminderHomeScreen> createState() => _ReminderHomeScreenState();
}

class _ReminderHomeScreenState extends State<ReminderHomeScreen> {
  final DateTime _selected = DateTime.now();

  @override
  void initState() {
    super.initState();
    ReminderService.instance.initMock();
  }

  @override
  Widget build(BuildContext context) {
    final reminders = ReminderService.instance.getForDate(_selected);
    final upcoming = ReminderService.instance.getUpcoming(3);
    final completion = ReminderService.instance.completionPercentForDate(
      _selected,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAdd(context),
        label: const Text('Add Reminder'),
        icon: const Icon(Icons.add),
      ),
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
            Text('Reminders', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            ReminderProgressCard(percent: completion),
            const SizedBox(height: 12),
            SectionHeader(
              title: "Today's Reminders",
              actionLabel: 'Add',
              onAction: () => _openAdd(context),
            ),
            const SizedBox(height: 8),
            if (reminders.isEmpty)
              const EmptyState(
                title: 'No reminders for today',
                subtitle: 'Add a reminder to get started',
              )
            else
              Column(
                children: reminders
                    .map(
                      (r) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: ReminderCard(
                          reminder: r,
                          onTap: () => _openDetails(context, r.id),
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
            if (upcoming.isEmpty)
              const EmptyState(title: 'No upcoming reminders')
            else
              Column(
                children: upcoming
                    .map(
                      (r) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: ReminderCard(
                          reminder: r,
                          onTap: () => _openDetails(context, r.id),
                        ),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 12),
            SectionHeader(title: 'History'),
            const SizedBox(height: 8),
            ReminderTimeline(reminders: ReminderService.instance.getAll()),
          ],
        ),
      ),
    );
  }

  void _openAdd(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddReminderScreen()),
    );
    if (mounted) setState(() {});
  }

  void _openDetails(BuildContext context, String id) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReminderDetailScreen(reminderId: id)),
    );
    if (mounted) setState(() {});
  }
}

