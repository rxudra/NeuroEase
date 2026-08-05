import 'package:flutter/material.dart';

class EmptyConversation extends StatelessWidget {
  const EmptyConversation({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          Text('No messages yet', style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
