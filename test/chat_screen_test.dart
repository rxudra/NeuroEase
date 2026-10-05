import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/ai_assistant/screens/chat_screen.dart';
import 'package:app/features/ai_assistant/services/ai_service.dart';
import 'package:app/features/ai_assistant/services/fake_ai_gateway.dart';
import 'package:app/features/ai_assistant/widgets/typing_indicator.dart';

void main() {
  testWidgets('shows and clears the loading indicator', (tester) async {
    final service = AIService.custom(
      gateway: FakeAIGateway(delay: const Duration(milliseconds: 100)),
    );

    await tester.pumpWidget(
      MaterialApp(home: ChatScreen(service: service)),
    );
    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    expect(find.byType(TypingIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byType(TypingIndicator), findsNothing);
  });
}