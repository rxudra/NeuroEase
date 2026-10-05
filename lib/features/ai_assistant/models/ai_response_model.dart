import '../services/ai_service_exception.dart';

class AIResponseModel {
  const AIResponseModel({required this.text});

  factory AIResponseModel.fromMap(Map<String, dynamic> map) {
    final value = map['response'];
    if (value is! String) {
      throw const AIInvalidResponseException();
    }

    final text = value.trim();
    if (text.isEmpty) {
      throw const AIEmptyResponseException();
    }
    return AIResponseModel(text: text);
  }

  final String text;
}