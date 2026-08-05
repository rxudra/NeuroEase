import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../widgets/memory_card.dart';

class MemoryRecallScreen extends StatelessWidget {
  const MemoryRecallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final memories = AIService.instance.getMemories();
    return Scaffold(
      appBar: AppBar(title: const Text('Memories')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: memories
            .map(
              (m) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: MemoryCard(memory: m),
              ),
            )
            .toList(),
      ),
    );
  }
}
