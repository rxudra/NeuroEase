import 'package:flutter/material.dart';
import '../services/search_service.dart';

class SearchResultTile extends StatelessWidget {
  const SearchResultTile({super.key, required this.item, this.onTap});

  final SearchResultItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _iconFor(item.type),
      title: Text(item.title),
      subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
      trailing: Text(item.type, style: Theme.of(context).textTheme.bodySmall),
      onTap: onTap,
    );
  }

  Widget _iconFor(String type) {
    switch (type) {
      case 'Medication':
        return const Icon(Icons.medication, color: Colors.blue);
      case 'Reminder':
        return const Icon(Icons.notifications, color: Colors.orange);
      case 'Task':
        return const Icon(Icons.event, color: Colors.green);
      case 'Contact':
        return const Icon(Icons.person, color: Colors.purple);
      default:
        return const Icon(Icons.info);
    }
  }
}
