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
    'dosage': dosage,
    'unit': type,
    'frequency': frequency,
    'timing': times
        .map(
          (t) =>
              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
        )
        .toList(),
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'instructions': notes,
    'reminderEnabled': isReminderEnabled,
    'color': 0,
    'createdAt': createdAt.toIso8601String(),
  };

  static MedicationModel fromMap(Map<String, dynamic> m) {
    List<TimeOfDay> parseTimes(List<dynamic>? arr) {
      if (arr == null) return [];
      return arr.map((e) {
        final s = e as String;
        final parts = s.split(':');
        final h = int.tryParse(parts[0]) ?? 0;
        final mm = int.tryParse(parts[1]) ?? 0;
        return TimeOfDay(hour: h, minute: mm);
      }).toList();
    }

    return MedicationModel(
      id: m['id'] as String? ?? '',
      name: m['medicineName'] as String? ?? '',
      dosage: m['dosage'] as String? ?? '',
      type: m['unit'] as String? ?? '',
      frequency: m['frequency'] as String? ?? '',
      times: parseTimes(m['timing'] as List?),
      foodInstruction: m['foodInstruction'] as String? ?? '',
      notes: m['instructions'] as String? ?? '',
      startDate:
          DateTime.tryParse(m['startDate'] as String? ?? '') ?? DateTime.now(),
      endDate:
          DateTime.tryParse(m['endDate'] as String? ?? '') ?? DateTime.now(),
      isReminderEnabled: m['reminderEnabled'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
