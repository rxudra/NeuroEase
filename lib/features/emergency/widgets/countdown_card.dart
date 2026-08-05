import 'package:flutter/material.dart';

class CountdownCard extends StatelessWidget {
  const CountdownCard({super.key, required this.secondsLeft});

  final int secondsLeft;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Countdown',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    '$secondsLeft seconds remaining',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(Icons.timer, color: Colors.orange, size: 32),
          ],
        ),
      ),
    );
  }
}
