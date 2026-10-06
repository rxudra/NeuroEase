import 'package:app/features/vision/camera/device_vision_camera.dart';
import 'package:app/features/vision/vision_failure.dart';
import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VisionFailure', () {
    test('every kind has a non-empty title and message', () {
      for (final kind in VisionFailureKind.values) {
        final failure = VisionFailure(kind);
        expect(failure.title, isNotEmpty, reason: kind.name);
        expect(failure.userMessage, isNotEmpty, reason: kind.name);
      }
    });

    test('retry is offered except when there is no camera', () {
      expect(
        const VisionFailure(VisionFailureKind.noCamera).canRetry,
        isFalse,
      );
      for (final kind in VisionFailureKind.values.where(
        (k) => k != VisionFailureKind.noCamera,
      )) {
        expect(VisionFailure(kind).canRetry, isTrue, reason: kind.name);
      }
    });

    test('permanently denied explains how to fix it in Settings', () {
      const failure = VisionFailure(
        VisionFailureKind.permissionPermanentlyDenied,
      );
      expect(failure.userMessage, contains('Settings'));
    });

    test('toString exposes only the kind', () {
      const failure = VisionFailure(
        VisionFailureKind.processingFailed,
        debugMessage: 'PlatformException',
      );
      expect(failure.toString(), 'VisionFailure(processingFailed)');
    });
  });

  group('visionFailureFromCameraException', () {
    test('maps CameraAccessDenied to permissionDenied', () {
      final failure = visionFailureFromCameraException(
        CameraException('CameraAccessDenied', 'denied'),
      );
      expect(failure.kind, VisionFailureKind.permissionDenied);
    });

    test('maps iOS "without prompt" and restricted to permanently denied', () {
      for (final code in [
        'CameraAccessDeniedWithoutPrompt',
        'CameraAccessRestricted',
      ]) {
        final failure = visionFailureFromCameraException(
          CameraException(code, null),
        );
        expect(
          failure.kind,
          VisionFailureKind.permissionPermanentlyDenied,
          reason: code,
        );
      }
    });

    test('maps unknown codes to cameraUnavailable', () {
      final failure = visionFailureFromCameraException(
        CameraException('cameraNotReadable', 'busy'),
      );
      expect(failure.kind, VisionFailureKind.cameraUnavailable);
      expect(failure.debugMessage, 'cameraNotReadable');
    });
  });

  group('DeviceVisionCamera without hardware', () {
    test('reports noCamera when the device lists no cameras', () async {
      final camera = DeviceVisionCamera(loadCameras: () async => []);
      await expectLater(
        camera.initialize(),
        throwsA(
          isA<VisionFailure>().having(
            (f) => f.kind,
            'kind',
            VisionFailureKind.noCamera,
          ),
        ),
      );
      expect(camera.isInitialized, isFalse);
    });

    test('maps a permission error while listing cameras', () async {
      final camera = DeviceVisionCamera(
        loadCameras: () async =>
            throw CameraException('CameraAccessDenied', null),
      );
      await expectLater(
        camera.initialize(),
        throwsA(
          isA<VisionFailure>().having(
            (f) => f.kind,
            'kind',
            VisionFailureKind.permissionDenied,
          ),
        ),
      );
    });

    test('capture before initialize fails cleanly', () async {
      final camera = DeviceVisionCamera(loadCameras: () async => []);
      await expectLater(camera.capturePhoto(), throwsA(isA<VisionFailure>()));
    });

    test('dispose is safe when never initialized', () async {
      final camera = DeviceVisionCamera(loadCameras: () async => []);
      await camera.dispose();
      await camera.dispose();
      expect(camera.isInitialized, isFalse);
    });
  });
}
