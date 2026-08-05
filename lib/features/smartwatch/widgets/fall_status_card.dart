import 'package:flutter/material.dart';
import '../models/fall_event_model.dart';

class FallStatusCard extends StatelessWidget {
  const FallStatusCard({super.key, required this.event});

  final FallEventModel event;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              event.detected ? Icons.warning : Icons.check_circle,
              color: event.detected ? Colors.orange : Colors.green,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.detected ? 'Fall Detected' : 'Monitoring',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    event.time?.toLocal().toIso8601String() ?? 'No events',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (event.confirmed) Chip(label: const Text('Confirmed')),
          ],
        ),
      ),
    );
  }
}
