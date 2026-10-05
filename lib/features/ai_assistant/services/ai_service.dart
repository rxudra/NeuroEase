import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/ai_request_model.dart';
import '../models/chat_message_model.dart';
import '../models/memory_model.dart';
import '../models/exercise_model.dart';
import '../models/insight_model.dart';
import 'ai_gateway.dart';
import 'ai_service_exception.dart';
import 'firebase_ai_gateway.dart';

class AIService {
  AIService._private({AIGateway? gateway})
    : _gateway = gateway ?? FirebaseAIGateway();

  factory AIService.custom({required AIGateway gateway}) {
    return AIService._private(gateway: gateway);
  }

  static final AIService instance = AIService._private();

  final AIGateway _gateway;
  final List<ChatMessageModel> _messages = [];
  final List<MemoryModel> _memories = [];
  final List<ExerciseModel> _exercises = [];
  final List<InsightModel> _insights = [];

  void initMock() {
    if (_memories.isNotEmpty) return;
    _memories.addAll([
      MemoryModel(
        id: 'm1',
        title: "Doctor's appointment",
        details: 'Scheduled yesterday at 3pm',
        time: DateTime.now().subtract(const Duration(days: 1)),
      ),
      MemoryModel(
        id: 'm2',
        title: 'Took morning meds',
        details: 'Amlodipine and Metformin',
        time: DateTime.now().subtract(const Duration(hours: 20)),
      ),
    ]);

    _exercises.addAll([
      ExerciseModel(
        id: 'e1',
        title: 'Remember Sequence',
        description: 'Tap the sequence in order',
        difficulty: 2,
      ),
      ExerciseModel(
        id: 'e2',
        title: 'Face Matching',
        description: 'Match faces shown earlier',
        difficulty: 3,
      ),
    ]);

    _insights.addAll([
      InsightModel(
        id: 'i1',
        title: 'Medication Adherence',
        value: '92%',
        trend: 1,
      ),
      InsightModel(id: 'i2', title: 'Memory Trend', value: 'Stable', trend: 0),
    ]);
  }

  Future<ChatMessageModel> sendMessage(String text) async {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) {
      throw const AIEmptyPromptException();
    }

    final user = ChatMessageModel(
      id: 'u${DateTime.now().millisecondsSinceEpoch}',
      text: normalizedText,
      sender: 'user',
      time: DateTime.now(),
    );
    _messages.add(user);

    try {
      final response = await _gateway.generateResponse(
        AIRequestModel(prompt: normalizedText),
      );
      final responseText = response.text.trim();
      if (responseText.isEmpty) {
        throw const AIEmptyResponseException();
      }

      final assistantMessage = ChatMessageModel(
        id: 'a${DateTime.now().millisecondsSinceEpoch}',
        text: responseText,
        sender: 'ai',
        time: DateTime.now(),
      );
      _messages.add(assistantMessage);
      return assistantMessage;
    } on AIServiceException catch (error) {
      debugPrint(
        '[AIService] AI service exception: '
        '${error.runtimeType}: $error',
      );
      rethrow;
    } on TimeoutException {
      debugPrint('[AIService] Request timed out.');
      throw const AITimeoutException();
    } catch (error) {
      debugPrint(
        '[AIService] Unexpected exception: '
        '${error.runtimeType}: $error',
      );
      throw const AIUnavailableException();
    }
  }

  List<ChatMessageModel> getMessages() => List.unmodifiable(_messages);
  List<MemoryModel> getMemories() => List.unmodifiable(_memories);
  List<ExerciseModel> getExercises() => List.unmodifiable(_exercises);
  List<InsightModel> getInsights() => List.unmodifiable(_insights);
}
