import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

import '../../ai_assistant/models/memory_model.dart';
import '../../backend/data/firestore_memory_service.dart';
import '../../backend/repositories/memory_repository.dart';

class MemoryService {
  MemoryService._private() {
    _init();
  }

  static final MemoryService instance = MemoryService._private();

  final List<MemoryModel> _memories = [];
  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  final MemoryRepository _repo = FirestoreMemoryService();
  StreamSubscription<List<MemoryModel>>? _sub;

  final StreamController<List<MemoryModel>> _streamController =
      StreamController<List<MemoryModel>>.broadcast();

  Stream<List<MemoryModel>> get stream => _streamController.stream;

  void _notify() {
    _streamController.add(List.unmodifiable(_memories));
  }

  void _init() {
    final auth = _auth;
    if (auth == null) return;
    auth.authStateChanges().listen((user) {
      _sub?.cancel();
      _memories.clear();

      if (user != null) {
        _sub = _repo
            .streamForUser(user.uid)
            .listen(
              (list) {
                _memories
                  ..clear()
                  ..addAll(list);
                _notify();
              },
              onError: (_) {
                _notify();
              },
            );
      } else {
        _notify();
      }
    });
  }

  List<MemoryModel> getMemories() => List.unmodifiable(_memories);

  Future<void> addMemory(MemoryModel memory) async {
    final idx = _memories.indexWhere((m) => m.id == memory.id);
    if (idx >= 0) {
      _memories[idx] = memory;
    } else {
      _memories.insert(0, memory);
    }
    _notify();

    final user = _auth?.currentUser;
    if (user != null) {
      await _repo.add(user.uid, memory);
    }
  }

  Future<void> updateMemory(MemoryModel memory) async {
    final idx = _memories.indexWhere((m) => m.id == memory.id);
    if (idx >= 0) {
      _memories[idx] = memory;
    } else {
      _memories.insert(0, memory);
    }
    _notify();

    final user = _auth?.currentUser;
    if (user != null) {
      await _repo.update(user.uid, memory);
    }
  }

  Future<void> deleteMemory(String memoryId) async {
    _memories.removeWhere((m) => m.id == memoryId);
    _notify();

    final user = _auth?.currentUser;
    if (user != null) {
      await _repo.delete(user.uid, memoryId);
    }
  }
}
