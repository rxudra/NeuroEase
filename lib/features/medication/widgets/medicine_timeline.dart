import 'package:flutter/material.dart';
import '../../../core/widgets/app_cards.dart';

class MedicineTimeline extends StatelessWidget {
  const MedicineTimeline({required this.events, super.key});

  final List<Map<String, String>> events;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: events
          .map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: AppCard(
                child: Row(
                  children: [
                    Text(e['time'] ?? ''),
                    const SizedBox(width: 12),
                    Expanded(child: Text(e['title'] ?? '')),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
