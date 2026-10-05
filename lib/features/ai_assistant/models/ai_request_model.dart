class AIRequestModel {
  const AIRequestModel({required this.prompt});

  final String prompt;

  Map<String, dynamic> toMap() => {'prompt': prompt};
}