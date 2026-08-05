import 'package:flutter/material.dart';
import '../models/memory_model.dart';

class MemoryCard extends StatelessWidget {
  const MemoryCard({super.key, required this.memory});

  final MemoryModel memory;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(memory.title),
        subtitle: Text(memory.details),
      ),
    );
  }
}
