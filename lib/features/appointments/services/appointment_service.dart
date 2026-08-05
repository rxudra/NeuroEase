import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
// no Flutter UI imports required in this service

import '../../backend/data/firestore_appointment_service.dart';
import '../../backend/repositories/appointment_repository.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  AppointmentService._private() {
    _init();
  }

  static final AppointmentService instance = AppointmentService._private();

  final List<AppointmentModel> _store = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AppointmentRepository _repo = FirestoreAppointmentService();
  StreamSubscription<List<AppointmentModel>>? _sub;

  void _init() {
    _auth.authStateChanges().listen((user) {
      _sub?.cancel();
      _store.clear();
      if (user != null) {
        _sub = _repo.streamForUser(user.uid).listen((list) {
          _store
            ..clear()
            ..addAll(list);
        });
      }
    });
  }

  List<AppointmentModel> getAll() => List.unmodifiable(_store);

  List<AppointmentModel> getForDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return _store
        .where(
          (a) =>
              DateTime(
                a.appointmentDate.year,
                a.appointmentDate.month,
                a.appointmentDate.day,
              ) ==
              d,
        )
        .toList()
      ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
  }

  Future<void> add(AppointmentModel a) async {
    if (a.doctorName.trim().isEmpty) {
      throw ArgumentError('Doctor name required');
    }
    _store.add(a);
    final user = _auth.currentUser;
    if (user != null) {
      await _repo.add(user.uid, a);
    }
  }

  Future<void> update(AppointmentModel a) async {
    final i = _store.indexWhere((e) => e.id == a.id);
    if (i >= 0) _store[i] = a;
    final user = _auth.currentUser;
    if (user != null) await _repo.update(user.uid, a);
  }

  Future<void> delete(String id) async {
    _store.removeWhere((a) => a.id == id);
    final user = _auth.currentUser;
    if (user != null) await _repo.delete(user.uid, id);
  }
}
