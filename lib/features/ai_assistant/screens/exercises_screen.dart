import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../widgets/exercise_card.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ex = AIService.instance.getExercises();
    return Scaffold(
      appBar: AppBar(title: const Text('Cognitive Exercises')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: ex
            .map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ExerciseCard(exercise: e),
              ),
            )
            .toList(),
      ),
    );
  }
}
