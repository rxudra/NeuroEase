import 'package:flutter/material.dart';

enum RepeatType { none, daily, weekly, monthly }

enum Priority { low, medium, high }

class ScheduleTask {
  ScheduleTask({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.date,
    required this.time,
    this.repeat = RepeatType.none,
    this.priority = Priority.medium,
    this.completed = false,
    required this.colorValue,
    this.notificationEnabled = true,
  });

  final String id;
  String title;
  String description;
  String category;
  DateTime date; // date part
  TimeOfDay time; // time part
  RepeatType repeat;
  Priority priority;
  bool completed;
  int colorValue;
  bool notificationEnabled;

  DateTime get dateTime =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  ScheduleTask copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    DateTime? date,
    TimeOfDay? time,
    RepeatType? repeat,
    Priority? priority,
    bool? completed,
    int? colorValue,
    bool? notificationEnabled,
  }) {
    return ScheduleTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      time: time ?? this.time,
      repeat: repeat ?? this.repeat,
      priority: priority ?? this.priority,
      completed: completed ?? this.completed,
      colorValue: colorValue ?? this.colorValue,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'date': date.toIso8601String(),
    'time': '${time.hour}:${time.minute}',
    'repeat': repeat.index,
    'priority': priority.index,
    'completed': completed,
    'colorValue': colorValue,
    'notificationEnabled': notificationEnabled,
  };

  static ScheduleTask fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      try {
        final dynamic t = val;
        return t.toDate() as DateTime;
      } catch (_) {
        return DateTime.now();
      }
    }

    final d = parseDate(json['date']);
    final timeStr = (json['time'] as String? ?? '10:00');
    final parts = timeStr.split(':');
    final h = parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 10) : 10;
    final mm = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    return ScheduleTask(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      date: d,
      time: TimeOfDay(hour: h, minute: mm),
      repeat: RepeatType.values[(json['repeat'] as int?) ?? 0],
      priority: Priority.values[(json['priority'] as int?) ?? 1],
      completed: json['completed'] as bool? ?? false,
      colorValue: json['colorValue'] as int? ?? Colors.blue.toARGB32(),
      notificationEnabled: json['notificationEnabled'] as bool? ?? true,
    );
  }
}
