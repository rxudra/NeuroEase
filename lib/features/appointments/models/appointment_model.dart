import 'package:flutter/material.dart';

class AppointmentModel {
  AppointmentModel({
    required this.id,
    required this.doctorName,
    required this.hospitalName,
    this.specialty = '',
    required this.appointmentDate,
    required this.appointmentTime,
    this.notes = '',
    this.location = '',
    this.isCompleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  final String id;
  String doctorName;
  String hospitalName;
  String specialty;
  DateTime appointmentDate;
  TimeOfDay appointmentTime;
  String notes;
  String location;
  bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'doctorName': doctorName,
    'hospitalName': hospitalName,
    'specialty': specialty,
    'appointmentDate': appointmentDate.toIso8601String(),
    'appointmentTime': '${appointmentTime.hour}:${appointmentTime.minute}',
    'notes': notes,
    'location': location,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  static AppointmentModel fromJson(Map<String, dynamic> m) {
    DateTime parseDate(dynamic v) {
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      if (v is DateTime) return v;
      return DateTime.now();
    }

    TimeOfDay parseTime(dynamic v) {
      if (v is String) {
        final parts = v.split(':');
        final h = int.tryParse(parts[0]) ?? 0;
        final mm = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
        return TimeOfDay(hour: h, minute: mm);
      }
      if (v is TimeOfDay) return v;
      return const TimeOfDay(hour: 0, minute: 0);
    }

    return AppointmentModel(
      id: m['id'] as String? ?? '',
      doctorName: m['doctorName'] as String? ?? '',
      hospitalName: m['hospitalName'] as String? ?? '',
      specialty: m['specialty'] as String? ?? '',
      appointmentDate: parseDate(m['appointmentDate']),
      appointmentTime: parseTime(m['appointmentTime']),
      notes: m['notes'] as String? ?? '',
      location: m['location'] as String? ?? '',
      isCompleted: m['isCompleted'] as bool? ?? false,
      createdAt: parseDate(
        m['createdAt'] ?? m['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: parseDate(
        m['updatedAt'] ?? m['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
