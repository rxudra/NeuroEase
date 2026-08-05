import 'package:flutter/material.dart';
import '../widgets/ai_avatar.dart';
import '../widgets/suggestion_chip.dart';
import 'chat_screen.dart';
import 'memory_recall_screen.dart';
import 'exercises_screen.dart';
import 'insights_screen.dart';
import '../services/ai_service.dart';

class AIHomeScreen extends StatefulWidget {
  const AIHomeScreen({super.key});

  @override
  State<AIHomeScreen> createState() => _AIHomeScreenState();
}

class _AIHomeScreenState extends State<AIHomeScreen> {
  @override
  void initState() {
    super.initState();
    AIService.instance.initMock();
  }

  void _openChat([String seed = '']) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ChatScreen(initialPrompt: seed)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                AIAvatar(size: 56),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Good morning, I\'m NeuroAI — Ready to help',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                SuggestionChip(
                  label: 'What medicines should I take?',
                  onTap: () => _openChat('What medicines should I take?'),
                ),
                SuggestionChip(
                  label: 'What happened yesterday?',
                  onTap: () => _openChat('What happened yesterday?'),
                ),
                SuggestionChip(
                  label: 'Call my caregiver',
                  onTap: () => _openChat('Call my caregiver'),
                ),
                SuggestionChip(
                  label: 'Tell me today\'s schedule',
                  onTap: () => _openChat('Tell me today\'s schedule'),
                ),
                SuggestionChip(
                  label: 'Memory Exercise',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ExercisesScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _openChat(),
                  child: const Text('Chat'),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MemoryRecallScreen(),
                    ),
                  ),
                  child: const Text('Memories'),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const InsightsScreen()),
                  ),
                  child: const Text('Insights'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
