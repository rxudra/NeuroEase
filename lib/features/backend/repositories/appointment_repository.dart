import '../../appointments/models/appointment_model.dart';

abstract class AppointmentRepository {
  Stream<List<AppointmentModel>> streamForUser(String uid);
  Future<List<AppointmentModel>> getAll(String uid);
  Future<void> add(String uid, AppointmentModel appointment);
  Future<void> update(String uid, AppointmentModel appointment);
  Future<void> delete(String uid, String appointmentId);
}
