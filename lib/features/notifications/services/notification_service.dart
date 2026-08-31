import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../backend/data/firestore_notification_service.dart';
import '../../backend/repositories/notification_repository.dart';
import '../models/notification_item.dart';

class NotificationService {
  NotificationService._internal({
    NotificationRepository? repository,
    this._auth,
  }) : _repo = repository ?? FirestoreNotificationService() {
    _init();
  }

  static final NotificationService instance = NotificationService._internal();

  /// Visible for testing constructor allowing injection of mock repo/auth
  factory NotificationService.custom({
    NotificationRepository? repository,
    FirebaseAuth? auth,
  }) {
    return NotificationService._internal(repository: repository, auth: auth);
  }

  final NotificationRepository _repo;
  final FirebaseAuth? _auth;

  User? get _currentUser {
    if (_auth != null) return _auth.currentUser;
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  final List<NotificationItem> _items = [];
  StreamSubscription<List<NotificationItem>>? _notifSub;
  StreamSubscription<User?>? _authSub;

  final StreamController<List<NotificationItem>> _streamController =
      StreamController<List<NotificationItem>>.broadcast();

  Stream<List<NotificationItem>> get stream => _streamController.stream;

  List<NotificationItem> get items =>
      List.unmodifiable(_items.where((n) => !n.isDismissed).toList());

  int get unreadCount =>
      _items.where((n) => !n.isDismissed && !n.isRead).length;

  void _notify() {
    _streamController.add(items);
  }

  void _init() {
    try {
      final authInstance = _auth ?? FirebaseAuth.instance;
      _authSub = authInstance.authStateChanges().listen((user) {
        _notifSub?.cancel();
        _items.clear();
        _notify();

        if (user != null && user.uid.isNotEmpty) {
          _notifSub = _repo
              .streamForUser(user.uid)
              .listen(
                (list) {
                  _items
                    ..clear()
                    ..addAll(list);
                  _notify();
                },
                onError: (error, stackTrace) {
                  debugPrint(
                    '[NotificationService] streamForUser error: $error\n$stackTrace',
                  );
                  _notify();
                },
              );
        }
      });
    } catch (e) {
      debugPrint('[NotificationService] FirebaseAuth init skipped: $e');
    }
  }

  Future<List<NotificationItem>> fetch({
    String? category,
    bool unreadOnly = false,
    String? query,
  }) async {
    final user = _currentUser;
    List<NotificationItem> source = [];

    if (user != null && user.uid.isNotEmpty) {
      try {
        source = await _repo.getAll(user.uid);
        _items
          ..clear()
          ..addAll(source);
      } catch (e, stackTrace) {
        debugPrint(
          '[NotificationService] fetch error from backend: $e\n$stackTrace',
        );
        source = List.from(_items);
      }
    } else {
      source = List.from(_items);
    }

    Iterable<NotificationItem> results = source.where((n) => !n.isDismissed);
    if (category != null && category != 'All') {
      results = results.where((n) => n.category == category);
    }
    if (unreadOnly) {
      results = results.where((n) => !n.isRead);
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where(
        (n) =>
            n.title.toLowerCase().contains(q) ||
            n.body.toLowerCase().contains(q),
      );
    }
    final sorted = results.toList()..sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  Future<void> addNotification(NotificationItem notification) async {
    final idx = _items.indexWhere((n) => n.id == notification.id);
    if (idx >= 0) {
      _items[idx] = notification;
    } else {
      _items.insert(0, notification);
    }
    _notify();

    final user = _currentUser;
    if (user != null && user.uid.isNotEmpty) {
      try {
        await _repo.add(user.uid, notification);
      } catch (e, stackTrace) {
        debugPrint(
          '[NotificationService] addNotification error: $e\n$stackTrace',
        );
      }
    }
  }

  Future<void> markRead(String id) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      _items[idx].isRead = true;
      _notify();
    }

    final user = _currentUser;
    if (user != null && user.uid.isNotEmpty) {
      try {
        await _repo.markRead(user.uid, id);
      } catch (e, stackTrace) {
        debugPrint(
          '[NotificationService] markRead error for $id: $e\n$stackTrace',
        );
      }
    }
  }

  Future<void> markUnread(String id) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      _items[idx].isRead = false;
      _notify();
    }

    final user = _currentUser;
    if (user != null && user.uid.isNotEmpty) {
      try {
        await _repo.markUnread(user.uid, id);
      } catch (e, stackTrace) {
        debugPrint(
          '[NotificationService] markUnread error for $id: $e\n$stackTrace',
        );
      }
    }
  }

  Future<void> markAllRead() async {
    for (final n in _items) {
      n.isRead = true;
    }
    _notify();

    final user = _currentUser;
    if (user != null && user.uid.isNotEmpty) {
      try {
        await _repo.markAllRead(user.uid);
      } catch (e, stackTrace) {
        debugPrint('[NotificationService] markAllRead error: $e\n$stackTrace');
      }
    }
  }

  Future<void> dismiss(String id) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      _items[idx].isDismissed = true;
      _notify();
    }

    final user = _currentUser;
    if (user != null && user.uid.isNotEmpty) {
      try {
        await _repo.dismiss(user.uid, id);
      } catch (e, stackTrace) {
        debugPrint(
          '[NotificationService] dismiss error for $id: $e\n$stackTrace',
        );
      }
    }
  }

  Future<void> delete(String id) async {
    _items.removeWhere((e) => e.id == id);
    _notify();

    final user = _currentUser;
    if (user != null && user.uid.isNotEmpty) {
      try {
        await _repo.delete(user.uid, id);
      } catch (e, stackTrace) {
        debugPrint(
          '[NotificationService] delete error for $id: $e\n$stackTrace',
        );
      }
    }
  }

  List<String> categories() {
    final set = <String>{
      'All',
      'Reminders',
      'Medication',
      'Messages',
      'System',
    };
    for (final n in _items.where((item) => !item.isDismissed)) {
      if (n.category.isNotEmpty) {
        set.add(n.category);
      }
    }
    return set.toList();
  }

  void dispose() {
    _notifSub?.cancel();
    _authSub?.cancel();
    _streamController.close();
  }
}
