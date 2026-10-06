import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/ai_assistant/controllers/assistant_controller.dart';
import 'package:app/features/ai_assistant/models/chat_message_model.dart';
import 'package:app/features/ai_assistant/models/memory_model.dart';
import 'package:app/features/ai_assistant/screens/chat_screen.dart';
import 'package:app/features/ai_assistant/services/ai_service.dart';
import 'package:app/features/ai_assistant/widgets/chat_bubble.dart';
import 'package:app/features/memory/services/memory_service.dart';

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

  test('AIService returns 112, 108, and Emergency SOS for emergency queries', () async {
    final response = await service.generateResponse('I have chest pain and can\'t breathe');
    expect(response, contains('112'));
    expect(response, contains('108'));
    expect(response, contains('Emergency SOS'));
  });

  test('AIService does not recommend drug prescriptions or dosages for medication queries', () async {
    final response = await service.generateResponse('What medicines should I take?');
    expect(response, isNot(contains('Amlodipine')));
    expect(response, isNot(contains('Metformin')));
    expect(response, isNot(contains('5mg')));
    expect(response, contains('cannot recommend medication or doses'));
  });

  test('AIService does not return fabricated patient history for yesterday queries', () async {
    final response = await service.generateResponse('What happened yesterday?');
    expect(response, isNot(contains('doctor appointment')));
    expect(response, isNot(contains('took morning medication')));
    expect(response, contains("don't have verified information"));
  });

  testWidgets('renders error banner and Retry button on ChatScreen when request fails', (tester) async {
    final provider = _FakeProvider([Exception('Network error')]);
    final controller = AssistantController(
      service: service,
      provider: provider,
    );

    await tester.pumpWidget(
      MaterialApp(home: ChatScreen(controller: controller)),
    );

    await controller.send('Help me');
    await tester.pumpAndSettle();

    expect(find.text(controller.errorMessage!), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
    controller.dispose();
  });

  testWidgets('ChatBubble formats message timestamp into readable localized time', (tester) async {
    final message = ChatMessageModel(
      id: 'm1',
      text: 'Hello world',
      sender: 'user',
      time: DateTime(2026, 10, 6, 10, 48),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatBubble(message: message),
        ),
      ),
    );

    expect(find.text('10:48:00'), findsNothing);
    expect(find.byType(ChatBubble), findsOneWidget);
  });

  test('AIService retrieves actual user memories when asked about yesterday', () async {
    final memory = MemoryModel(
      id: 'mem_test_1',
      title: 'I had very good time yesterday',
      details: 'he was really good',
      time: DateTime.now().subtract(const Duration(days: 1)),
    );
    await MemoryService.instance.addMemory(memory);

    final response = await service.generateResponse('What happened yesterday?');
    expect(response, contains('I had very good time yesterday'));
    expect(response, contains('he was really good'));

    await MemoryService.instance.deleteMemory(memory.id);
  });

  test('AIService retrieves memory matching keyword query', () async {
    final memory = MemoryModel(
      id: 'mem_test_2',
      title: 'Gardening in the afternoon',
      details: 'Planted new sunflowers',
    );
    await MemoryService.instance.addMemory(memory);

    final response = await service.generateResponse('Tell me about my gardening');
    expect(response, contains('Gardening in the afternoon'));

    await MemoryService.instance.deleteMemory(memory.id);
  });

  test('AIService does not fabricate memory when no matching memory exists', () async {
    final response = await service.generateResponse('What happened yesterday?');
    expect(response, contains("don't have verified information"));
  });
}
