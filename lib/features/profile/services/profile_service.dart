import '../models/patient_model.dart';

class ProfileService {
  ProfileService._private();
  static final ProfileService instance = ProfileService._private();

  late PatientModel _patient;
  bool _initialized = false;

  void initMock() {
    if (_initialized) return;
    _patient = PatientModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      fullName: 'Rudra Kumar',
      nickname: 'Rudra',
      dob: DateTime(1955, 4, 12),
      gender: 'Male',
      bloodGroup: 'A+',
      heightCm: 170,
      weightKg: 72,
      phone: '+91 90000 00000',
      email: 'rudra@example.com',
      address: '123, Example Street, City',
      doctor: 'Dr. Priya Sharma',
      hospital: 'City Hospital',
      allergies: ['Penicillin'],
      conditions: ['Hypertension'],
      medications: ['Vitamin D', 'Amlodipine'],
      emergencyContacts: [
        EmergencyContact(
          id: 'c1',
          name: 'Priya Sharma',
          relationship: 'Daughter',
          phone: '+91 91111 11111',
          isPrimary: true,
        ),
        EmergencyContact(
          id: 'c2',
          name: 'Amit Kumar',
          relationship: 'Son',
          phone: '+91 92222 22222',
        ),
      ],
      notes: 'Patient prefers morning walks and gentle exercises.',
    );
    _initialized = true;
  }

  PatientModel getPatient() {
    if (!_initialized) initMock();
    return _patient;
  }

  void updatePatient(PatientModel updated) {
    _patient = updated;
  }
}
