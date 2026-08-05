import 'package:flutter/material.dart';
import '../../../core/widgets/app_cards.dart';
import '../services/schedule_service.dart';

class MonthCalendar extends StatefulWidget {
  const MonthCalendar({super.key, required this.onDaySelected});

  final ValueChanged<DateTime> onDaySelected;

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  DateTime _display = DateTime.now();

  @override
  void initState() {
    super.initState();
    ScheduleService.instance.initMock();
  }

  void _prev() =>
      setState(() => _display = DateTime(_display.year, _display.month - 1));
  void _next() =>
      setState(() => _display = DateTime(_display.year, _display.month + 1));

  @override
  Widget build(BuildContext context) {
    final first = DateTime(_display.year, _display.month, 1);
    final startWeekday = first.weekday % 7; // Sunday=0
    final daysInMonth = DateTime(_display.year, _display.month + 1, 0).day;
    final cells = <DateTime>[];
    for (var i = 0; i < startWeekday; i++) {
      cells.add(first.subtract(Duration(days: startWeekday - i)));
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(_display.year, _display.month, d));
    }

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _prev,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Center(
                  child: Text('${_display.month}/${_display.year}'),
                ),
              ),
              IconButton(
                onPressed: _next,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.1,
            ),
            itemCount: cells.length,
            itemBuilder: (context, idx) {
              final d = cells[idx];
              final isToday =
                  DateTime.now().year == d.year &&
                  DateTime.now().month == d.month &&
                  DateTime.now().day == d.day;
              final hasTasks = ScheduleService.instance
                  .getTasksForDate(d)
                  .isNotEmpty;
              final completedAll =
                  hasTasks &&
                  ScheduleService.instance.completionForDate(d) >= 1.0;
              final missed =
                  hasTasks &&
                  ScheduleService.instance.completionForDate(d) == 0.0 &&
                  d.isBefore(DateTime.now());
              return GestureDetector(
                onTap: () => widget.onDaySelected(d),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isToday
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      Center(child: Text('${d.day}')),
                      if (hasTasks)
                        Positioned(
                          bottom: 6,
                          right: 6,
                          child: Icon(
                            completedAll
                                ? Icons.check_circle
                                : missed
                                ? Icons.error_outline
                                : Icons.circle,
                            size: 12,
                            color: hasTasks
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
