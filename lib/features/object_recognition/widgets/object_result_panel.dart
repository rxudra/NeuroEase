import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../models/object_recognition_result.dart';

/// Shows an object recognition result in plain words.
///
/// Confident labels (max 3) are stated with "Very likely"/"Likely".
/// Low-confidence labels are never stated as fact: at most one is offered
/// as "It might be …" with advice to try again.
class ObjectResultPanel extends StatelessWidget {
  const ObjectResultPanel({super.key, required this.result});

  final ObjectRecognitionResult result;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final guess = result.tentativeGuess;

    return Container(
      key: const Key('object-result-panel'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.hasConfidentResult
                    ? Icons.check_circle_outline
                    : Icons.help_outline,
                size: 32,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  result.summary,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (result.hasConfidentResult) ...[
            for (final label in result.confidentLabels)
              Padding(
                key: Key('object-label-${label.name}'),
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  '${label.name} — ${label.confidenceText} '
                  '(${label.percentText})',
                  style: textTheme.bodyLarge,
                ),
              ),
          ] else if (guess != null) ...[
            Text(
              'It might be: ${guess.name}',
              key: const Key('object-tentative-guess'),
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Try moving closer, adding more light, or holding the object '
              'still, then scan again.',
              style: textTheme.bodyLarge,
            ),
          ] else
            Text(
              'Try pointing the camera straight at one object in good light, '
              'then scan again.',
              style: textTheme.bodyLarge,
            ),
          if (result.objectCount > 1) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${result.objectCount} separate objects in view',
              style: textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            'Please double-check before relying on this, '
            'especially for medicines or food.',
            key: const Key('object-safety-note'),
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
