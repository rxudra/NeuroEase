import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../models/face_detection_result.dart';

/// Shows a face detection result without overwhelming the user: one large
/// headline, then a short line per face (at most [maxFacesListed]).
class FaceResultPanel extends StatelessWidget {
  const FaceResultPanel({super.key, required this.result});

  static const int maxFacesListed = 3;

  final FaceDetectionResult result;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final listed = result.faces.take(maxFacesListed).toList();
    final hidden = result.faceCount - listed.length;

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
          if (!result.hasFaces)
            Text(
              'Make sure the face is well lit and fills more of the picture, '
              'then scan again.',
              style: textTheme.bodyLarge,
            )
          else ...[
            for (var i = 0; i < listed.length; i++)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  result.faceCount == 1
                      ? listed[i].description
                      : 'Face ${i + 1}: ${listed[i].description}',
                  style: textTheme.bodyLarge,
                ),
              ),
            if (hidden > 0)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  'and $hidden more',
                  style: textTheme.bodyLarge,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
