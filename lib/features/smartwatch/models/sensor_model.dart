enum SensorStatus { connected, disconnected, unknown }

class SensorModel {
  SensorModel({
    required this.id,
    required this.name,
    this.status = SensorStatus.unknown,
  });

  final String id;
  String name;
  SensorStatus status;
}
