import 'package:flutter/material.dart';
import '../../../core/widgets/app_cards.dart';

class ScheduleTimeline extends StatelessWidget {
  const ScheduleTimeline({required this.items, super.key});

  final List<Map<String, String>> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((it) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: AppCard(
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      it['time'] ?? '',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      it['period'] ?? '',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Container(
                  width: 2,
                  height: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        it['title'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      if (it['subtitle'] != null) Text(it['subtitle'] ?? ''),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
