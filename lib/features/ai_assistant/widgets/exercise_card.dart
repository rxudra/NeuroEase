import 'package:flutter/material.dart';
import '../models/exercise_model.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({super.key, required this.exercise});

  final ExerciseModel exercise;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(exercise.title),
        subtitle: Text(exercise.description),
        trailing: Text('Diff ${exercise.difficulty}'),
      ),
    );
  }
}
