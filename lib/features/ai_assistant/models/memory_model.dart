class MemoryModel {
  MemoryModel({
    required this.id,
    required this.title,
    this.details = '',
    this.category = 'Personal',
    this.time,
    this.people = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  String title;
  String details;
  String category;
  DateTime? time;
  List<String> people;
  DateTime? createdAt;
  DateTime? updatedAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'details': details,
    'category': category,
    'time': time?.toIso8601String(),
    'people': people,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  static MemoryModel fromMap(Map<String, dynamic> map, {String? documentId}) {
    DateTime? parseDateTime(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      try {
        final dynamic t = val;
        return t.toDate() as DateTime;
      } catch (_) {
        return null;
      }
    }

    final rawPeople = map['people'];
    List<String> parsedPeople = const [];
    if (rawPeople is List) {
      parsedPeople = rawPeople.map((e) => e.toString()).toList();
    }

    final rawCategory = map['category'] as String?;

    return MemoryModel(
      id: (documentId != null && documentId.isNotEmpty)
          ? documentId
          : (map['id'] as String? ?? ''),
      title: map['title'] as String? ?? '',
      details: map['details'] as String? ?? '',
      category: (rawCategory != null && rawCategory.trim().isNotEmpty)
          ? rawCategory.trim()
          : 'Personal',
      time: parseDateTime(map['time']),
      people: parsedPeople,
      createdAt: parseDateTime(map['createdAt']),
      updatedAt: parseDateTime(map['updatedAt']),
    );
  }
}
