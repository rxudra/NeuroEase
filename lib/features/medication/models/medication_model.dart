import 'package:flutter/material.dart';

class MedicationModel {
  MedicationModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.type,
    required this.frequency,
    required this.times,
    required this.foodInstruction,
    required this.notes,
    required this.startDate,
    required this.endDate,
    required this.isReminderEnabled,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String name;
  final String dosage;
  final String type;
  final String frequency;
  final List<TimeOfDay> times;
  final String foodInstruction;
  final String notes;
  final DateTime startDate;
  final DateTime endDate;
  final bool isReminderEnabled;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'medicineName': name,
    'name': name,
    'dosage': dosage,
    'unit': type,
    'type': type,
    'frequency': frequency,
    'timing': times
        .map(
          (t) =>
              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
        )
        .toList(),
    'foodInstruction': foodInstruction,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'instructions': notes,
    'notes': notes,
    'reminderEnabled': isReminderEnabled,
    'color': 0,
    'createdAt': createdAt.toIso8601String(),
  };

  static MedicationModel fromMap(Map<String, dynamic> m) {
    List<TimeOfDay> parseTimes(List<dynamic>? arr) {
      if (arr == null) return [];
      return arr.map((e) {
        final s = e.toString();
        final parts = s.split(':');
        final h = int.tryParse(parts[0]) ?? 0;
        final mm = int.tryParse(parts[1]) ?? 0;
        return TimeOfDay(hour: h, minute: mm);
      }).toList();
    }

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

    final parsedTimes = parseTimes(m['timing'] as List? ?? m['times'] as List?);
    return MedicationModel(
      id: m['id'] as String? ?? '',
      name: (m['medicineName'] ?? m['name']) as String? ?? '',
      dosage: m['dosage'] as String? ?? '',
      type: (m['unit'] ?? m['type']) as String? ?? '',
      frequency: m['frequency'] as String? ?? '',
      times: parsedTimes,
      foodInstruction: (m['foodInstruction'] ?? m['food']) as String? ?? '',
      notes: (m['instructions'] ?? m['notes']) as String? ?? '',
      startDate: parseDate(m['startDate']),
      endDate: parseDate(m['endDate']),
      isReminderEnabled: m['reminderEnabled'] as bool? ?? false,
      createdAt: parseDate(m['createdAt']),
    );
  }
}
