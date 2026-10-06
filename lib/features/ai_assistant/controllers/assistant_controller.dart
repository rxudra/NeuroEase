import 'package:flutter/foundation.dart';

import '../models/chat_message_model.dart';
import '../services/ai_service.dart';

abstract interface class AssistantProvider {
  Future<String> generateResponse(
    String text, {
    required List<ChatMessageModel> history,
  });
}

class AIServiceProvider implements AssistantProvider {
  AIServiceProvider({AIService? service}) : _service = service ?? AIService.instance;

  final AIService _service;

  @override
  Future<String> generateResponse(
    String text, {
    required List<ChatMessageModel> history,
  }) {
    return _service.generateResponse(text, history: history);
  }
}

class AssistantController extends ChangeNotifier {
  AssistantController({
    AssistantProvider? provider,
    AIService? service,
  }) : _provider = provider ?? AIServiceProvider(service: service),
       _service = service ?? AIService.instance;

  final AssistantProvider _provider;
  final AIService _service;
  bool isLoading = false;
  String? errorMessage;
  String? _failedText;

  List<ChatMessageModel> get messages => _service.getMessages();

  Future<void> send(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || isLoading) return;

    _failedText = null;
    errorMessage = null;
    _service.addUserMessage(text);
    notifyListeners();
    await _requestResponse(text);
  }

  Future<void> retry() async {
    final text = _failedText;
    if (text == null || isLoading) return;

    errorMessage = null;
    notifyListeners();
    await _requestResponse(text);
  }

  void clearConversation() {
    if (isLoading) return;
    _service.clearConversation();
    errorMessage = null;
    _failedText = null;
    notifyListeners();
  }

  Future<void> _requestResponse(String text) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await _provider.generateResponse(
        text,
        history: messages,
      );
      _service.addAssistantMessage(response);
      _failedText = null;
    } catch (_) {
      _failedText = text;
      errorMessage =
          'I could not respond right now. Please check your connection and try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
