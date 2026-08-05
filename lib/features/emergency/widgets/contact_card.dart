import 'package:flutter/material.dart';
import '../models/emergency_contact_model.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({super.key, required this.contact});

  final EmergencyContactModel contact;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              child: Text(contact.name.isNotEmpty ? contact.name[0] : '?'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    contact.relationship,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Chip(label: Text('P${contact.priority}')),
            const SizedBox(width: 8),
            IconButton(onPressed: () {}, icon: const Icon(Icons.call)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.message)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.videocam)),
          ],
        ),
      ),
    );
  }
}
