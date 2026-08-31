class EmergencyStatusModel {
  EmergencyStatusModel({
    this.gpsOk = true,
    this.internetOk = true,
    this.sensorConnected = false,
    this.sensorDeviceName = 'No Sensor Connected',
    this.batteryPct = 0,
  });

  bool gpsOk;
  bool internetOk;
  bool sensorConnected;
  String sensorDeviceName;
  int batteryPct;
}
