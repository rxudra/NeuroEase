import 'package:flutter/material.dart';
import '../../../core/widgets/app_cards.dart';
import 'progress_widget.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    required this.total,
    required this.taken,
    required this.missed,
    super.key,
  });

  final int total;
  final int taken;
  final int missed;

  @override
  Widget build(BuildContext context) {
    final remaining = total - taken - missed;
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Today', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Text(
                  '$total medicines',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              ProgressWidget(progress: total == 0 ? 0 : (taken / total)),
              const SizedBox(height: 8),
              Text(
                '$taken taken',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Text('Missed', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 6),
              Text(
                '$missed',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.red),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Text('Remaining', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 6),
              Text(
                '$remaining',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
