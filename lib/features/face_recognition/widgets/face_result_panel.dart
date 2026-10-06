import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../models/face_detection_result.dart';

/// Shows a face detection result without overwhelming the user.
class FaceResultPanel extends StatelessWidget {
  const FaceResultPanel({super.key, required this.result});

  final FaceDetectionResult result;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      key: const Key('face-result-panel'),
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
                result.hasFaces
                    ? Icons.face_retouching_natural
                    : Icons.person_search_outlined,
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
          Text(
            result.hasFaces
                ? 'Face detected successfully.'
                : 'Move closer and make sure your face is visible.',
            style: textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
