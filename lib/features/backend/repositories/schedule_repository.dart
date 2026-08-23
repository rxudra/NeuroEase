import '../../schedule/models/schedule_task.dart';

abstract class ScheduleRepository {
  Stream<List<ScheduleTask>> streamForUser(String uid);
  Future<List<ScheduleTask>> getAll(String uid);
  Future<void> add(String uid, ScheduleTask task);
  Future<void> update(String uid, ScheduleTask task);
  Future<void> delete(String uid, String taskId);
}
