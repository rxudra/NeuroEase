import 'package:cloud_firestore/cloud_firestore.dart';

import '../../emergency/models/emergency_contact_model.dart';
import '../repositories/emergency_contact_repository.dart';

class FirestoreEmergencyContactService implements EmergencyContactRepository {
  FirestoreEmergencyContactService({this._firestore});

  final FirebaseFirestore? _firestore;

  FirebaseFirestore? get _db {
    if (_firestore != null) return _firestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? _userContacts(String uid) {
    final db = _db;
    if (db == null) return null;
    return db.collection('users').doc(uid).collection('emergency_contacts');
  }

  @override
  Stream<List<EmergencyContactModel>> streamForUser(String uid) {
    final col = _userContacts(uid);
    if (col == null) return Stream.value([]);
    return col
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
    final col = _userContacts(uid);
    if (col == null) return;
    final map = contact.toMap();
    final docRef = col.doc(contact.id);
    final writeMap = Map<String, dynamic>.from(map);
    writeMap['createdAt'] = FieldValue.serverTimestamp();
    writeMap['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(writeMap, SetOptions(merge: true));
  }

  @override
  Future<void> update(String uid, EmergencyContactModel contact) async {
    final col = _userContacts(uid);
    if (col == null) return;
    final map = contact.toMap();
    final docRef = col.doc(contact.id);
    final writeMap = Map<String, dynamic>.from(map);
    writeMap['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(writeMap, SetOptions(merge: true));
  }

  @override
  Future<void> delete(String uid, String contactId) async {
    final col = _userContacts(uid);
    if (col == null) return;
    await col.doc(contactId).delete();
  }

  @override
  Future<List<EmergencyContactModel>> getAll(String uid) async {
    final col = _userContacts(uid);
    if (col == null) return [];
    final snap = await col.orderBy('priority', descending: false).get();
    return snap.docs
        .map((d) => EmergencyContactModel.fromMap({...d.data(), 'id': d.id}))
        .toList();
  }
}
