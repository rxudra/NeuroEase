class MemoryModel {
  MemoryModel({
    required this.id,
    required this.title,
    this.details = '',
    this.time,
  });

  final String id;
  String title;
  String details;
  DateTime? time;
}
