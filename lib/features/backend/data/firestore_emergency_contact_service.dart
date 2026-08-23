import 'package:cloud_firestore/cloud_firestore.dart';

import '../../emergency/models/emergency_contact_model.dart';
import '../repositories/emergency_contact_repository.dart';

class FirestoreEmergencyContactService implements EmergencyContactRepository {
  FirestoreEmergencyContactService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _userContacts(String uid) =>
      _firestore.collection('users').doc(uid).collection('emergency_contacts');

  @override
  Stream<List<EmergencyContactModel>> streamForUser(String uid) {
    return _userContacts(uid)
        .orderBy('priority', descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final data = {...d.data(), 'id': d.id};
            return EmergencyContactModel.fromMap(data);
          }).toList(),
        );
  }

  @override
  Future<void> add(String uid, EmergencyContactModel contact) async {
    final map = contact.toMap();
    final docRef = _userContacts(uid).doc(contact.id);
    final writeMap = Map<String, dynamic>.from(map);
    writeMap['createdAt'] = FieldValue.serverTimestamp();
    writeMap['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(writeMap, SetOptions(merge: true));
  }

  @override
  Future<void> update(String uid, EmergencyContactModel contact) async {
    final map = contact.toMap();
    final docRef = _userContacts(uid).doc(contact.id);
    final writeMap = Map<String, dynamic>.from(map);
    writeMap['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(writeMap, SetOptions(merge: true));
  }

  @override
  Future<void> delete(String uid, String contactId) async {
    await _userContacts(uid).doc(contactId).delete();
  }

  @override
  Future<List<EmergencyContactModel>> getAll(String uid) async {
    final snap = await _userContacts(
      uid,
    ).orderBy('priority', descending: false).get();
    return snap.docs
        .map((d) => EmergencyContactModel.fromMap({...d.data(), 'id': d.id}))
        .toList();
  }
}
