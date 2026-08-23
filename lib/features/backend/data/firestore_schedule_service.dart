import 'package:cloud_firestore/cloud_firestore.dart';

import '../../schedule/models/schedule_task.dart';
import '../repositories/schedule_repository.dart';

class FirestoreScheduleService implements ScheduleRepository {
  FirestoreScheduleService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _userTasks(String uid) =>
      _firestore.collection('users').doc(uid).collection('schedule_tasks');

  @override
  Stream<List<ScheduleTask>> streamForUser(String uid) {
    return _userTasks(uid)
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
    final map = task.toJson();
    final docRef = _userTasks(uid).doc(task.id);
    final writeMap = Map<String, dynamic>.from(map);
    writeMap['createdAt'] = FieldValue.serverTimestamp();
    writeMap['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(writeMap, SetOptions(merge: true));
  }

  @override
  Future<void> update(String uid, ScheduleTask task) async {
    final map = task.toJson();
    final docRef = _userTasks(uid).doc(task.id);
    final writeMap = Map<String, dynamic>.from(map);
    writeMap['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(writeMap, SetOptions(merge: true));
  }

  @override
  Future<void> delete(String uid, String taskId) async {
    await _userTasks(uid).doc(taskId).delete();
  }

  @override
  Future<List<ScheduleTask>> getAll(String uid) async {
    final snap = await _userTasks(
      uid,
    ).orderBy('createdAt', descending: true).get();
    return snap.docs
        .map((d) => ScheduleTask.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }
}
