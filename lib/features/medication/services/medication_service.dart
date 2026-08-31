import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../backend/data/firestore_medication_service.dart';
import '../../backend/repositories/medication_repository.dart';
import '../models/medication_model.dart';

class MedicationService {
  MedicationService._private() {
    _init();
  }

  static final MedicationService instance = MedicationService._private();

  final List<MedicationModel> _store = [];

  // track taken state per medication per date+time key
  final Set<String> _takenKeys = <String>{};

  final MedicationRepository _repo = FirestoreMedicationService();
  StreamSubscription<List<MedicationModel>>? _sub;

  final StreamController<List<MedicationModel>> _streamController =
      StreamController<List<MedicationModel>>.broadcast();

  Stream<List<MedicationModel>> get stream => _streamController.stream;

  void _notify() {
    _streamController.add(List.unmodifiable(_store));
  }

  void _init() {
    try {
      FirebaseAuth.instance.authStateChanges().listen((user) {
        _sub?.cancel();
        _store.clear();
        if (user != null) {
          _sub = _repo.streamForUser(user.uid).listen((list) {
            _store
              ..clear()
              ..addAll(list);
            _notify();
          });
        } else {
          _initFallback();
        }
      });
    } catch (e) {
      debugPrint('[MedicationService] FirebaseAuth init skipped: $e');
      _initFallback();
    }
  }

  void _initFallback() {
    if (_store.isEmpty) {
      _store.addAll([
        MedicationModel(
          id: 'med1',
          name: 'Vitamin D',
          dosage: '1000 IU',
          type: 'Tablet',
          frequency: 'Once',
          times: [const TimeOfDay(hour: 10, minute: 0)],
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
          times: [const TimeOfDay(hour: 8, minute: 0)],
          foodInstruction: 'Anytime',
          notes: 'Monitor blood pressure',
          startDate: DateTime.now().subtract(const Duration(days: 2)),
          endDate: DateTime.now().add(const Duration(days: 365)),
          isReminderEnabled: true,
        ),
      ]);
      _notify();
    }
  }

  List<MedicationModel> getAll() => List.unmodifiable(_store);

  List<MedicationModel> getActiveForDate(DateTime date) {
    final target = DateTime(date.year, date.month, date.day);
    return _store.where((m) {
      final start = DateTime(
        m.startDate.year,
        m.startDate.month,
        m.startDate.day,
      );
      final end = DateTime(m.endDate.year, m.endDate.month, m.endDate.day);
      return !target.isBefore(start) && !target.isAfter(end);
    }).toList();
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
    _notify();
  }

  Future<void> addMedication(MedicationModel med) async {
    if (med.name.trim().isEmpty ||
        med.dosage.trim().isEmpty ||
        med.times.isEmpty) {
      throw ArgumentError(
        'Medicine name, dosage and at least one timing are required',
      );
    }
    _store.add(med);
    _notify();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _repo.add(user.uid, med);
      }
    } catch (_) {}
  }

  Future<void> updateMedication(String id, MedicationModel updated) async {
    final idx = _store.indexWhere((m) => m.id == id);
    if (idx >= 0) _store[idx] = updated;
    _notify();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _repo.update(user.uid, updated);
      }
    } catch (_) {}
  }

  Future<void> deleteMedication(String id) async {
    _store.removeWhere((m) => m.id == id);
    _notify();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _repo.delete(user.uid, id);
      }
    } catch (_) {}
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
  String _timeKey(TimeOfDay t) => '${t.hour}:${t.minute}';
}
