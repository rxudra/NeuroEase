import 'dart:math';

import '../models/watch_device_model.dart';
import '../models/sensor_model.dart';
import '../models/health_reading_model.dart';
import '../models/connection_status_model.dart';
import '../models/fall_event_model.dart';

class SmartwatchService {
  SmartwatchService._private();
  static final SmartwatchService instance = SmartwatchService._private();

  final List<WatchDeviceModel> devices = [];
  final List<SensorModel> sensors = [];
  HealthReadingModel latest = HealthReadingModel();
  ConnectionStatusModel connection = ConnectionStatusModel();
  final List<FallEventModel> falls = [];

  void initMock() {
    if (devices.isNotEmpty) return;
    devices.addAll([
      WatchDeviceModel(
        id: 'w1',
        name: 'NeuroWatch A1',
        batteryPct: 78,
        signal: 4,
        connected: true,
        firmware: '1.2.0',
      ),
      WatchDeviceModel(
        id: 'w2',
        name: 'NeuroWatch B2',
        batteryPct: 52,
        signal: 3,
        connected: false,
        firmware: '1.0.4',
      ),
    ]);

    sensors.addAll([
      SensorModel(
        id: 's1',
        name: 'Accelerometer',
        status: SensorStatus.connected,
      ),
      SensorModel(id: 's2', name: 'Gyroscope', status: SensorStatus.connected),
      SensorModel(id: 's3', name: 'GPS', status: SensorStatus.connected),
      SensorModel(id: 's4', name: 'Pulse', status: SensorStatus.connected),
      SensorModel(id: 's5', name: 'Temp', status: SensorStatus.connected),
    ]);

    latest = HealthReadingModel(
      heartRate: 72 + Random().nextInt(8),
      spo2: 95 + Random().nextInt(4),
      temperature: 36.4 + Random().nextDouble() * 0.6,
      steps: 1240,
      calories: 56,
      distanceMeters: 800,
    );
    connection = ConnectionStatusModel(status: ConnectionStatus.connected);

    falls.add(
      FallEventModel(
        id: 'f1',
        time: DateTime.now().subtract(const Duration(days: 2)),
        detected: true,
        confirmed: false,
      ),
    );
  }

  List<WatchDeviceModel> getDevices() => List.unmodifiable(devices);
  List<SensorModel> getSensors() => List.unmodifiable(sensors);
  HealthReadingModel getLatest() => latest;
  ConnectionStatusModel getConnection() => connection;
  List<FallEventModel> getFalls() => List.unmodifiable(falls);

  void simulateUpdate() {
    latest.heartRate = 60 + Random().nextInt(60);
    latest.spo2 = 92 + Random().nextInt(7);
    latest.temperature = 36 + Random().nextDouble() * 1.5;
    latest.steps += Random().nextInt(20);
    latest.calories += Random().nextInt(5);
    latest.distanceMeters += Random().nextInt(10);
  }

  void pairDevice(String id) {
    final d = devices.firstWhere(
      (x) => x.id == id,
      orElse: () => devices.first,
    );
    d.connected = true;
    connection.status = ConnectionStatus.connected;
  }

  void disconnectDevice(String id) {
    final d = devices.firstWhere(
      (x) => x.id == id,
      orElse: () => devices.first,
    );
    d.connected = false;
    connection.status = ConnectionStatus.disconnected;
  }
}
