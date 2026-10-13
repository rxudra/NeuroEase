import 'package:flutter/material.dart';
import '../../../core/constants/spacing.dart';
import '../models/enrolled_person.dart';

/// Modal dialog for listing and deleting enrolled family members / care team profiles.
class ManagePeopleDialog extends StatelessWidget {
  const ManagePeopleDialog({
    super.key,
    required this.people,
    required this.onDelete,
  });

  final List<EnrolledPerson> people;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final scheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people_alt_outlined, color: scheme.primary, size: 28),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Family & Care Team',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Enrolled people stored locally on this device:',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            if (people.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(
                  child: Text(
                    'No enrolled people yet.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: people.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final person = people[index];
                    return Container(
                      key: Key('enrolled-person-${person.id}'),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: scheme.primaryContainer,
                            child: Icon(
                              _getRelationshipIcon(person.relationship),
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  person.name,
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  person.relationship,
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            key: Key('delete-person-${person.id}'),
                            style: TextButton.styleFrom(
                              foregroundColor: scheme.error,
                            ),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Delete'),
                            onPressed: () => onDelete(person.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRelationshipIcon(String relationship) {
    switch (relationship) {
      case PersonRelationship.mom:
      case PersonRelationship.sister:
        return Icons.person_outline;
      case PersonRelationship.dad:
      case PersonRelationship.brother:
        return Icons.person;
      case PersonRelationship.caregiver:
        return Icons.medical_services_outlined;
      case PersonRelationship.doctor:
        return Icons.local_hospital_outlined;
      default:
        return Icons.account_circle_outlined;
    }
  }
}
