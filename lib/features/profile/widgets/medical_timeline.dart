import 'package:flutter/material.dart';
import '../../../core/widgets/app_cards.dart';

class MedicalTimeline extends StatelessWidget {
  const MedicalTimeline({required this.events, super.key});

  final List<Map<String, String>> events;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: events.map((e) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: AppCard(
            child: Row(
              children: [
                Text(e['date'] ?? ''),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e['title'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      if (e['notes'] != null) Text(e['notes'] ?? ''),
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
