import 'package:flutter/material.dart';

class CountdownCard extends StatelessWidget {
  const CountdownCard({super.key, required this.secondsLeft, this.onCancel});

  final int secondsLeft;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.red.shade200, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.timer, color: Colors.red, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EMERGENCY ALERT COUNTDOWN',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Colors.red.shade900,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$secondsLeft seconds remaining',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (onCancel != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade900,
                    side: BorderSide(color: Colors.red.shade400, width: 1.5),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel_outlined, size: 20),
                  label: const Text(
                    'Cancel Alert',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
