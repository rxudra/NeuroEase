import 'package:cloud_firestore/cloud_firestore.dart';

import '../../emergency/models/emergency_event_model.dart';
import '../repositories/emergency_event_repository.dart';

class FirestoreEmergencyEventService implements EmergencyEventRepository {
  FirestoreEmergencyEventService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _userEvents(String uid) =>
      _firestore.collection('users').doc(uid).collection('emergency_events');

  @override
  Stream<List<EmergencyEventModel>> streamForUser(String uid) {
    return _userEvents(uid)
        .orderBy('time', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final data = {...d.data(), 'id': d.id};
            return EmergencyEventModel.fromMap(data);
          }).toList(),
        );
  }

  @override
  Future<void> add(String uid, EmergencyEventModel event) async {
    final map = event.toMap();
    final docRef = _userEvents(uid).doc(event.id);
    final writeMap = Map<String, dynamic>.from(map);
    writeMap['createdAt'] = FieldValue.serverTimestamp();
    await docRef.set(writeMap, SetOptions(merge: true));
  }

  @override
  Future<List<EmergencyEventModel>> getAll(String uid) async {
    final snap = await _userEvents(uid).orderBy('time', descending: true).get();
    return snap.docs
        .map((d) => EmergencyEventModel.fromMap({...d.data(), 'id': d.id}))
        .toList();
  }
}
