class InsightModel {
  InsightModel({
    required this.id,
    required this.title,
    this.value = '',
    this.trend = 0,
  });

  final String id;
  String title;
  String value;
  int trend; // -1,0,1
}
