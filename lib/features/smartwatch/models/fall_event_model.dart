class FallEventModel {
  FallEventModel({
    required this.id,
    this.time,
    this.detected = false,
    this.confirmed = false,
  });

  final String id;
  DateTime? time;
  bool detected;
  bool confirmed;
}
