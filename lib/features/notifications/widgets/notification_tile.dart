import 'package:flutter/material.dart';

import '../models/notification_item.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.item, this.onTap});

  final NotificationItem item;
  final VoidCallback? onTap;

  IconData _iconForCategory(String c) {
    switch (c) {
      case 'Reminders':
        return Icons.alarm;
      case 'Medication':
        return Icons.medication;
      case 'Messages':
        return Icons.message;
      case 'System':
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Notification: ${item.title}',
      button: true,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.read
              ? Colors.grey.shade200
              : Theme.of(context).colorScheme.primary.withAlpha(31),
          child: Icon(
            _iconForCategory(item.category),
            color: item.read
                ? Colors.grey
                : Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          item.title,
          style: item.read
              ? null
              : const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(item.body, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!item.read)
              Semantics(
                label: 'Unread',
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            const SizedBox(height: 6),
            Text(
              _friendlyDate(item.date),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _friendlyDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inDays >= 1) return '${diff.inDays}d';
    if (diff.inHours >= 1) return '${diff.inHours}h';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m';
    return 'now';
  }
}
