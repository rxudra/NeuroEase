import 'package:flutter/material.dart';
import '../models/memory_model.dart';

class MemoryCard extends StatelessWidget {
  const MemoryCard({
    super.key,
    required this.memory,
    this.onEdit,
    this.onDelete,
  });

  final MemoryModel memory;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'family':
        return Colors.blue;
      case 'medical':
        return Colors.purple;
      case 'event':
        return Colors.orange;
      case 'personal':
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = memory.time != null
        ? '${memory.time!.year}-${memory.time!.month.toString().padLeft(2, '0')}-${memory.time!.day.toString().padLeft(2, '0')}'
        : null;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    memory.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    memory.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: _categoryColor(memory.category),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: _categoryColor(
                    memory.category,
                  ).withValues(alpha: 0.12),
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                if (onEdit != null || onDelete != null)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (val) {
                      if (val == 'edit') onEdit?.call();
                      if (val == 'delete') onDelete?.call();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(memory.details, style: theme.textTheme.bodyMedium),
            if (memory.people.isNotEmpty || timeStr != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (timeStr != null) ...[
                    const Icon(Icons.calendar_today_outlined, size: 14),
                    const SizedBox(width: 4),
                    Text(timeStr, style: theme.textTheme.bodySmall),
                    const SizedBox(width: 12),
                  ],
                  if (memory.people.isNotEmpty) ...[
                    const Icon(Icons.person_outline_rounded, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'People: ${memory.people.join(', ')}',
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
