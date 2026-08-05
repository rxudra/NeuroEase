import 'package:flutter/material.dart';

class BatteryCard extends StatelessWidget {
  const BatteryCard({super.key, required this.pct});

  final int pct;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.battery_full,
              color: pct > 30 ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Battery',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text('$pct%', style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
