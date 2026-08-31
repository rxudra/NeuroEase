import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../notifications/models/notification_item.dart';
import '../repositories/notification_repository.dart';

class FirestoreNotificationService implements NotificationRepository {
  FirestoreNotificationService({this._firestore});

  final FirebaseFirestore? _firestore;

  FirebaseFirestore? get _db {
    if (_firestore != null) return _firestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? _userNotifications(String uid) {
    final db = _db;
    if (db == null || uid.isEmpty) return null;
    return db.collection('users').doc(uid).collection('notifications');
  }

  @override
  Stream<List<NotificationItem>> streamForUser(String uid) {
    final col = _userNotifications(uid);
    if (col == null) return Stream.value([]);
    return col
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) {
            final data = {...d.data(), 'id': d.id};
            return NotificationItem.fromMap(data, documentId: d.id);
          }).toList();
          list.sort((a, b) => b.date.compareTo(a.date));
          return list;
        })
        .handleError((error, stackTrace) {
          debugPrint(
            '[FirestoreNotificationService] streamForUser error: $error\n$stackTrace',
          );
          throw error;
        });
  }

  @override
  Future<List<NotificationItem>> getAll(String uid) async {
    final col = _userNotifications(uid);
    if (col == null) return [];
    try {
      final snap = await col.get();
      final list = snap.docs.map((d) {
        final data = {...d.data(), 'id': d.id};
        return NotificationItem.fromMap(data, documentId: d.id);
      }).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    } catch (e, stackTrace) {
      debugPrint(
        '[FirestoreNotificationService] getAll error for $uid: $e\n$stackTrace',
      );
      rethrow;
    }
  }

  @override
  Future<void> add(String uid, NotificationItem notification) async {
    final col = _userNotifications(uid);
    if (col == null) return;
    try {
      final docId = notification.id.isNotEmpty ? notification.id : col.doc().id;
      final docRef = col.doc(docId);
      final map = notification.toMap();
      final writeMap = Map<String, dynamic>.from(map);
      writeMap['id'] = docId;
      writeMap['createdAt'] = FieldValue.serverTimestamp();
      writeMap['updatedAt'] = FieldValue.serverTimestamp();
      await docRef.set(writeMap, SetOptions(merge: true));
    } catch (e, stackTrace) {
      debugPrint(
        '[FirestoreNotificationService] add error for $uid: $e\n$stackTrace',
      );
      rethrow;
    }
  }

  @override
  Future<void> update(String uid, NotificationItem notification) async {
    final col = _userNotifications(uid);
    if (col == null || notification.id.isEmpty) return;
    try {
      final docRef = col.doc(notification.id);
      final map = notification.toMap();
      final writeMap = Map<String, dynamic>.from(map);
      writeMap.remove('createdAt');
      writeMap['updatedAt'] = FieldValue.serverTimestamp();
      await docRef.set(writeMap, SetOptions(merge: true));
    } catch (e, stackTrace) {
      debugPrint(
        '[FirestoreNotificationService] update error for $uid/${notification.id}: $e\n$stackTrace',
      );
      rethrow;
    }
  }

  @override
  Future<void> markRead(String uid, String notificationId) async {
    final col = _userNotifications(uid);
    if (col == null || notificationId.isEmpty) return;
    try {
      final docRef = col.doc(notificationId);
      await docRef.set({
        'read': true,
        'isRead': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e, stackTrace) {
      debugPrint(
        '[FirestoreNotificationService] markRead error for $uid/$notificationId: $e\n$stackTrace',
      );
      rethrow;
    }
  }

  @override
  Future<void> markUnread(String uid, String notificationId) async {
    final col = _userNotifications(uid);
    if (col == null || notificationId.isEmpty) return;
    try {
      final docRef = col.doc(notificationId);
      await docRef.set({
        'read': false,
        'isRead': false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e, stackTrace) {
      debugPrint(
        '[FirestoreNotificationService] markUnread error for $uid/$notificationId: $e\n$stackTrace',
      );
      rethrow;
    }
  }

  @override
  Future<void> markAllRead(String uid) async {
    final col = _userNotifications(uid);
    final db = _db;
    if (col == null || db == null) return;
    try {
      final snap = await col.where('read', isEqualTo: false).get();
      final batch = db.batch();
      for (final doc in snap.docs) {
        batch.set(doc.reference, {
          'read': true,
          'isRead': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      final snapIsRead = await col.where('isRead', isEqualTo: false).get();
      for (final doc in snapIsRead.docs) {
        batch.set(doc.reference, {
          'read': true,
          'isRead': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      await batch.commit();
    } catch (e, stackTrace) {
      debugPrint(
        '[FirestoreNotificationService] markAllRead error for $uid: $e\n$stackTrace',
      );
      rethrow;
    }
  }

  @override
  Future<void> dismiss(String uid, String notificationId) async {
    final col = _userNotifications(uid);
    if (col == null || notificationId.isEmpty) return;
    try {
      final docRef = col.doc(notificationId);
      await docRef.set({
        'isDismissed': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e, stackTrace) {
      debugPrint(
        '[FirestoreNotificationService] dismiss error for $uid/$notificationId: $e\n$stackTrace',
      );
      rethrow;
    }
  }

  @override
  Future<void> delete(String uid, String notificationId) async {
    final col = _userNotifications(uid);
    if (col == null || notificationId.isEmpty) return;
    try {
      await col.doc(notificationId).delete();
    } catch (e, stackTrace) {
      debugPrint(
        '[FirestoreNotificationService] delete error for $uid/$notificationId: $e\n$stackTrace',
      );
      rethrow;
    }
  }
}
