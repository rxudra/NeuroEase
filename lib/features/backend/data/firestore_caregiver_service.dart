import 'package:cloud_firestore/cloud_firestore.dart';

import '../../caregiver/models/alert_model.dart';
import '../../caregiver/models/caregiver_model.dart';
import '../../caregiver/models/caregiver_relationship_model.dart';
import '../repositories/caregiver_repository.dart';

class FirestoreCaregiverService implements CaregiverRepository {
  FirestoreCaregiverService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _userAlerts(String uid) =>
      _firestore.collection('users').doc(uid).collection('alerts');

  CollectionReference<Map<String, dynamic>> _userCaregivers(String uid) =>
      _firestore.collection('users').doc(uid).collection('caregivers');

  CollectionReference<Map<String, dynamic>> _patientLinks(
    String caregiverUid,
  ) => _firestore
      .collection('users')
      .doc(caregiverUid)
      .collection('patient_links');

  @override
  Stream<List<AlertModel>> streamAlertsForUser(String uid) {
    return _userAlerts(uid)
        .orderBy('time', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final data = {...d.data(), 'id': d.id};
            return AlertModel.fromMap(data, documentId: d.id);
          }).toList(),
        );
  }

  @override
  Future<List<AlertModel>> getAlerts(String uid) async {
    final snap = await _userAlerts(uid).orderBy('time', descending: true).get();
    return snap.docs
        .map(
          (d) =>
              AlertModel.fromMap({...d.data(), 'id': d.id}, documentId: d.id),
        )
        .toList();
  }

  @override
  Future<void> addAlert(String uid, AlertModel alert) async {
    final map = alert.toMap();
    final docRef = _userAlerts(uid).doc(alert.id);
    final writeMap = Map<String, dynamic>.from(map);
    writeMap['createdAt'] = FieldValue.serverTimestamp();
    writeMap['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(writeMap, SetOptions(merge: true));
  }

  @override
  Future<void> updateAlert(String uid, AlertModel alert) async {
    final map = alert.toMap();
    final docRef = _userAlerts(uid).doc(alert.id);
    final writeMap = Map<String, dynamic>.from(map);
    writeMap.remove('createdAt');
    writeMap['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(writeMap, SetOptions(merge: true));
  }

  @override
  Future<void> deleteAlert(String uid, String alertId) async {
    await _userAlerts(uid).doc(alertId).delete();
  }

  @override
  Stream<CaregiverModel?> streamCaregiverProfile(String uid) {
    final docId = uid.isNotEmpty ? uid : 'profile';
    return _userCaregivers(uid).doc(docId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      final data = {...snap.data()!, 'id': snap.id};
      return CaregiverModel.fromMap(data, documentId: snap.id);
    });
  }

  @override
  Future<CaregiverModel?> getCaregiverProfile(String uid) async {
    final docId = uid.isNotEmpty ? uid : 'profile';
    final snap = await _userCaregivers(uid).doc(docId).get();
    if (!snap.exists || snap.data() == null) return null;
    final data = {...snap.data()!, 'id': snap.id};
    return CaregiverModel.fromMap(data, documentId: snap.id);
  }

  @override
  Future<void> saveCaregiverProfile(
    String uid,
    CaregiverModel caregiver,
  ) async {
    final docId = caregiver.id.isNotEmpty ? caregiver.id : uid;
    final map = caregiver.toMap();
    final docRef = _userCaregivers(uid).doc(docId);
    final writeMap = Map<String, dynamic>.from(map);
    writeMap['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(writeMap, SetOptions(merge: true));
  }

  @override
  Stream<List<CaregiverRelationshipModel>> streamPatientLinks(
    String caregiverUid,
  ) {
    return _patientLinks(caregiverUid).snapshots().map(
      (snap) => snap.docs.map((d) {
        final data = {...d.data(), 'id': d.id};
        return CaregiverRelationshipModel.fromMap(data, documentId: d.id);
      }).toList(),
    );
  }

  @override
  Future<List<CaregiverRelationshipModel>> getPatientLinks(
    String caregiverUid,
  ) async {
    final snap = await _patientLinks(caregiverUid).get();
    return snap.docs
        .map(
          (d) => CaregiverRelationshipModel.fromMap({
            ...d.data(),
            'id': d.id,
          }, documentId: d.id),
        )
        .toList();
  }

  @override
  Future<void> linkPatient(
    String caregiverUid,
    String patientId, {
    String relationship = 'Primary Caregiver',
  }) async {
    if (caregiverUid.isEmpty || patientId.isEmpty) return;

    final link = CaregiverRelationshipModel(
      id: patientId,
      caregiverId: caregiverUid,
      patientId: patientId,
      relationship: relationship,
      createdAt: DateTime.now(),
    );

    final caregiverLinkRef = _patientLinks(caregiverUid).doc(patientId);
    final patientLinkRef = _firestore
        .collection('users')
        .doc(patientId)
        .collection('caregivers')
        .doc(caregiverUid);

    final writeMap = Map<String, dynamic>.from(link.toMap());
    writeMap['createdAt'] = FieldValue.serverTimestamp();
    writeMap['updatedAt'] = FieldValue.serverTimestamp();

    await caregiverLinkRef.set(writeMap, SetOptions(merge: true));
    await patientLinkRef.set(writeMap, SetOptions(merge: true));
  }

  @override
  Future<void> unlinkPatient(String caregiverUid, String patientId) async {
    if (caregiverUid.isEmpty || patientId.isEmpty) return;

    await _patientLinks(caregiverUid).doc(patientId).delete();
    await _firestore
        .collection('users')
        .doc(patientId)
        .collection('caregivers')
        .doc(caregiverUid)
        .delete();
  }
}
