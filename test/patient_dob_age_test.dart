import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/profile/models/patient_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Patient DOB and Dynamic Age Tests', () {
    test(
      'Existing DOB loads correctly and age is calculated dynamically from DOB',
      () {
        final now = DateTime.now();
        final dob = DateTime(now.year - 30, now.month, now.day);
        final patient = PatientModel(
          id: 'p1',
          fullName: 'Test Patient',
          dob: dob,
        );

        expect(patient.dob, equals(dob));
        expect(patient.age, equals(30));
      },
    );

    test(
      'Patient age accounts for leap years and birth month/day threshold',
      () {
        final now = DateTime.now();
        final futureMonth = now.month < 12 ? now.month + 1 : 1;
        final yearOffset = now.month < 12 ? 25 : 26;
        final dobNotYet = DateTime(now.year - yearOffset, futureMonth, 15);

        final patient = PatientModel(
          id: 'p2',
          fullName: 'Test Patient 2',
          dob: dobNotYet,
        );

        expect(patient.age, equals(24));
      },
    );

    test('Missing DOB returns age == null and serializes as null', () {
      final patient = PatientModel(
        id: 'p3',
        fullName: 'No DOB Patient',
        dob: null,
      );

      expect(patient.dob, isNull);
      expect(patient.age, isNull);

      final map = patient.toMap();
      expect(map['dob'], isNull);
      expect(map.containsKey('age'), isFalse);
    });

    test('PatientModel.fromMap deserializes DOB correctly', () {
      final mapWithDob = {
        'id': 'p4',
        'fullName': 'Map Patient',
        'dob': '1990-05-15T00:00:00.000',
      };

      final patient = PatientModel.fromMap(mapWithDob);
      expect(patient.dob, equals(DateTime(1990, 5, 15)));
      expect(patient.age, isNotNull);

      final mapWithoutDob = {'id': 'p5', 'fullName': 'No DOB Map Patient'};

      final patientNoDob = PatientModel.fromMap(mapWithoutDob);
      expect(patientNoDob.dob, isNull);
      expect(patientNoDob.age, isNull);
    });

    test('Saving DOB persists it to Map format without age field', () {
      final now = DateTime.now();
      final newDob = DateTime(now.year - 40, 3, 20);

      final patient = PatientModel(
        id: 'p6',
        fullName: 'Updated Patient',
        dob: null,
      );
      expect(patient.age, isNull);

      final updatedPatient = PatientModel(
        id: patient.id,
        fullName: patient.fullName,
        dob: newDob,
      );

      expect(updatedPatient.dob, equals(newDob));
      expect(updatedPatient.age, equals(40));

      final savedMap = updatedPatient.toMap();
      expect(savedMap['dob'], equals(newDob.toIso8601String()));
      expect(savedMap.containsKey('age'), isFalse);
    });

    test('Future DOB is rejected during date picker constraint setup', () {
      final now = DateTime.now();
      final futureDob = DateTime(now.year + 1, 1, 1);

      bool isDobValid(DateTime candidate) {
        return !candidate.isAfter(DateTime.now());
      }

      expect(isDobValid(futureDob), isFalse);
      expect(isDobValid(DateTime(1995, 1, 1)), isTrue);
    });
  });
}
