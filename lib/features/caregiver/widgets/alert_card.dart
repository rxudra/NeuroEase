import 'package:flutter/material.dart';
import '../../../core/widgets/app_cards.dart';
import '../models/alert_model.dart';

class AlertCard extends StatelessWidget {
  const AlertCard({
    required this.alert,
    this.onDismiss,
    this.onView,
    super.key,
  });

  final AlertModel alert;
  final VoidCallback? onDismiss;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        title: Text(
          alert.title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(alert.details),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: onView, icon: const Icon(Icons.visibility)),
            IconButton(onPressed: onDismiss, icon: const Icon(Icons.close)),
          ],
        ),
      ),
    );
  }
}
