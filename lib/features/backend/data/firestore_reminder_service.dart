import 'package:cloud_firestore/cloud_firestore.dart';

import '../../reminders/models/reminder_model.dart';
import '../repositories/reminder_repository.dart';

class FirestoreReminderService implements ReminderRepository {
  FirestoreReminderService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _userReminders(String uid) =>
      _firestore.collection('users').doc(uid).collection('reminders');

  @override
  Stream<List<ReminderModel>> streamForUser(String uid) {
    return _userReminders(uid)
        .orderBy('date')
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final data = {...d.data(), 'id': d.id};
            // Convert potential Timestamps to ISO strings
            if (data['date'] is Timestamp) {
              data['date'] = (data['date'] as Timestamp)
                  .toDate()
                  .toIso8601String();
            }
            if (data['time'] is Timestamp) {
              data['time'] =
                  '${(data['time'] as Timestamp).toDate().hour}:${(data['time'] as Timestamp).toDate().minute}';
            }
            return ReminderModel.fromJson(Map<String, dynamic>.from(data));
          }).toList(),
        );
  }

  @override
  Future<void> add(String uid, ReminderModel reminder) async {
    final map = reminder.toJson();
    final docRef = _userReminders(uid).doc(reminder.id);
    final writeMap = Map<String, dynamic>.from(map);
    writeMap['createdAt'] = FieldValue.serverTimestamp();
    writeMap['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(writeMap, SetOptions(merge: true));
  }

  @override
  Future<void> update(String uid, ReminderModel reminder) async {
    final map = reminder.toJson();
    final docRef = _userReminders(uid).doc(reminder.id);
    final writeMap = Map<String, dynamic>.from(map);
    writeMap['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(writeMap, SetOptions(merge: true));
  }

  @override
  Future<void> delete(String uid, String reminderId) async {
    await _userReminders(uid).doc(reminderId).delete();
  }

  @override
  Future<List<ReminderModel>> getAll(String uid) async {
    final snap = await _userReminders(uid).orderBy('date').get();
    return snap.docs.map((d) {
      final data = {...d.data(), 'id': d.id};
      if (data['date'] is Timestamp) {
        data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
      }
      if (data['time'] is Timestamp) {
        data['time'] =
            '${(data['time'] as Timestamp).toDate().hour}:${(data['time'] as Timestamp).toDate().minute}';
      }
      return ReminderModel.fromJson(Map<String, dynamic>.from(data));
    }).toList();
  }
}
