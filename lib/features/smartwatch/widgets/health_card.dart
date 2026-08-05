import 'package:flutter/material.dart';
import '../models/health_reading_model.dart';

class HealthCard extends StatelessWidget {
  const HealthCard({super.key, required this.reading, required this.title});

  final HealthReadingModel reading;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HR: ${reading.heartRate} bpm'),
                      Text('SpO₂: ${reading.spo2}%'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Temp: ${reading.temperature.toStringAsFixed(1)}°C'),
                      Text('Steps: ${reading.steps}'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
