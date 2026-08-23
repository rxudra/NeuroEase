import '../../emergency/models/emergency_contact_model.dart';

abstract class EmergencyContactRepository {
  Stream<List<EmergencyContactModel>> streamForUser(String uid);
  Future<List<EmergencyContactModel>> getAll(String uid);
  Future<void> add(String uid, EmergencyContactModel contact);
  Future<void> update(String uid, EmergencyContactModel contact);
  Future<void> delete(String uid, String contactId);
}
