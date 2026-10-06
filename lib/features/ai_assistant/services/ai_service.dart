import '../../memory/services/memory_service.dart';
import '../models/chat_message_model.dart';
import '../models/exercise_model.dart';
import '../models/insight_model.dart';
import '../models/memory_model.dart';

class AIService {
  AIService._private([this._memoryService]);

  static final AIService instance = AIService._private();

  /// Creates an instance with a custom [MemoryService] for testing.
  factory AIService.withMemoryService(MemoryService memoryService) {
    return AIService._private(memoryService);
  }

  final MemoryService? _memoryService;
  MemoryService get _effectiveMemoryService =>
      _memoryService ?? MemoryService.instance;

  final List<ChatMessageModel> _messages = [];
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
    if (_exercises.isNotEmpty) return;

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
  List<MemoryModel> getMemories() => _effectiveMemoryService.getMemories();
  List<ExerciseModel> getExercises() => List.unmodifiable(_exercises);
  List<InsightModel> getInsights() => List.unmodifiable(_insights);

  MemoryModel? _findRelevantMemory(String text) {
    final lowerText = text.toLowerCase();
    final memories = _effectiveMemoryService.getMemories();
    if (memories.isEmpty) return null;

    if (lowerText.contains('yesterday')) {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      for (final m in memories) {
        final titleLower = m.title.toLowerCase();
        final detailsLower = m.details.toLowerCase();
        if (titleLower.contains('yesterday') ||
            detailsLower.contains('yesterday')) {
          return m;
        }
        if (m.time != null) {
          final local = m.time!.toLocal();
          if (local.year == yesterday.year &&
              local.month == yesterday.month &&
              local.day == yesterday.day) {
            return m;
          }
        }
      }
      return null;
    }

    final words = lowerText
        .split(RegExp(r'\W+'))
        .where((w) => w.length > 3)
        .toList();

    for (final memory in memories) {
      final title = memory.title.toLowerCase();
      final details = memory.details.toLowerCase();
      final category = memory.category.toLowerCase();
      final people = memory.people.map((p) => p.toLowerCase()).join(' ');

      for (final word in words) {
        if (word == 'remember' ||
            word == 'happened' ||
            word == 'what' ||
            word == 'tell') {
          continue;
        }
        if (title.contains(word) ||
            details.contains(word) ||
            category.contains(word) ||
            people.contains(word)) {
          return memory;
        }
      }
    }

    return null;
  }

  String _generateResponse(String text) {
    final lowerText = text.toLowerCase();
    if (lowerText.contains('emergency') ||
        lowerText.contains('can\'t breathe') ||
        lowerText.contains('cannot breathe') ||
        lowerText.contains('chest pain')) {
      return 'If this is an emergency, call 112 for emergency assistance or 108 for medical/ambulance assistance in India. You can also use NeuroEase Emergency SOS or ask a trusted person nearby for immediate help. I am not an emergency responder.';
    }
    if (lowerText.contains('med')) {
      return 'I can share general information, but I cannot recommend medication or doses. '
          'Please check your care plan or ask a qualified healthcare professional.';
    }

    final relevantMemory = _findRelevantMemory(text);

    if (lowerText.contains('yesterday')) {
      if (relevantMemory != null) {
        final detailsStr = relevantMemory.details.isNotEmpty
            ? ' (${relevantMemory.details})'
            : '';
        return 'According to your memory journal: "${relevantMemory.title}"$detailsStr.';
      }
      return 'I don\'t have verified information about your activities from yesterday. '
          'Please check your schedule, memories, or ask your caregiver.';
    }

    if (relevantMemory != null) {
      final detailsStr = relevantMemory.details.isNotEmpty
          ? ' (${relevantMemory.details})'
          : '';
      return 'Found in your memory journal: "${relevantMemory.title}"$detailsStr.';
    }

    if (lowerText.contains('caregiver')) {
      return 'I cannot contact a caregiver from this chat. Please use the caregiver '
          'contact options or reach out to a trusted person directly.';
    }
    return 'I\'m ready to help — tell me more.';
  }
}
