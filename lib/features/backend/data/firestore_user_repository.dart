import 'package:cloud_firestore/cloud_firestore.dart';

import '../../profile/models/patient_model.dart';
import '../repositories/user_repository.dart';

class FirestoreUserRepository implements UserRepository {
  FirestoreUserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<void> delete(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  @override
  Future<PatientModel?> getById(String uid) async {
    final snap = await _firestore.collection('users').doc(uid).get();
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
    final map = user.toMap();
    // Convert ISO dates back to server timestamps where appropriate
    final docRef = _firestore.collection('users').doc(user.id);
    final writeMap = Map<String, dynamic>.from(map);
    try {
      // Convert createdAt and dob to Timestamp if possible
      writeMap['createdAt'] = FieldValue.serverTimestamp();
    } catch (_) {}
    await docRef.set(writeMap, SetOptions(merge: true));
  }
}
