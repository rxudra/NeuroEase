import 'package:flutter/material.dart';

import '../../core/constants/spacing.dart';
import '../../core/widgets/app_cards.dart';
import '../face_recognition/screens/face_recognition_screen.dart';
import '../object_recognition/screens/object_recognition_screen.dart';

/// Entry point for the camera-based assistive features.
class RecognitionScreen extends StatelessWidget {
  const RecognitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Camera help')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _RecognitionTile(
              key: const Key('recognition-tile-face'),
              icon: Icons.face_retouching_natural,
              title: 'Face detection',
              subtitle: 'Check whether a face is in front of the camera.',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const FaceRecognitionScreen(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _RecognitionTile(
              key: const Key('recognition-tile-object'),
              icon: Icons.center_focus_strong_outlined,
              title: 'What is this?',
              subtitle: 'Point the camera at an object to find out what '
                  'it is.',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ObjectRecognitionScreen(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock_outline, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Photos are checked on this phone and deleted straight '
                    'away. Nothing is saved or uploaded.',
                    style: textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecognitionTile extends StatelessWidget {
  const _RecognitionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Icon(icon, size: 40, color: scheme.primary),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: textTheme.bodyLarge),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
