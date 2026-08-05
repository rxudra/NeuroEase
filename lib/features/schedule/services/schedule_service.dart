import 'package:flutter/material.dart';
import '../models/schedule_task.dart';

class ScheduleService {
  ScheduleService._private();
  static final ScheduleService instance = ScheduleService._private();

  final List<ScheduleTask> _tasks = [];

  void initMock() {
    if (_tasks.isNotEmpty) return;
    final now = DateTime.now();
    _tasks.addAll([
      ScheduleTask(
        id: 't1',
        title: 'Morning walk',
        description: 'Gentle 20 minute walk',
        category: 'Exercise',
        date: DateTime(now.year, now.month, now.day),
        time: const TimeOfDay(hour: 7, minute: 0),
        priority: Priority.low,
        colorValue: Colors.green.toARGB32(),
      ),
      ScheduleTask(
        id: 't2',
        title: 'Take Amlodipine',
        description: 'After breakfast',
        category: 'Medication',
        date: DateTime(now.year, now.month, now.day),
        time: const TimeOfDay(hour: 8, minute: 30),
        priority: Priority.high,
        colorValue: Colors.blue.toARGB32(),
      ),
      ScheduleTask(
        id: 't3',
        title: 'Doctor Visit',
        description: 'Cardiology follow-up',
        category: 'Doctor Visit',
        date: DateTime(now.year, now.month, now.day + 2),
        time: const TimeOfDay(hour: 11, minute: 0),
        priority: Priority.high,
        colorValue: Colors.orange.toARGB32(),
      ),
    ]);
  }

  List<ScheduleTask> getAll() => List.unmodifiable(_tasks);

  List<ScheduleTask> getTasksForDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return _tasks
        .where((t) => DateTime(t.date.year, t.date.month, t.date.day) == d)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<ScheduleTask> getUpcoming(int count) {
    final now = DateTime.now();
    final list = _tasks.where((t) => t.dateTime.isAfter(now)).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list.take(count).toList();
  }

  void addTask(ScheduleTask t) {
    _tasks.add(t);
  }

  void updateTask(ScheduleTask updated) {
    final idx = _tasks.indexWhere((t) => t.id == updated.id);
    if (idx >= 0) {
      _tasks[idx] = updated;
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
  }

  void toggleCompleted(String id) {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx >= 0) {
      _tasks[idx] = _tasks[idx].copyWith(completed: !_tasks[idx].completed);
    }
  }

  double completionForDate(DateTime date) {
    final tasks = getTasksForDate(date);
    if (tasks.isEmpty) return 0.0;
    final done = tasks.where((t) => t.completed).length;
    return done / tasks.length;
  }
}
