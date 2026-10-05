import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/ai_assistant/models/ai_request_model.dart';
import 'package:app/features/ai_assistant/models/ai_response_model.dart';
import 'package:app/features/ai_assistant/services/ai_gateway.dart';
import 'package:app/features/ai_assistant/services/ai_service.dart';
import 'package:app/features/ai_assistant/services/ai_service_exception.dart';

class FakeAIGateway implements AIGateway {
  FakeAIGateway({this.response = 'A safe response.'});

  String response;
  AIRequestModel? receivedRequest;
  Object? error;

  @override
  Future<AIResponseModel> generateResponse(AIRequestModel request) async {
    receivedRequest = request;
    if (error != null) throw error!;
    return AIResponseModel(text: response);
  }
}

void main() {
  group('AIService', () {
    test('sends only the user prompt through the gateway', () async {
      final gateway = FakeAIGateway();
      final service = AIService.custom(gateway: gateway);

      final response = await service.sendMessage('Hello');

      expect(gateway.receivedRequest?.prompt, 'Hello');
      expect(response.text, 'A safe response.');
      expect(service.getMessages(), hasLength(2));
    });

    test('rejects an empty prompt without calling the gateway', () async {
      final gateway = FakeAIGateway();
      final service = AIService.custom(gateway: gateway);

      await expectLater(
        service.sendMessage('  '),
        throwsA(isA<AIEmptyPromptException>()),
      );
      expect(gateway.receivedRequest, isNull);
    });

    test('reports an invalid prompt separately from an invalid response', () async {
      final gateway = FakeAIGateway()..error = const AIInvalidPromptException();
      final service = AIService.custom(gateway: gateway);

      await expectLater(
        service.sendMessage('Hello'),
        throwsA(isA<AIInvalidPromptException>()),
      );
    });

    test('does not add an empty assistant response', () async {
      final gateway = FakeAIGateway(response: '   ');
      final service = AIService.custom(gateway: gateway);

      await expectLater(
        service.sendMessage('Hello'),
        throwsA(isA<AIEmptyResponseException>()),
      );
      expect(service.getMessages(), hasLength(1));
    });

    test('converts gateway timeouts to a controlled exception', () async {
      final gateway = FakeAIGateway()..error = const AITimeoutException();
      final service = AIService.custom(gateway: gateway);

      await expectLater(
        service.sendMessage('Hello'),
        throwsA(isA<AITimeoutException>()),
      );
    });

    test('converts unexpected gateway failures to unavailable errors', () async {
      final gateway = FakeAIGateway()..error = StateError('offline');
      final service = AIService.custom(gateway: gateway);

      await expectLater(
        service.sendMessage('Hello'),
        throwsA(isA<AIUnavailableException>()),
      );
    });
  });
}