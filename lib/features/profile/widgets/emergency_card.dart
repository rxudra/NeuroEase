import 'package:flutter/material.dart';
import '../../../core/widgets/app_cards.dart';
import '../models/patient_model.dart';

class EmergencyCard extends StatelessWidget {
  const EmergencyCard({required this.contact, super.key});

  final EmergencyContact contact;

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(contact.relationship),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.message)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.call)),
            ],
          ),
        ],
      ),
    );
  }
}
