import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
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
    final time = med.times.isNotEmpty
        ? med.times.first
        : const TimeOfDay(hour: 10, minute: 0);
    final taken = _service.isTaken(med, time, today);
    final timeDisplay = med.times.isNotEmpty
        ? med.times.map((t) => t.format(context)).join(', ')
        : 'No time set';
    final detailsList = [
      if (med.dosage.isNotEmpty) med.dosage,
      if (med.type.isNotEmpty) med.type,
      if (med.foodInstruction.isNotEmpty) med.foodInstruction,
    ];
    final details = detailsList.join(' • ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryContainer,
            child: const Icon(
              Icons.medication_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  med.name.isNotEmpty ? med.name : 'Medication',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    details,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  timeDisplay,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: taken ? AppColors.success : AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(60, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              setState(() {
                _service.toggleTaken(med, time, today);
              });
            },
            child: Text(taken ? 'Taken' : 'Mark'),
          ),
        ],
      ),
    );
  }
}
