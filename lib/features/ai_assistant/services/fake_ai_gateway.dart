import 'dart:async';

import '../models/ai_request_model.dart';
import '../models/ai_response_model.dart';
import 'ai_gateway.dart';

/// Temporary local gateway for development and unit tests; this is not Gemini.
class FakeAIGateway implements AIGateway {
  FakeAIGateway({
    this.response = 'I am the local NeuroEase assistant.',
    this.delay = const Duration(milliseconds: 250),
    this.error,
  });

  final String response;
  final Duration delay;
  final Object? error;
  AIRequestModel? lastRequest;

  @override
  Future<AIResponseModel> generateResponse(AIRequestModel request) async {
    lastRequest = request;
    await Future<void>.delayed(delay);
    if (error != null) throw error!;
    return AIResponseModel(text: response);
  }
}