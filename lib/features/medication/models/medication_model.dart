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
}
