import 'package:flutter/material.dart';
import '../../../core/widgets/app_cards.dart';

class ReminderProgressCard extends StatelessWidget {
  const ReminderProgressCard({required this.percent, super.key});

  final double percent;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Completion', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: percent),
          const SizedBox(height: 8),
          Text('${(percent * 100).toStringAsFixed(0)}%'),
        ],
      ),
    );
  }
}
