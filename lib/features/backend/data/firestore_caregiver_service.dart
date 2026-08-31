import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../caregiver/models/alert_model.dart';
import '../../caregiver/models/caregiver_model.dart';
import '../../caregiver/models/caregiver_relationship_model.dart';
import '../../caregiver/models/family_member_model.dart';
import '../repositories/caregiver_repository.dart';

class FirestoreCaregiverService implements CaregiverRepository {
  FirestoreCaregiverService({this._firestore});

  final FirebaseFirestore? _firestore;

  FirebaseFirestore? get _db {
    if (_firestore != null) return _firestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? _userAlerts(String uid) {
    final db = _db;
    if (db == null || uid.isEmpty) return null;
    return db.collection('users').doc(uid).collection('alerts');
  }

  CollectionReference<Map<String, dynamic>>? _userCaregivers(String uid) {
    final db = _db;
    if (db == null || uid.isEmpty) return null;
    return db.collection('users').doc(uid).collection('caregivers');
  }

  CollectionReference<Map<String, dynamic>>? _patientLinks(
    String caregiverUid,
  ) {
    final db = _db;
    if (db == null || caregiverUid.isEmpty) return null;
    return db.collection('users').doc(caregiverUid).collection('patient_links');
  }

  CollectionReference<Map<String, dynamic>>? _userFamily(String uid) {
    final db = _db;
    if (db == null || uid.isEmpty) return null;
    return db.collection('users').doc(uid).collection('family_members');
  }

  @override
  Stream<List<AlertModel>> streamAlertsForUser(String uid) {
    final col = _userAlerts(uid);
    if (col == null) return Stream.value([]);
    return col.snapshots().map((snap) {
      final list = snap.docs.map((d) {
        final map = Map<String, dynamic>.from(d.data());
        return AlertModel.fromMap(map, documentId: d.id);
      }).toList();
      list.sort((a, b) {
        final tA = a.time ?? DateTime.fromMillisecondsSinceEpoch(0);
        final tB = b.time ?? DateTime.fromMillisecondsSinceEpoch(0);
        return tB.compareTo(tA);
      });
      return list;
    });
  }

  @override
  Future<List<AlertModel>> getAlerts(String uid) async {
    final col = _userAlerts(uid);
    if (col == null) return [];
    final snap = await col.get();
    final list = snap.docs
        .map((d) => AlertModel.fromMap(d.data(), documentId: d.id))
        .toList();
    list.sort((a, b) {
      final tA = a.time ?? DateTime.fromMillisecondsSinceEpoch(0);
      final tB = b.time ?? DateTime.fromMillisecondsSinceEpoch(0);
      return tB.compareTo(tA);
    });
    return list;
  }

  @override
  Future<void> addAlert(String uid, AlertModel alert) async {
    final col = _userAlerts(uid);
    if (col == null) return;
    try {
      final docRef = col.doc(alert.id);
      await docRef.set(alert.toMap(), SetOptions(merge: true));
    } catch (e, stackTrace) {
      debugPrint('[FirestoreCaregiverService] addAlert error: $e\n$stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> updateAlert(String uid, AlertModel alert) async {
    final col = _userAlerts(uid);
    if (col == null) return;
    await col.doc(alert.id).set(alert.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteAlert(String uid, String alertId) async {
    final col = _userAlerts(uid);
    if (col == null) return;
    await col.doc(alertId).delete();
  }

  @override
  Stream<CaregiverModel?> streamCaregiverProfile(String uid) {
    final col = _userCaregivers(uid);
    if (col == null) return Stream.value(null);
    return col.doc('profile').snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return CaregiverModel.fromMap({...doc.data()!, 'id': doc.id});
    });
  }

  @override
  Future<CaregiverModel?> getCaregiverProfile(String uid) async {
    final col = _userCaregivers(uid);
    if (col == null) return null;
    final doc = await col.doc('profile').get();
    if (!doc.exists || doc.data() == null) return null;
    return CaregiverModel.fromMap({...doc.data()!, 'id': doc.id});
  }

  @override
  Future<void> saveCaregiverProfile(
    String uid,
    CaregiverModel caregiver,
  ) async {
    final col = _userCaregivers(uid);
    if (col == null) return;
    await col.doc('profile').set(caregiver.toMap(), SetOptions(merge: true));
  }

  @override
  Stream<List<CaregiverRelationshipModel>> streamPatientLinks(
    String caregiverUid,
  ) {
    final col = _patientLinks(caregiverUid);
    if (col == null) return Stream.value([]);
    return col.snapshots().map(
      (snap) => snap.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        return CaregiverRelationshipModel.fromMap({...data, 'id': d.id});
      }).toList(),
    );
  }

  @override
  Future<List<CaregiverRelationshipModel>> getPatientLinks(
    String caregiverUid,
  ) async {
    final col = _patientLinks(caregiverUid);
    if (col == null) return [];
    final snap = await col.get();
    return snap.docs
        .map(
          (d) => CaregiverRelationshipModel.fromMap({...d.data(), 'id': d.id}),
        )
        .toList();
  }

  @override
  Future<void> linkPatient(
    String caregiverUid,
    String patientId, {
    String relationship = 'Primary Caregiver',
  }) async {
    final col = _patientLinks(caregiverUid);
    if (col == null) return;
    final model = CaregiverRelationshipModel(
      id: patientId,
      caregiverId: caregiverUid,
      patientId: patientId,
      relationship: relationship,
      createdAt: DateTime.now(),
    );
    await col.doc(patientId).set(model.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> unlinkPatient(String caregiverUid, String patientId) async {
    final col = _patientLinks(caregiverUid);
    if (col == null) return;
    await col.doc(patientId).delete();
  }

  @override
  Stream<List<FamilyMemberModel>> streamFamilyMembers(String uid) {
    final col = _userFamily(uid);
    if (col == null) return Stream.value([]);
    return col.snapshots().map(
      (snap) => snap.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        return FamilyMemberModel.fromMap({...data, 'id': d.id});
      }).toList(),
    );
  }

  @override
  Future<List<FamilyMemberModel>> getFamilyMembers(String uid) async {
    final col = _userFamily(uid);
    if (col == null) return [];
    final snap = await col.get();
    return snap.docs
        .map((d) => FamilyMemberModel.fromMap({...d.data(), 'id': d.id}))
        .toList();
  }

  @override
  Future<void> addFamilyMember(String uid, FamilyMemberModel member) async {
    final col = _userFamily(uid);
    if (col == null) return;
    await col.doc(member.id).set(member.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> updateFamilyMember(String uid, FamilyMemberModel member) async {
    final col = _userFamily(uid);
    if (col == null) return;
    await col.doc(member.id).set(member.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteFamilyMember(String uid, String memberId) async {
    final col = _userFamily(uid);
    if (col == null) return;
    await col.doc(memberId).delete();
  }
}
