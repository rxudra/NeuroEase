import 'package:flutter/material.dart';

class TaskChip extends StatelessWidget {
  const TaskChip({required this.label, this.color, super.key});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: color ?? Theme.of(context).colorScheme.primaryContainer,
    );
  }
}
