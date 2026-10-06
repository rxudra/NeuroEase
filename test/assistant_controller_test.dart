import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/ai_assistant/controllers/assistant_controller.dart';
import 'package:app/features/ai_assistant/models/chat_message_model.dart';
import 'package:app/features/ai_assistant/screens/chat_screen.dart';
import 'package:app/features/ai_assistant/services/ai_service.dart';

class _FakeProvider implements AssistantProvider {
  _FakeProvider(this.responses);

  final List<Object> responses;
  int calls = 0;

  @override
  Future<String> generateResponse(
    String text, {
    required List<ChatMessageModel> history,
  }) async {
    final response = responses[calls++];
    if (response is Exception) throw response;
    return response as String;
  }
}

void main() {
  late AIService service;

  setUp(() {
    service = AIService.instance;
    service.clearConversation();
  });

  testWidgets('renders the assistant chat controls', (tester) async {
    final controller = AssistantController(
      service: service,
      provider: _FakeProvider(['Hello']),
    );

    await tester.pumpWidget(
      MaterialApp(home: ChatScreen(controller: controller)),
    );

    expect(find.text('AI Assistant'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Message'), findsOneWidget);
    expect(find.byTooltip('Send message'), findsOneWidget);
    expect(find.byTooltip('Clear conversation'), findsOneWidget);
    controller.dispose();
  });

  test('sends a message and stores the successful response', () async {
    final provider = _FakeProvider(['Hello back']);
    final controller = AssistantController(
      service: service,
      provider: provider,
    );

    final future = controller.send('Hi');
    expect(controller.messages.single.text, 'Hi');
    expect(controller.isLoading, isTrue);
    await future;

    expect(controller.messages.map((message) => message.text), [
      'Hi',
      'Hello back',
    ]);
    expect(controller.isLoading, isFalse);
    controller.dispose();
  });

  test('ignores empty input without requesting a response', () async {
    final provider = _FakeProvider(['Unexpected']);
    final controller = AssistantController(
      service: service,
      provider: provider,
    );

    await controller.send('   ');

    expect(controller.messages, isEmpty);
    expect(provider.calls, 0);
    controller.dispose();
  });

  test('exposes an error and retries the failed request', () async {
    final provider = _FakeProvider([
      Exception('offline'),
      'Recovered',
    ]);
    final controller = AssistantController(
      service: service,
      provider: provider,
    );

    await controller.send('Help');
    expect(controller.errorMessage, isNotNull);
    expect(controller.messages.single.text, 'Help');

    await controller.retry();

    expect(controller.errorMessage, isNull);
    expect(controller.messages.last.text, 'Recovered');
    expect(provider.calls, 2);
    controller.dispose();
  });

  testWidgets('clears the conversation', (tester) async {
    final controller = AssistantController(
      service: service,
      provider: _FakeProvider(['Hello']),
    );
    await controller.send('Hi');

    await tester.pumpWidget(
      MaterialApp(home: ChatScreen(controller: controller)),
    );
    await tester.tap(find.byTooltip('Clear conversation'));
    await tester.pump();

    expect(controller.messages, isEmpty);
    expect(find.text('No messages yet'), findsOneWidget);
    controller.dispose();
  });
}
