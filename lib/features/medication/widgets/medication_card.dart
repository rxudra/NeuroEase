import 'package:flutter/material.dart';
import '../../../core/widgets/app_cards.dart';
import '../../medication/models/medication_model.dart';
import '../../medication/services/medication_service.dart';

class MedicationCard extends StatefulWidget {
  const MedicationCard({required this.med, super.key});

  final MedicationModel med;

  @override
  State<MedicationCard> createState() => _MedicationCardState();
}

class _MedicationCardState extends State<MedicationCard> {
  final _service = MedicationService.instance;

  @override
  Widget build(BuildContext context) {
    final med = widget.med;
    final today = DateTime.now();
    final taken = _service.isTaken(med, med.times.first, today);
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.medication_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${med.dosage} • ${med.type} • ${med.foodInstruction}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                med.times.map((t) => t.format(context)).join(', '),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _service.toggleTaken(med, med.times.first, today);
                  });
                },
                child: Text(taken ? 'Undo' : 'Mark'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
