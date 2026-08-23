import 'package:cloud_firestore/cloud_firestore.dart';

import '../../ai_assistant/models/memory_model.dart';
import '../repositories/memory_repository.dart';

class FirestoreMemoryService implements MemoryRepository {
  FirestoreMemoryService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _userMemories(String uid) =>
      _firestore.collection('users').doc(uid).collection('memories');

  @override
  Stream<List<MemoryModel>> streamForUser(String uid) {
    return _userMemories(uid)
        .orderBy('time', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final data = {...d.data(), 'id': d.id};
            return MemoryModel.fromMap(data, documentId: d.id);
          }).toList(),
        );
  }

  @override
  Future<List<MemoryModel>> getAll(String uid) async {
    final snap = await _userMemories(
      uid,
    ).orderBy('time', descending: true).get();
    return snap.docs
        .map(
          (d) =>
              MemoryModel.fromMap({...d.data(), 'id': d.id}, documentId: d.id),
        )
        .toList();
  }

  @override
  Future<void> add(String uid, MemoryModel memory) async {
    final map = memory.toMap();
    final docRef = _userMemories(uid).doc(memory.id);
    final writeMap = Map<String, dynamic>.from(map);
    writeMap['createdAt'] = FieldValue.serverTimestamp();
    writeMap['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(writeMap, SetOptions(merge: true));
  }

  @override
  Future<void> update(String uid, MemoryModel memory) async {
    final map = memory.toMap();
    final docRef = _userMemories(uid).doc(memory.id);
    final writeMap = Map<String, dynamic>.from(map);
    writeMap.remove('createdAt');
    writeMap['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(writeMap, SetOptions(merge: true));
  }

  @override
  Future<void> delete(String uid, String memoryId) async {
    await _userMemories(uid).doc(memoryId).delete();
  }
}
