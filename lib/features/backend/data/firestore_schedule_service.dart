import 'package:cloud_firestore/cloud_firestore.dart';

import '../../schedule/models/schedule_task.dart';
import '../repositories/schedule_repository.dart';

class FirestoreScheduleService implements ScheduleRepository {
  FirestoreScheduleService({this._firestore});

  final FirebaseFirestore? _firestore;

  FirebaseFirestore? get _db {
    if (_firestore != null) return _firestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? _userTasks(String uid) {
    final db = _db;
    if (db == null || uid.isEmpty) return null;
    return db.collection('users').doc(uid).collection('schedule_tasks');
  }

  @override
  Stream<List<ScheduleTask>> streamForUser(String uid) {
    final col = _userTasks(uid);
    if (col == null) return Stream.value([]);
    return col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final data = {...d.data(), 'id': d.id};
            return ScheduleTask.fromJson(data);
          }).toList(),
        );
  }

  @override
  Future<void> add(String uid, ScheduleTask task) async {
    final col = _userTasks(uid);
    if (col == null) return;
    final map = task.toJson();
    final docRef = col.doc(task.id);
    final writeMap = Map<String, dynamic>.from(map);
    writeMap['createdAt'] = FieldValue.serverTimestamp();
    writeMap['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(writeMap, SetOptions(merge: true));
  }

  @override
  Future<void> update(String uid, ScheduleTask task) async {
    final col = _userTasks(uid);
    if (col == null) return;
    final map = task.toJson();
    final docRef = col.doc(task.id);
    final writeMap = Map<String, dynamic>.from(map);
    writeMap['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(writeMap, SetOptions(merge: true));
  }

  @override
  Future<void> delete(String uid, String taskId) async {
    final col = _userTasks(uid);
    if (col == null) return;
    await col.doc(taskId).delete();
  }

  @override
  Future<List<ScheduleTask>> getAll(String uid) async {
    final col = _userTasks(uid);
    if (col == null) return [];
    final snap = await col.orderBy('createdAt', descending: true).get();
    return snap.docs
        .map((d) => ScheduleTask.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }
}
