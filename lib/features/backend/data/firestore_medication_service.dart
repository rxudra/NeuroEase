import 'package:cloud_firestore/cloud_firestore.dart';

import '../../medication/models/medication_model.dart';
import '../repositories/medication_repository.dart';

class FirestoreMedicationService implements MedicationRepository {
  FirestoreMedicationService({this._firestore});

  final FirebaseFirestore? _firestore;

  FirebaseFirestore? get _db {
    if (_firestore != null) return _firestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? _userMeds(String uid) {
    final db = _db;
    if (db == null || uid.isEmpty) return null;
    return db.collection('users').doc(uid).collection('medications');
  }

  @override
  Stream<List<MedicationModel>> streamForUser(String uid) {
    final col = _userMeds(uid);
    if (col == null) return Stream.value([]);
    return col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final data = {...d.data(), 'id': d.id};
            return MedicationModel.fromMap(data);
          }).toList(),
        );
  }

  @override
  Future<void> add(String uid, MedicationModel med) async {
    final col = _userMeds(uid);
    if (col == null) return;
    final map = med.toMap();
    final docRef = col.doc(med.id);
    final writeMap = Map<String, dynamic>.from(map);
    writeMap['createdAt'] = FieldValue.serverTimestamp();
    writeMap['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(writeMap, SetOptions(merge: true));
  }

  @override
  Future<void> update(String uid, MedicationModel med) async {
    final col = _userMeds(uid);
    if (col == null) return;
    final map = med.toMap();
    final docRef = col.doc(med.id);
    final writeMap = Map<String, dynamic>.from(map);
    writeMap['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(writeMap, SetOptions(merge: true));
  }

  @override
  Future<void> delete(String uid, String medId) async {
    final col = _userMeds(uid);
    if (col == null) return;
    await col.doc(medId).delete();
  }

  @override
  Future<List<MedicationModel>> getAll(String uid) async {
    final col = _userMeds(uid);
    if (col == null) return [];
    final snap = await col.orderBy('createdAt', descending: true).get();
    return snap.docs
        .map((d) => MedicationModel.fromMap({...d.data(), 'id': d.id}))
        .toList();
  }
}
