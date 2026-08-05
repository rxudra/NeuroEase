import 'package:flutter/material.dart';
import '../models/medication_model.dart';

class MedicationService {
  MedicationService._private();
  static final MedicationService instance = MedicationService._private();

  final List<MedicationModel> _store = [
    MedicationModel(
      id: 'med1',
      name: 'Vitamin D',
      dosage: '1000 IU',
      type: 'Tablet',
      frequency: 'Once',
      times: [TimeOfDay(hour: 10, minute: 0)],
      foodInstruction: 'After food',
      notes: 'Take with breakfast',
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      endDate: DateTime.now().add(const Duration(days: 20)),
      isReminderEnabled: true,
    ),
    MedicationModel(
      id: 'med2',
      name: 'Amlodipine',
      dosage: '5 mg',
      type: 'Tablet',
      frequency: 'Once',
      times: [TimeOfDay(hour: 8, minute: 0)],
      foodInstruction: 'Anytime',
      notes: 'Monitor blood pressure',
      startDate: DateTime.now().subtract(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 365)),
      isReminderEnabled: true,
    ),
  ];

  // track taken state per medication per date+time key
  final Set<String> _takenKeys = <String>{};

  List<MedicationModel> getAll() => List.unmodifiable(_store);

  List<MedicationModel> getActiveForDate(DateTime date) {
    return _store
        .where(
          (m) => !_isBefore(date, m.endDate) && !_isAfter(date, m.startDate),
        )
        .toList();
  }

  List<MedicationModel> getUpcomingForDate(DateTime date) =>
      getActiveForDate(date);

  List<MedicationModel> getCompletedToday(DateTime date) {
    final dayKey = _dateKey(date);
    return _store
        .where(
          (m) => m.times.any(
            (t) => _takenKeys.contains('${m.id}|$dayKey|${_timeKey(t)}'),
          ),
        )
        .toList();
  }

  List<MedicationModel> getMissedForDate(DateTime date) {
    // for mock: none missed
    return <MedicationModel>[];
  }

  bool isTaken(MedicationModel med, TimeOfDay time, DateTime date) {
    return _takenKeys.contains('${med.id}|${_dateKey(date)}|${_timeKey(time)}');
  }

  void toggleTaken(MedicationModel med, TimeOfDay time, DateTime date) {
    final key = '${med.id}|${_dateKey(date)}|${_timeKey(time)}';
    if (_takenKeys.contains(key)) {
      _takenKeys.remove(key);
    } else {
      _takenKeys.add(key);
    }
  }

  void addMedication(MedicationModel med) => _store.add(med);

  void updateMedication(String id, MedicationModel updated) {
    final idx = _store.indexWhere((m) => m.id == id);
    if (idx >= 0) _store[idx] = updated;
  }

  void deleteMedication(String id) => _store.removeWhere((m) => m.id == id);

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
  String _timeKey(TimeOfDay t) => '${t.hour}:${t.minute}';

  bool _isBefore(DateTime a, DateTime b) => a.isBefore(b);
  bool _isAfter(DateTime a, DateTime b) => a.isAfter(b);
}
