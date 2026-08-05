import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../widgets/insight_card.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = AIService.instance.getInsights();
    return Scaffold(
      appBar: AppBar(title: const Text('AI Insights')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: items
            .map(
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: InsightCard(insight: i),
              ),
            )
            .toList(),
      ),
    );
  }
}
