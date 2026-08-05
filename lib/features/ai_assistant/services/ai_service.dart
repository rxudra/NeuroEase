import 'dart:async';

import '../models/chat_message_model.dart';
import '../models/memory_model.dart';
import '../models/exercise_model.dart';
import '../models/insight_model.dart';

class AIService {
  AIService._private();
  static final AIService instance = AIService._private();

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
    final user = ChatMessageModel(
      id: 'u${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      sender: 'user',
      time: DateTime.now(),
    );
    _messages.add(user);
    // Simulate thinking
    await Future.delayed(const Duration(milliseconds: 700));
    final response = ChatMessageModel(
      id: 'a${DateTime.now().millisecondsSinceEpoch}',
      text: _generateResponse(text),
      sender: 'ai',
      time: DateTime.now(),
    );
    _messages.add(response);
    return response;
  }

  List<ChatMessageModel> getMessages() => List.unmodifiable(_messages);
  List<MemoryModel> getMemories() => List.unmodifiable(_memories);
  List<ExerciseModel> getExercises() => List.unmodifiable(_exercises);
  List<InsightModel> getInsights() => List.unmodifiable(_insights);

  String _generateResponse(String text) {
    if (text.toLowerCase().contains('med')) {
      return 'Take Amlodipine 5mg in the morning and Metformin 500mg after breakfast.';
    }
    if (text.toLowerCase().contains('yesterday')) {
      return 'Yesterday you had a doctor appointment and took morning medication.';
    }
    if (text.toLowerCase().contains('caregiver')) {
      return 'Would you like me to call Priya Sharma? (mock)';
    }
    return 'I\'m ready to help — tell me more.';
  }
}
