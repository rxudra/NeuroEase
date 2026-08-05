import '../../profile/models/patient_model.dart';

abstract class UserRepository {
  Future<PatientModel?> getById(String uid);
  Future<void> save(PatientModel user);
  Future<void> delete(String uid);
}
