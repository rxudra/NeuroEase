import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../vision_failure.dart';
import '../vision_scan_controller.dart';

/// Shared layout for tap-to-scan vision screens: camera preview, one clear
/// status message, and one large action button.
///
/// Holds no logic of its own; everything comes from [controller].
class VisionScanView<T> extends StatelessWidget {
  const VisionScanView({
    super.key,
    required this.controller,
    required this.scanLabel,
    required this.readyMessage,
    required this.scanningMessage,
    required this.resultBuilder,
  });

  final VisionScanController<T> controller;

  /// Button label when ready, e.g. "Check for faces".
  final String scanLabel;

  /// Instruction shown under the preview when ready.
  final String readyMessage;

  /// Message shown while a photo is being analysed.
  final String scanningMessage;

  /// Builds the result panel.
  final Widget Function(BuildContext context, T result) resultBuilder;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 3, child: _PreviewArea(controller: controller)),
              const SizedBox(height: AppSpacing.lg),
              Flexible(
                flex: 2,
                child: SingleChildScrollView(
                  child: Semantics(
                    liveRegion: true,
                    child: _StatusArea<T>(
                      controller: controller,
                      readyMessage: readyMessage,
                      scanningMessage: scanningMessage,
                      resultBuilder: resultBuilder,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ActionButton(controller: controller, scanLabel: scanLabel),
            ],
          ),
        );
      },
    );
  }
}

class _PreviewArea extends StatelessWidget {
  const _PreviewArea({required this.controller});

  final VisionScanController<Object?> controller;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (controller.showPreview) {
      child = controller.camera.buildPreview();
    } else if (controller.status == VisionScanStatus.error) {
      child = const Icon(
        Icons.no_photography_outlined,
        size: 64,
        color: Colors.white70,
      );
    } else {
      child = const CircularProgressIndicator(
        key: Key('vision-initializing'),
        color: Colors.white,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: ColoredBox(
        color: const Color(0xFF0F172A),
        child: Center(child: child),
      ),
    );
  }
}

class _StatusArea<T> extends StatelessWidget {
  const _StatusArea({
    required this.controller,
    required this.readyMessage,
    required this.scanningMessage,
    required this.resultBuilder,
  });

  final VisionScanController<T> controller;
  final String readyMessage;
  final String scanningMessage;
  final Widget Function(BuildContext context, T result) resultBuilder;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    switch (controller.status) {
      case VisionScanStatus.idle:
      case VisionScanStatus.initializing:
        return Text(
          'Starting the camera…',
          key: const Key('vision-status-starting'),
          style: textTheme.titleMedium,
          textAlign: TextAlign.center,
        );
      case VisionScanStatus.ready:
        return Text(
          readyMessage,
          key: const Key('vision-status-ready'),
          style: textTheme.titleMedium,
          textAlign: TextAlign.center,
        );
      case VisionScanStatus.scanning:
        return Row(
          key: const Key('vision-status-scanning'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(width: AppSpacing.md),
            Flexible(
              child: Text(scanningMessage, style: textTheme.titleMedium),
            ),
          ],
        );
      case VisionScanStatus.result:
        final result = controller.result;
        if (result == null) return const SizedBox.shrink();
        return resultBuilder(context, result);
      case VisionScanStatus.error:
        final failure = controller.failure ??
            const VisionFailure(VisionFailureKind.cameraUnavailable);
        return _FailureMessage(failure: failure);
    }
  }
}

class _FailureMessage extends StatelessWidget {
  const _FailureMessage({required this.failure});

  final VisionFailure failure;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      key: const Key('vision-status-error'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            failure.title,
            style: textTheme.titleLarge?.copyWith(
              color: scheme.onErrorContainer,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            failure.userMessage,
            style: textTheme.bodyLarge?.copyWith(
              color: scheme.onErrorContainer,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.controller, required this.scanLabel});

  final VisionScanController<Object?> controller;
  final String scanLabel;

  @override
  Widget build(BuildContext context) {
    final String label;
    final VoidCallback? onPressed;

    switch (controller.status) {
      case VisionScanStatus.idle:
      case VisionScanStatus.initializing:
      case VisionScanStatus.scanning:
        label = 'Please wait…';
        onPressed = null;
      case VisionScanStatus.ready:
        label = scanLabel;
        onPressed = controller.scan;
      case VisionScanStatus.result:
        label = 'Scan again';
        onPressed = controller.scan;
      case VisionScanStatus.error:
        final canRetry = controller.failure?.canRetry ?? true;
        if (!canRetry) return const SizedBox.shrink();
        label = 'Try again';
        onPressed = controller.retry;
    }

    return FilledButton(
      key: const Key('vision-action-button'),
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}
