import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/empty_conversation.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({this.initialPrompt = '', super.key});

  final String initialPrompt;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  bool _typing = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPrompt.isNotEmpty) {
      _controller.text = widget.initialPrompt;
    }
    AIService.instance.initMock();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _typing = true;
    });
    _controller.clear();
    await AIService.instance.sendMessage(text);
    setState(() {
      _typing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final msgs = AIService.instance.getMessages();
    return Scaffold(
      appBar: AppBar(title: const Text('AI Chat')),
      body: Column(
        children: [
          Expanded(
            child: msgs.isEmpty
                ? const EmptyConversation()
                : ListView.builder(
                    itemCount: msgs.length,
                    itemBuilder: (ctx, i) => ChatBubble(message: msgs[i]),
                  ),
          ),
          if (_typing)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: TypingIndicator(),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                      ),
                    ),
                  ),
                  IconButton(onPressed: _send, icon: const Icon(Icons.send)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
