import 'package:flutter/material.dart';
import '../models/connection_status_model.dart';

class ConnectionChip extends StatelessWidget {
  const ConnectionChip({super.key, required this.status});

  final ConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status == ConnectionStatus.connected
        ? Colors.green
        : (status == ConnectionStatus.connecting ? Colors.orange : Colors.grey);
    return Chip(
      label: Text(status.name),
      backgroundColor: color.withValues(alpha: 0.31),
    );
  }
}
