import 'package:flutter/material.dart';
import '../models/medication_model.dart';
import '../widgets/medicine_timeline.dart';
import '../widgets/reminder_chip.dart';

class MedicationDetailScreen extends StatelessWidget {
  const MedicationDetailScreen({required this.med, super.key});

  final MedicationModel med;

  @override
  Widget build(BuildContext context) {
    final events = med.times
        .map((t) => {'time': t.format(context), 'title': 'Take ${med.name}'})
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(med.name),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.delete)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag: med.id,
                child: CircleAvatar(
                  radius: 44,
                  child: const Icon(Icons.medication_rounded),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              med.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text('${med.dosage} • ${med.type}'),
            const SizedBox(height: 12),
            Row(
              children: [
                ReminderChip(enabled: med.isReminderEnabled),
                const SizedBox(width: 12),
                Text(
                  'From ${med.startDate.toLocal().toString().split(' ')[0]} to ${med.endDate.toLocal().toString().split(' ')[0]}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Schedule',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            MedicineTimeline(events: events),
            const SizedBox(height: 16),
            const Text('Notes', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(med.notes),
          ],
        ),
      ),
    );
  }
}
