import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

import '../../backend/data/firestore_emergency_contact_service.dart';
import '../../backend/data/firestore_emergency_event_service.dart';
import '../../backend/repositories/emergency_contact_repository.dart';
import '../../backend/repositories/emergency_event_repository.dart';
import '../models/emergency_contact_model.dart';
import '../models/emergency_event_model.dart';
import '../models/emergency_status_model.dart';

class EmergencyService {
  EmergencyService._private() {
    _init();
  }

  static final EmergencyService instance = EmergencyService._private();

  final List<EmergencyContactModel> contacts = [];
  final List<EmergencyEventModel> events = [];
  EmergencyStatusModel status = EmergencyStatusModel();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final EmergencyContactRepository _repo = FirestoreEmergencyContactService();
  final EmergencyEventRepository _eventRepo = FirestoreEmergencyEventService();

  StreamSubscription<List<EmergencyContactModel>>? _sub;
  StreamSubscription<List<EmergencyEventModel>>? _eventSub;

  final StreamController<List<EmergencyContactModel>> _streamController =
      StreamController<List<EmergencyContactModel>>.broadcast();

  Stream<List<EmergencyContactModel>> get stream => _streamController.stream;

  void _notify() {
    _streamController.add(List.unmodifiable(contacts));
  }

  void _init() {
    _auth.authStateChanges().listen((user) {
      _sub?.cancel();
      _eventSub?.cancel();
      contacts.clear();
      events.clear();

      if (user != null) {
        _sub = _repo
            .streamForUser(user.uid)
            .listen(
              (list) {
                contacts
                  ..clear()
                  ..addAll(list);
                _notify();
              },
              onError: (_) {
                _notify();
              },
            );

        _eventSub = _eventRepo
            .streamForUser(user.uid)
            .listen(
              (list) {
                events
                  ..clear()
                  ..addAll(list);
                _notify();
              },
              onError: (_) {
                _notify();
              },
            );
      } else {
        // Fallback mock contacts for unauthenticated users
        contacts.addAll([
          EmergencyContactModel(
            id: 'c1',
            name: 'Priya Sharma',
            relationship: 'Daughter',
            phone: '+91 91111 11111',
            priority: 1,
          ),
          EmergencyContactModel(
            id: 'c2',
            name: 'Amit Kumar',
            relationship: 'Son',
            phone: '+91 92222 22222',
            priority: 2,
          ),
        ]);

        events.addAll([
          EmergencyEventModel(
            id: 'e1',
            type: EmergencyEventType.sosTriggered,
            title: 'SOS Triggered',
            details: 'User held SOS',
            time: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          EmergencyEventModel(
            id: 'e2',
            type: EmergencyEventType.locationShared,
            title: 'Location Shared',
            details: 'Shared to emergency contacts',
            time: DateTime.now().subtract(
              const Duration(hours: 1, minutes: 40),
            ),
          ),
        ]);

        _notify();
      }
    });
  }

  void initMock() {
    // Preserved for backward compatibility
  }

  List<EmergencyContactModel> getContacts() => List.unmodifiable(contacts);
  List<EmergencyEventModel> getEvents() => List.unmodifiable(events);

  Future<void> addEvent(EmergencyEventModel e) async {
    events.insert(0, e);
    _notify();
    final user = _auth.currentUser;
    if (user != null) {
      await _eventRepo.add(user.uid, e);
    }
  }

  Future<void> addContact(EmergencyContactModel c) async {
    final idx = contacts.indexWhere((existing) => existing.id == c.id);
    if (idx >= 0) {
      contacts[idx] = c;
    } else {
      contacts.add(c);
    }
    _notify();
    final user = _auth.currentUser;
    if (user != null) {
      await _repo.add(user.uid, c);
    }
  }

  Future<void> updateContact(String id, EmergencyContactModel updated) async {
    final idx = contacts.indexWhere((c) => c.id == id);
    if (idx >= 0) contacts[idx] = updated;
    _notify();
    final user = _auth.currentUser;
    if (user != null) {
      await _repo.update(user.uid, updated);
    }
  }

  Future<void> removeContact(String id) async {
    contacts.removeWhere((c) => c.id == id);
    _notify();
    final user = _auth.currentUser;
    if (user != null) {
      await _repo.delete(user.uid, id);
    }
  }

  void setStatus(EmergencyStatusModel s) => status = s;
}
