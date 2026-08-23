import 'package:flutter/material.dart';
import '../models/medication_model.dart';
import '../services/medication_service.dart';
import '../widgets/medicine_timeline.dart';
import '../widgets/reminder_chip.dart';
import 'add_medication_screen.dart';

class MedicationDetailScreen extends StatelessWidget {
  const MedicationDetailScreen({required this.med, super.key});

  final MedicationModel med;

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Medication'),
        content: Text('Are you sure you want to delete ${med.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await MedicationService.instance.deleteMedication(med.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${med.name} deleted')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  Future<void> _edit(BuildContext context) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddMedicationScreen(med: med)),
    );
    if (updated == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final events = med.times
        .map((t) => {'time': t.format(context), 'title': 'Take ${med.name}'})
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(med.name),
        actions: [
          IconButton(
            onPressed: () => _edit(context),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () => _delete(context),
            icon: const Icon(Icons.delete),
          ),
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
