import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/caregiver/models/alert_model.dart';
import 'package:app/features/caregiver/services/caregiver_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Caregiver SOS Alert Dismissal Tests', () {
    test('dismissed SOS alert is excluded from active getAlerts()', () async {
      final service = CaregiverService.instance;
      service.alerts.clear();

      final sosAlert = AlertModel(
        id: 'sos_test_101',
        title: '🚨 SOS EMERGENCY ALERT - John',
        type: AlertType.fall,
        details: 'Fall detected',
        time: DateTime.now(),
        severity: 5,
        isRead: false,
        isDismissed: false,
        patientId: 'p_test_101',
      );

      await service.addAlert(sosAlert);
      expect(service.getAlerts().length, equals(1));
      expect(service.getAlerts().first.id, equals('sos_test_101'));

      await service.dismissAlert('sos_test_101');

      // Filtered out from active getAlerts()
      expect(service.getAlerts().length, equals(0));

      // Retained in memory as dismissed
      expect(service.alerts.length, equals(1));
      expect(service.alerts.first.isDismissed, isTrue);
    });

    test('AlertModel.toMap includes both time and timestamp fields', () {
      final alert = AlertModel(
        id: 'sos_test_102',
        title: 'Test Alert',
        time: DateTime.parse('2026-08-27T12:00:00.000Z'),
        isDismissed: true,
      );

      final map = alert.toMap();
      expect(map['time'], equals('2026-08-27T12:00:00.000Z'));
      expect(map['timestamp'], equals('2026-08-27T12:00:00.000Z'));
      expect(map['isDismissed'], isTrue);
    });
  });
}
