import '../../medication/models/medication_model.dart';

abstract class MedicationRepository {
  Stream<List<MedicationModel>> streamForUser(String uid);
  Future<List<MedicationModel>> getAll(String uid);
  Future<void> add(String uid, MedicationModel med);
  Future<void> update(String uid, MedicationModel med);
  Future<void> delete(String uid, String medId);
}
