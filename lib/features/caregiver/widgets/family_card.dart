import 'package:flutter/material.dart';
import '../../../core/widgets/app_cards.dart';
import '../models/family_member_model.dart';

class FamilyCard extends StatelessWidget {
  const FamilyCard({
    required this.member,
    this.onCall,
    this.onMessage,
    super.key,
  });

  final FamilyMemberModel member;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          child: Text(member.name.isNotEmpty ? member.name[0] : '?'),
        ),
        title: Text(member.name),
        subtitle: Text('${member.relationship} • ${member.role}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: onCall, icon: const Icon(Icons.call)),
            IconButton(onPressed: onMessage, icon: const Icon(Icons.message)),
          ],
        ),
      ),
    );
  }
}
