class MedicationModel {
  MedicationModel({
    required this.id,
    required this.name,
    this.dosage = '',
    this.schedule = '',
  });

  final String id;
  final String name;
  final String dosage;
  final String schedule;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'dosage': dosage,
    'schedule': schedule,
  };
  static MedicationModel fromMap(Map<String, dynamic> m) => MedicationModel(
    id: m['id'] ?? '',
    name: m['name'] ?? '',
    dosage: m['dosage'] ?? '',
    schedule: m['schedule'] ?? '',
  );
}
