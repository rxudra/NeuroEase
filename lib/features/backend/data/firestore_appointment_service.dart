import 'package:cloud_firestore/cloud_firestore.dart';

import '../../appointments/models/appointment_model.dart';
import '../repositories/appointment_repository.dart';

class FirestoreAppointmentService implements AppointmentRepository {
  FirestoreAppointmentService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _userAppointments(String uid) =>
      _firestore.collection('users').doc(uid).collection('appointments');

  @override
  Stream<List<AppointmentModel>> streamForUser(String uid) {
    return _userAppointments(uid)
        .orderBy('appointmentDate')
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final data = {...d.data(), 'id': d.id};
            if (data['appointmentDate'] is Timestamp) {
              data['appointmentDate'] = (data['appointmentDate'] as Timestamp)
                  .toDate()
                  .toIso8601String();
            }
            if (data['appointmentTime'] is Timestamp) {
              final dt = (data['appointmentTime'] as Timestamp).toDate();
              data['appointmentTime'] = '${dt.hour}:${dt.minute}';
            }
            return AppointmentModel.fromJson(Map<String, dynamic>.from(data));
          }).toList(),
        );
  }

  @override
  Future<void> add(String uid, AppointmentModel appointment) async {
    final map = appointment.toJson();
    final docRef = _userAppointments(uid).doc(appointment.id);
    final writeMap = Map<String, dynamic>.from(map);
    writeMap['createdAt'] = FieldValue.serverTimestamp();
    writeMap['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(writeMap, SetOptions(merge: true));
  }

  @override
  Future<void> update(String uid, AppointmentModel appointment) async {
    final map = appointment.toJson();
    final docRef = _userAppointments(uid).doc(appointment.id);
    final writeMap = Map<String, dynamic>.from(map);
    writeMap['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(writeMap, SetOptions(merge: true));
  }

  @override
  Future<void> delete(String uid, String appointmentId) async {
    await _userAppointments(uid).doc(appointmentId).delete();
  }

  @override
  Future<List<AppointmentModel>> getAll(String uid) async {
    final snap = await _userAppointments(uid).orderBy('appointmentDate').get();
    return snap.docs.map((d) {
      final data = {...d.data(), 'id': d.id};
      if (data['appointmentDate'] is Timestamp) {
        data['appointmentDate'] = (data['appointmentDate'] as Timestamp)
            .toDate()
            .toIso8601String();
      }
      if (data['appointmentTime'] is Timestamp) {
        final dt = (data['appointmentTime'] as Timestamp).toDate();
        data['appointmentTime'] = '${dt.hour}:${dt.minute}';
      }
      return AppointmentModel.fromJson(Map<String, dynamic>.from(data));
    }).toList();
  }
}
