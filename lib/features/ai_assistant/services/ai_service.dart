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

  Future<String> generateResponse(
    String text, {
    List<ChatMessageModel> history = const [],
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return _generateResponse(text);
  }

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
    final responseText = await generateResponse(text, history: _messages);
    final response = ChatMessageModel(
      id: 'a${DateTime.now().millisecondsSinceEpoch}',
      text: responseText,
      sender: 'ai',
      time: DateTime.now(),
    );
    _messages.add(response);
    return response;
  }

  List<ChatMessageModel> getMessages() => List.unmodifiable(_messages);

  ChatMessageModel addUserMessage(String text) {
    final message = ChatMessageModel(
      id: 'u${DateTime.now().microsecondsSinceEpoch}',
      text: text,
      sender: 'user',
      time: DateTime.now(),
    );
    _messages.add(message);
    return message;
  }

  ChatMessageModel addAssistantMessage(String text) {
    final message = ChatMessageModel(
      id: 'a${DateTime.now().microsecondsSinceEpoch}',
      text: text,
      sender: 'ai',
      time: DateTime.now(),
    );
    _messages.add(message);
    return message;
  }

  void clearConversation() => _messages.clear();
  List<MemoryModel> getMemories() => List.unmodifiable(_memories);
  List<ExerciseModel> getExercises() => List.unmodifiable(_exercises);
  List<InsightModel> getInsights() => List.unmodifiable(_insights);

  String _generateResponse(String text) {
    final lowerText = text.toLowerCase();
    if (lowerText.contains('emergency') ||
        lowerText.contains('can\'t breathe') ||
        lowerText.contains('cannot breathe') ||
        lowerText.contains('chest pain')) {
      return 'If this may be an emergency, contact your local emergency services '
          'now or ask a trusted person nearby for immediate help. I am not an emergency responder.';
    }
    if (lowerText.contains('med')) {
      return 'I can share general information, but I cannot recommend medication or doses. '
          'Please check your care plan or ask a qualified healthcare professional.';
    }
    if (lowerText.contains('yesterday')) {
      return 'Yesterday you had a doctor appointment and took morning medication.';
    }
    if (lowerText.contains('caregiver')) {
      return 'I cannot contact a caregiver from this chat. Please use the caregiver '
          'contact options or reach out to a trusted person directly.';
    }
    return 'I\'m ready to help — tell me more.';
  }
}
