import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../services/ai_service_exception.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/empty_conversation.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({this.initialPrompt = '', this.service, super.key});

  final String initialPrompt;
  final AIService? service;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  bool _typing = false;

  AIService get _service => widget.service ?? AIService.instance;

  @override
  void initState() {
    super.initState();
    if (widget.initialPrompt.isNotEmpty) {
      _controller.text = widget.initialPrompt;
    }
    _service.initMock();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _typing) return;
    setState(() {
      _typing = true;
    });
    _controller.clear();
    try {
      await _service.sendMessage(text);
    } on AIServiceException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _typing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final msgs = _service.getMessages();
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
