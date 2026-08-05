import 'package:flutter/material.dart';
import '../../../core/widgets/app_cards.dart';

class ReminderStatisticsCard extends StatelessWidget {
  const ReminderStatisticsCard({required this.stats, super.key});

  final Map<String, String> stats;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats.entries
            .map(
              (e) => Column(
                children: [
                  Text(e.key, style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 6),
                  Text(
                    e.value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
