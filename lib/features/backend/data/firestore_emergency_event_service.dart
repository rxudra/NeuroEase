import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../emergency/models/emergency_event_model.dart';
import '../repositories/emergency_event_repository.dart';

class FirestoreEmergencyEventService implements EmergencyEventRepository {
  FirestoreEmergencyEventService({this._firestore});

  final FirebaseFirestore? _firestore;

  FirebaseFirestore? get _db {
    if (_firestore != null) return _firestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? _userEvents(String uid) {
    final db = _db;
    if (db == null || uid.isEmpty) return null;
    return db.collection('users').doc(uid).collection('emergency_events');
  }

  @override
  Stream<List<EmergencyEventModel>> streamForUser(String uid) {
    final col = _userEvents(uid);
    if (col == null) return Stream.value([]);

    try {
      final projectId = Firebase.app().options.projectId;
      final appName = Firebase.app().name;
      debugPrint('PROJECT_ID: $projectId, APP_NAME: $appName');
    } catch (_) {}

    return col.snapshots().map((snap) {
      final list = snap.docs.map((d) {
        final data = {...d.data(), 'id': d.id};
        return EmergencyEventModel.fromMap(data);
      }).toList();
      list.sort((a, b) {
        final aTime = a.time ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.time ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
      return list;
    });
  }

  @override
  Future<void> add(String uid, EmergencyEventModel event) async {
    final col = _userEvents(uid);
    if (col == null) return;
    final map = event.toMap();
    final docRef = col.doc(event.id);
    final writeMap = Map<String, dynamic>.from(map);
    writeMap['createdAt'] = FieldValue.serverTimestamp();

    try {
      await docRef.set(writeMap, SetOptions(merge: true));
    } catch (e, stackTrace) {
      debugPrint(
        '[FirestoreEmergencyEventService] Write failure: $e\n$stackTrace',
      );
      rethrow;
    }
  }

  @override
  Future<List<EmergencyEventModel>> getAll(String uid) async {
    final col = _userEvents(uid);
    if (col == null) return [];
    final snap = await col.get();
    final list = snap.docs
        .map((d) => EmergencyEventModel.fromMap({...d.data(), 'id': d.id}))
        .toList();
    list.sort((a, b) {
      final aTime = a.time ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.time ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return list;
  }
}
