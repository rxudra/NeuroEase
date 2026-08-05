import 'package:flutter/material.dart';

class ReminderChip extends StatelessWidget {
  const ReminderChip({required this.enabled, super.key});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(enabled ? 'Reminder on' : 'Reminder off'),
      backgroundColor: enabled ? Colors.green.shade50 : Colors.grey.shade200,
    );
  }
}
