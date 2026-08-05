class WatchDeviceModel {
  WatchDeviceModel({
    required this.id,
    required this.name,
    this.batteryPct = 85,
    this.signal = 4,
    this.connected = false,
    this.firmware = '1.0.0',
  });

  final String id;
  String name;
  int batteryPct;
  int signal; // 0-5
  bool connected;
  String firmware;
}
