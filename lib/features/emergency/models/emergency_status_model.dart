class EmergencyStatusModel {
  EmergencyStatusModel({
    this.gpsOk = true,
    this.internetOk = true,
    this.watchConnected = true,
    this.batteryPct = 85,
    this.heartRate = 72,
    this.spo2 = 98,
  });

  bool gpsOk;
  bool internetOk;
  bool watchConnected;
  int batteryPct;
  int heartRate;
  int spo2;
}
