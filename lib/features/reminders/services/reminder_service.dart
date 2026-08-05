import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../backend/data/firestore_reminder_service.dart';
import '../../backend/repositories/reminder_repository.dart';
import '../models/reminder_model.dart';

class ReminderService {
  ReminderService._private() {
    _init();
  }
  static final ReminderService instance = ReminderService._private();

  final List<ReminderModel> _reminders = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ReminderRepository _repo = FirestoreReminderService();
  StreamSubscription<List<ReminderModel>>? _sub;

  void _init() {
    _auth.authStateChanges().listen((user) {
      _sub?.cancel();
      _reminders.clear();
      if (user != null) {
        _sub = _repo.streamForUser(user.uid).listen((list) {
          _reminders
            ..clear()
            ..addAll(list);
        });
      } else {
        initMock();
      }
    });
  }

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

  Future<void> add(ReminderModel r) async {
    if (r.title.trim().isEmpty) throw ArgumentError('Title required');
    _reminders.add(r);
    final user = _auth.currentUser;
    if (user != null) await _repo.add(user.uid, r);
  }

  Future<void> update(ReminderModel r) async {
    final i = _reminders.indexWhere((e) => e.id == r.id);
    if (i >= 0) _reminders[i] = r;
    final user = _auth.currentUser;
    if (user != null) await _repo.update(user.uid, r);
  }

  Future<void> delete(String id) async {
    _reminders.removeWhere((r) => r.id == id);
    final user = _auth.currentUser;
    if (user != null) await _repo.delete(user.uid, id);
  }

  void toggleComplete(String id) async {
    final i = _reminders.indexWhere((r) => r.id == id);
    if (i >= 0) {
      _reminders[i] = _reminders[i].copyWith(
        completed: !_reminders[i].completed,
      );
      final user = _auth.currentUser;
      if (user != null) await _repo.update(user.uid, _reminders[i]);
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
