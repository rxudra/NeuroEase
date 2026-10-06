import 'package:flutter/material.dart';
import '../controllers/assistant_controller.dart';
import '../services/ai_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/empty_conversation.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    this.initialPrompt = '',
    this.controller,
    super.key,
  });

  final String initialPrompt;
  final AssistantController? controller;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  late final AssistantController _assistantController;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _assistantController =
        widget.controller ?? AssistantController(service: AIService.instance);
    _assistantController.addListener(_onAssistantChanged);
    if (widget.initialPrompt.isNotEmpty) {
      _controller.text = widget.initialPrompt;
    }
    AIService.instance.initMock();
  }

  @override
  void dispose() {
    _assistantController.removeListener(_onAssistantChanged);
    if (widget.controller == null) {
      _assistantController.dispose();
    }
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onAssistantChanged() {
    if (!mounted) return;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    if (_assistantController.isLoading) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await _assistantController.send(text);
  }

  @override
  Widget build(BuildContext context) {
    final msgs = _assistantController.messages;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          IconButton(
            tooltip: 'Clear conversation',
            onPressed: _assistantController.isLoading ||
                    msgs.isEmpty
                ? null
                : _assistantController.clearConversation,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: msgs.isEmpty
                ? const EmptyConversation()
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: msgs.length,
                    itemBuilder: (ctx, i) => ChatBubble(message: msgs[i]),
                  ),
          ),
          if (_assistantController.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: TypingIndicator(),
            ),
          if (_assistantController.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _assistantController.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _assistantController.retry,
                    child: const Text('Retry'),
                  ),
                ],
              ),
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
                        labelText: 'Message',
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Send message',
                    onPressed: _assistantController.isLoading ? null : _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
