import 'package:flutter/material.dart';
import '../models/reminder_model.dart';

class ReminderService {
  ReminderService._private();
  static final ReminderService instance = ReminderService._private();

  final List<ReminderModel> _reminders = [];

  void initMock() {
    if (_reminders.isNotEmpty) return;
    final now = DateTime.now();
    _reminders.addAll([
      ReminderModel(
        id: 'r1',
        title: 'Take Amlodipine',
        description: 'Post breakfast',
        category: 'Medication',
        date: DateTime(now.year, now.month, now.day),
        time: const TimeOfDay(hour: 8, minute: 30),
        repeat: RepeatOption.daily,
        priority: ReminderPriority.high,
        completed: false,
        enabled: true,
        notificationEnabled: true,
        sound: 'default',
        vibration: true,
        notes: '',
        colorValue: Colors.blue.toARGB32(),
      ),
      ReminderModel(
        id: 'r2',
        title: 'Doctor appointment',
        description: 'Cardiology',
        category: 'Doctor Visit',
        date: DateTime(now.year, now.month, now.day + 1),
        time: const TimeOfDay(hour: 11, minute: 0),
        repeat: RepeatOption.once,
        priority: ReminderPriority.high,
        completed: false,
        enabled: true,
        notificationEnabled: true,
        sound: 'chime',
        vibration: true,
        notes: 'Bring medical reports',
        colorValue: Colors.orange.toARGB32(),
      ),
    ]);
  }

  List<ReminderModel> getAll() => List.unmodifiable(_reminders);

  List<ReminderModel> getForDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return _reminders
        .where((r) => DateTime(r.date.year, r.date.month, r.date.day) == d)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<ReminderModel> getUpcoming(int count) {
    final now = DateTime.now();
    final list = _reminders.where((r) => r.dateTime.isAfter(now)).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list.take(count).toList();
  }

  void add(ReminderModel r) => _reminders.add(r);

  void update(ReminderModel r) {
    final i = _reminders.indexWhere((e) => e.id == r.id);
    if (i >= 0) {
      _reminders[i] = r;
    }
  }

  void delete(String id) => _reminders.removeWhere((r) => r.id == id);

  void toggleComplete(String id) {
    final i = _reminders.indexWhere((r) => r.id == id);
    if (i >= 0) {
      _reminders[i] = _reminders[i].copyWith(
        completed: !_reminders[i].completed,
      );
    }
  }

  double completionPercentForDate(DateTime date) {
    final list = getForDate(date);
    if (list.isEmpty) return 0.0;
    final done = list.where((r) => r.completed).length;
    return done / list.length;
  }

  double missedPercentForDate(DateTime date) {
    final list = getForDate(date);
    if (list.isEmpty) return 0.0;
    final missed = list
        .where((r) => !r.completed && r.dateTime.isBefore(DateTime.now()))
        .length;
    return missed / list.length;
  }
}
