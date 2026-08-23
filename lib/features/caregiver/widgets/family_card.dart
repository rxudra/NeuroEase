import 'package:flutter/material.dart';
import '../../../core/widgets/app_cards.dart';
import '../models/family_member_model.dart';

enum FamilyCardAction { edit, delete }

class FamilyCard extends StatelessWidget {
  const FamilyCard({
    required this.member,
    this.onCall,
    this.onMessage,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final FamilyMemberModel member;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final roleText = member.role.isNotEmpty ? member.role : 'Member';
    final subText = member.relationship.isNotEmpty
        ? '${member.relationship} • $roleText'
        : roleText;

    return AppCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
          ),
        ),
        title: Text(
          member.name,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subText),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onCall != null)
              IconButton(onPressed: onCall, icon: const Icon(Icons.call)),
            if (onMessage != null)
              IconButton(onPressed: onMessage, icon: const Icon(Icons.message)),
            PopupMenuButton<FamilyCardAction>(
              icon: const Icon(Icons.more_vert),
              onSelected: (action) {
                if (action == FamilyCardAction.edit) {
                  onEdit?.call();
                } else if (action == FamilyCardAction.delete) {
                  onDelete?.call();
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: FamilyCardAction.edit,
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: FamilyCardAction.delete,
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete,
                        size: 18,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Delete',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
