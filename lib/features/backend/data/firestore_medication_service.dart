import 'package:cloud_firestore/cloud_firestore.dart';

import '../../medication/models/medication_model.dart';
import '../repositories/medication_repository.dart';

class FirestoreMedicationService implements MedicationRepository {
  FirestoreMedicationService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _userMeds(String uid) =>
      _firestore.collection('users').doc(uid).collection('medications');

  @override
  Stream<List<MedicationModel>> streamForUser(String uid) {
    return _userMeds(uid)
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
    final map = med.toMap();
    final docRef = _userMeds(uid).doc(med.id);
    final writeMap = Map<String, dynamic>.from(map);
    writeMap['createdAt'] = FieldValue.serverTimestamp();
    writeMap['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(writeMap, SetOptions(merge: true));
  }

  @override
  Future<void> update(String uid, MedicationModel med) async {
    final map = med.toMap();
    final docRef = _userMeds(uid).doc(med.id);
    final writeMap = Map<String, dynamic>.from(map);
    writeMap['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(writeMap, SetOptions(merge: true));
  }

  @override
  Future<void> delete(String uid, String medId) async {
    await _userMeds(uid).doc(medId).delete();
  }

  @override
  Future<List<MedicationModel>> getAll(String uid) async {
    final snap = await _userMeds(
      uid,
    ).orderBy('createdAt', descending: true).get();
    return snap.docs
        .map((d) => MedicationModel.fromMap({...d.data(), 'id': d.id}))
        .toList();
  }
}
