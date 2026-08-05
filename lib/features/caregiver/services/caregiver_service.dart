// Flutter material not required here; avoid unused import
import '../models/caregiver_model.dart';
import '../models/patient_status_model.dart';
import '../models/health_summary_model.dart';
import '../models/alert_model.dart';
import '../models/family_member_model.dart';

class CaregiverService {
  CaregiverService._private();
  static final CaregiverService instance = CaregiverService._private();

  late CaregiverModel caregiver;
  final List<PatientStatusModel> patients = [];
  final Map<String, HealthSummaryModel> health = {};
  final List<AlertModel> alerts = [];
  final List<FamilyMemberModel> family = [];

  void initMock() {
    caregiver = CaregiverModel(
      id: 'cg1',
      name: 'Priya Sharma',
      phone: '+91 91111 11111',
      role: 'Primary Caregiver',
    );

    patients.addAll([
      PatientStatusModel(
        patientId: 'p1',
        name: 'Rudra Kumar',
        avatarUrl: '',
        lastActive: DateTime.now().subtract(const Duration(minutes: 5)),
        location: 'Home',
        online: true,
      ),
      PatientStatusModel(
        patientId: 'p2',
        name: 'Asha Devi',
        avatarUrl: '',
        lastActive: DateTime.now().subtract(const Duration(hours: 2)),
        location: 'Clinic',
        online: false,
      ),
    ]);

    health['p1'] = HealthSummaryModel(
      heartRate: 72,
      bpSystolic: 130,
      bpDiastolic: 82,
      spo2: 97,
      sleepHours: 7.0,
    );
    health['p2'] = HealthSummaryModel(
      heartRate: 78,
      bpSystolic: 125,
      bpDiastolic: 80,
      spo2: 98,
      sleepHours: 6.5,
    );

    alerts.addAll([
      AlertModel(
        id: 'a1',
        title: 'Missed Medication - Amlodipine',
        type: AlertType.missedMedication,
        details: 'Missed at 08:30',
        time: DateTime.now().subtract(const Duration(hours: 3)),
        severity: 3,
      ),
      AlertModel(
        id: 'a2',
        title: 'Low Activity',
        type: AlertType.lowActivity,
        details: 'No movement detected for 12 hours',
        time: DateTime.now().subtract(const Duration(hours: 6)),
        severity: 2,
      ),
    ]);

    family.addAll([
      FamilyMemberModel(
        id: 'f1',
        name: 'Priya Sharma',
        relationship: 'Daughter',
        phone: '+91 91111 11111',
        role: 'Primary',
      ),
      FamilyMemberModel(
        id: 'f2',
        name: 'Amit Kumar',
        relationship: 'Son',
        phone: '+91 92222 22222',
        role: 'Secondary',
      ),
    ]);
  }

  List<PatientStatusModel> getPatients() => List.unmodifiable(patients);
  HealthSummaryModel? getHealth(String patientId) => health[patientId];
  List<AlertModel> getAlerts() => List.unmodifiable(alerts);
  List<FamilyMemberModel> getFamily() => List.unmodifiable(family);

  void dismissAlert(String id) => alerts.removeWhere((a) => a.id == id);
}
