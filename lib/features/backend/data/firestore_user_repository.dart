import 'package:cloud_firestore/cloud_firestore.dart';

import '../../profile/models/patient_model.dart';
import '../repositories/user_repository.dart';

class FirestoreUserRepository implements UserRepository {
  FirestoreUserRepository({this._firestore});

  final FirebaseFirestore? _firestore;

  FirebaseFirestore? get _db {
    if (_firestore != null) return _firestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> delete(String uid) async {
    final db = _db;
    if (db == null || uid.isEmpty) return;
    await db.collection('users').doc(uid).delete();
  }

  @override
  Future<PatientModel?> getById(String uid) async {
    final db = _db;
    if (db == null || uid.isEmpty) return null;
    final snap = await db.collection('users').doc(uid).get();
    if (!snap.exists) return null;
    final data = snap.data() ?? {};
    // Merge uid if missing
    final map = Map<String, dynamic>.from(data);
    map['id'] = uid;
    // Firestore timestamps may be Timestamp objects
    if (map['createdAt'] is Timestamp) {
      map['createdAt'] = (map['createdAt'] as Timestamp)
          .toDate()
          .toIso8601String();
    }
    if (map['dob'] is Timestamp) {
      map['dob'] = (map['dob'] as Timestamp).toDate().toIso8601String();
    }
    return PatientModel.fromMap(map);
  }

  @override
  Future<void> save(PatientModel user) async {
    final db = _db;
    if (db == null || user.id.isEmpty) return;
    final map = user.toMap();
    final docRef = db.collection('users').doc(user.id);
    final writeMap = Map<String, dynamic>.from(map);
    try {
      writeMap['createdAt'] = FieldValue.serverTimestamp();
    } catch (_) {}
    await docRef.set(writeMap, SetOptions(merge: true));
  }
}
