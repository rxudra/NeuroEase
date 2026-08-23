import '../../caregiver/models/alert_model.dart';
import '../../caregiver/models/caregiver_model.dart';
import '../../caregiver/models/caregiver_relationship_model.dart';

abstract class CaregiverRepository {
  Stream<List<AlertModel>> streamAlertsForUser(String uid);
  Future<List<AlertModel>> getAlerts(String uid);
  Future<void> addAlert(String uid, AlertModel alert);
  Future<void> updateAlert(String uid, AlertModel alert);
  Future<void> deleteAlert(String uid, String alertId);

  Stream<CaregiverModel?> streamCaregiverProfile(String uid);
  Future<CaregiverModel?> getCaregiverProfile(String uid);
  Future<void> saveCaregiverProfile(String uid, CaregiverModel caregiver);

  Stream<List<CaregiverRelationshipModel>> streamPatientLinks(
    String caregiverUid,
  );
  Future<List<CaregiverRelationshipModel>> getPatientLinks(String caregiverUid);
  Future<void> linkPatient(
    String caregiverUid,
    String patientId, {
    String relationship = 'Primary Caregiver',
  });
  Future<void> unlinkPatient(String caregiverUid, String patientId);
}
