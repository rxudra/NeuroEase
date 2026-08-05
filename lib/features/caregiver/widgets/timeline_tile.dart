import 'package:flutter/material.dart';
import '../../../core/widgets/app_cards.dart';

class TimelineTile extends StatelessWidget {
  const TimelineTile({
    required this.time,
    required this.title,
    this.color,
    super.key,
  });

  final String time;
  final String title;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(time, style: Theme.of(context).textTheme.bodySmall),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
          if (color != null)
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}
