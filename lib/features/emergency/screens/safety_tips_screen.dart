import 'package:flutter/material.dart';
import '../widgets/safety_card.dart';

class SafetyTipsScreen extends StatelessWidget {
  const SafetyTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Tips')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SafetyCard(
            title: 'Emergency Tips',
            body: 'Stay calm. Call for help.',
          ),
          SizedBox(height: 12),
          SafetyCard(
            title: 'Medication Safety',
            body: 'Keep meds in labelled containers.',
          ),
          SizedBox(height: 12),
          SafetyCard(
            title: 'Dementia Safety',
            body: 'Use door alarms and ID bracelets.',
          ),
          SizedBox(height: 12),
          SafetyCard(
            title: 'Travel Safety',
            body: 'Share itinerary with family.',
          ),
          SizedBox(height: 12),
          SafetyCard(
            title: 'Night Safety',
            body: 'Keep night lights on in hallways.',
          ),
        ],
      ),
    );
  }
}
