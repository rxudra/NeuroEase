import 'package:flutter/material.dart';
import '../../../core/widgets/app_cards.dart';

class CompletionProgress extends StatelessWidget {
  const CompletionProgress({required this.percent, super.key});

  final double percent; // 0.0 - 1.0

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today completion',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: percent),
                const SizedBox(height: 8),
                Text('${(percent * 100).toStringAsFixed(0)}%'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
