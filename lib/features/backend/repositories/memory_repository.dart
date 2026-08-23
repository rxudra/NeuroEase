import '../../ai_assistant/models/memory_model.dart';

abstract class MemoryRepository {
  Stream<List<MemoryModel>> streamForUser(String uid);
  Future<List<MemoryModel>> getAll(String uid);
  Future<void> add(String uid, MemoryModel memory);
  Future<void> update(String uid, MemoryModel memory);
  Future<void> delete(String uid, String memoryId);
}
