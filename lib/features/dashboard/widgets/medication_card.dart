import 'package:flutter/material.dart';
import '../../../core/widgets/app_cards.dart';
import '../../../core/widgets/app_snackbars.dart';

class MedicationCard extends StatelessWidget {
  const MedicationCard({
    required this.name,
    required this.time,
    required this.taken,
    required this.onToggle,
    super.key,
  });

  final String name;
  final String time;
  final bool taken;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      color: taken ? colorScheme.primaryContainer : null,
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            child: const Icon(Icons.medication_rounded),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(time, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: taken ? Colors.green : colorScheme.primary,
                ),
                onPressed: () {
                  onToggle();
                  AppSnackbars.show(
                    context,
                    taken ? 'Marked as not taken' : 'Marked as taken',
                  );
                },
                child: Text(taken ? 'Taken' : 'Mark'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
