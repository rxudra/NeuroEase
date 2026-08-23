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
    final isCritical = alert.severity >= 4 || alert.type == AlertType.fall;
    final isUnread = !alert.isRead;

    return AppCard(
      child: Container(
        decoration: BoxDecoration(
          border: isCritical
              ? Border(
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                    width: 4,
                  ),
                )
              : null,
        ),
        child: ListTile(
          onTap: onView,
          leading: isCritical
              ? Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.error,
                  size: 28,
                )
              : Icon(
                  Icons.notifications_active_outlined,
                  color: isUnread
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  alert.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                    color: isCritical
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                ),
              ),
              if (isUnread)
                Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'NEW',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Text(
            alert.details,
            style: TextStyle(
              fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onView != null)
                IconButton(
                  onPressed: onView,
                  icon: const Icon(Icons.info_outline),
                ),
              if (onDismiss != null)
                IconButton(onPressed: onDismiss, icon: const Icon(Icons.close)),
            ],
          ),
        ),
      ),
    );
  }
}
