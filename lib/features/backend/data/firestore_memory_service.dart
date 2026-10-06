import 'package:cloud_firestore/cloud_firestore.dart';

import '../../ai_assistant/models/memory_model.dart';
import '../repositories/memory_repository.dart';

class FirestoreMemoryService implements MemoryRepository {
  FirestoreMemoryService({this._firestore});

  final FirebaseFirestore? _firestore;

  FirebaseFirestore? get _db {
    if (_firestore != null) return _firestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? _userMemories(String uid) {
    final db = _db;
    if (db == null) return null;
    return db.collection('users').doc(uid).collection('memories');
  }

  @override
  Stream<List<MemoryModel>> streamForUser(String uid) {
    final col = _userMemories(uid);
    if (col == null) return const Stream.empty();
    return col
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
    final col = _userMemories(uid);
    if (col == null) return const [];
    final snap = await col.orderBy('time', descending: true).get();
    return snap.docs
        .map(
          (d) =>
              MemoryModel.fromMap({...d.data(), 'id': d.id}, documentId: d.id),
        )
        .toList();
  }

  @override
  Future<void> add(String uid, MemoryModel memory) async {
    final col = _userMemories(uid);
    if (col == null) return;
    final map = memory.toMap();
    final docRef = col.doc(memory.id);
    final writeMap = Map<String, dynamic>.from(map);
    writeMap['createdAt'] = FieldValue.serverTimestamp();
    writeMap['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(writeMap, SetOptions(merge: true));
  }

  @override
  Future<void> update(String uid, MemoryModel memory) async {
    final col = _userMemories(uid);
    if (col == null) return;
    final map = memory.toMap();
    final docRef = col.doc(memory.id);
    final writeMap = Map<String, dynamic>.from(map);
    writeMap.remove('createdAt');
    writeMap['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(writeMap, SetOptions(merge: true));
  }

  @override
  Future<void> delete(String uid, String memoryId) async {
    final col = _userMemories(uid);
    if (col == null) return;
    await col.doc(memoryId).delete();
  }
}
