import 'package:flutter/material.dart';

enum RepeatOption {
  once,
  daily,
  weekdays,
  weekends,
  weekly,
  monthly,
  yearly,
  custom,
}

enum ReminderPriority { low, medium, high }

class ReminderModel {
  ReminderModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.date,
    required this.time,
    this.repeat = RepeatOption.once,
    this.priority = ReminderPriority.medium,
    this.enabled = true,
    this.completed = false,
    this.notificationEnabled = true,
    this.sound = 'default',
    this.vibration = true,
    this.notes = '',
    required this.colorValue,
  });

  final String id;
  String title;
  String description;
  String category;
  DateTime date;
  TimeOfDay time;
  RepeatOption repeat;
  ReminderPriority priority;
  bool enabled;
  bool completed;
  bool notificationEnabled;
  String sound;
  bool vibration;
  String notes;
  int colorValue;

  DateTime get dateTime =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  ReminderModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    DateTime? date,
    TimeOfDay? time,
    RepeatOption? repeat,
    ReminderPriority? priority,
    bool? enabled,
    bool? completed,
    bool? notificationEnabled,
    String? sound,
    bool? vibration,
    String? notes,
    int? colorValue,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      time: time ?? this.time,
      repeat: repeat ?? this.repeat,
      priority: priority ?? this.priority,
      enabled: enabled ?? this.enabled,
      completed: completed ?? this.completed,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      sound: sound ?? this.sound,
      vibration: vibration ?? this.vibration,
      notes: notes ?? this.notes,
      colorValue: colorValue ?? this.colorValue,
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
    'enabled': enabled,
    'completed': completed,
    'notificationEnabled': notificationEnabled,
    'sound': sound,
    'vibration': vibration,
    'notes': notes,
    'colorValue': colorValue,
  };

  static ReminderModel fromJson(Map<String, dynamic> json) {
    final d = DateTime.parse(json['date'] as String);
    final parts = (json['time'] as String).split(':');
    return ReminderModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Custom',
      date: d,
      time: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
      repeat: RepeatOption.values[(json['repeat'] as int?) ?? 0],
      priority: ReminderPriority.values[(json['priority'] as int?) ?? 1],
      enabled: json['enabled'] as bool? ?? true,
      completed: json['completed'] as bool? ?? false,
      notificationEnabled: json['notificationEnabled'] as bool? ?? true,
      sound: json['sound'] as String? ?? 'default',
      vibration: json['vibration'] as bool? ?? true,
      notes: json['notes'] as String? ?? '',
      colorValue: json['colorValue'] as int? ?? Colors.blue.toARGB32(),
    );
  }
}
