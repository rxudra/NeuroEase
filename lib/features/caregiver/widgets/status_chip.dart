import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({required this.label, this.online = false, super.key});

  final String label;
  final bool online;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: online
          ? Colors.green.withValues(alpha: 31)
          : Colors.grey.withValues(alpha: 20),
    );
  }
}
