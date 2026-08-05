import '../../reminders/models/reminder_model.dart';

abstract class ReminderRepository {
  Stream<List<ReminderModel>> streamForUser(String uid);
  Future<List<ReminderModel>> getAll(String uid);
  Future<void> add(String uid, ReminderModel reminder);
  Future<void> update(String uid, ReminderModel reminder);
  Future<void> delete(String uid, String reminderId);
}
