import '../../emergency/models/emergency_event_model.dart';

abstract class EmergencyEventRepository {
  Stream<List<EmergencyEventModel>> streamForUser(String uid);
  Future<List<EmergencyEventModel>> getAll(String uid);
  Future<void> add(String uid, EmergencyEventModel event);
}
