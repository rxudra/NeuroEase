import 'package:flutter/material.dart';
import '../../../core/widgets/app_cards.dart';

class HealthCard extends StatelessWidget {
  const HealthCard({
    required this.title,
    required this.value,
    this.unit = '',
    super.key,
  });

  final String title;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Text(
            '$value $unit',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
