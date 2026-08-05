class ExerciseModel {
  ExerciseModel({
    required this.id,
    required this.title,
    this.description = '',
    this.difficulty = 1,
    this.progress = 0,
  });

  final String id;
  String title;
  String description;
  int difficulty;
  int progress;
}
