import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == 'user';
    final alignment = isUser
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final colorScheme = Theme.of(context).colorScheme;
    final bg = isUser ? colorScheme.primary : colorScheme.surface;
    final textColor = isUser ? colorScheme.onPrimary : colorScheme.onSurface;
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 560),
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.text,
            style: TextStyle(color: textColor),
          ),
        ),
        Text(
          message.time != null
              ? message.time!
                    .toLocal()
                    .toIso8601String()
                    .split('T')
                    .last
                    .split('.')
                    .first
              : '',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
