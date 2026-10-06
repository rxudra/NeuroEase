import 'dart:async';

import 'package:app/features/vision/vision_failure.dart';
import 'package:app/features/vision/vision_scan_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_vision_camera.dart';

void main() {
  late FakeVisionCamera camera;
  late List<String> analysedPaths;
  late Object? analyserError;
  late int disposeHookCalls;

  VisionScanController<String> buildController() {
    return VisionScanController<String>(
      camera: camera,
      analyse: (path) async {
        analysedPaths.add(path);
        final error = analyserError;
        if (error != null) throw error;
        return 'result for $path';
      },
      onDispose: () async {
        disposeHookCalls++;
      },
    );
  }

  setUp(() {
    camera = FakeVisionCamera();
    analysedPaths = [];
    analyserError = null;
    disposeHookCalls = 0;
  });

  group('initialize', () {
    test('starts idle', () {
      final controller = buildController();
      expect(controller.status, VisionScanStatus.idle);
      expect(controller.result, isNull);
      expect(controller.failure, isNull);
      expect(controller.showPreview, isFalse);
    });

    test('goes initializing -> ready', () async {
      camera.initializeGate = Completer<void>();
      final controller = buildController();

      final pending = controller.initialize();
      expect(controller.status, VisionScanStatus.initializing);
      expect(controller.isBusy, isTrue);

      camera.initializeGate!.complete();
      await pending;

      expect(controller.status, VisionScanStatus.ready);
      expect(controller.showPreview, isTrue);
    });

    test('permission denied becomes an error state', () async {
      camera.initializeFailure = const VisionFailure(
        VisionFailureKind.permissionDenied,
      );
      final controller = buildController();

      await controller.initialize();

      expect(controller.status, VisionScanStatus.error);
      expect(controller.failure?.kind, VisionFailureKind.permissionDenied);
      expect(controller.showPreview, isFalse);
    });

    test('unexpected errors become cameraUnavailable', () async {
      final controller = VisionScanController<String>(
        camera: _ThrowingCamera(),
        analyse: (_) async => 'unused',
      );

      await controller.initialize();

      expect(controller.status, VisionScanStatus.error);
      expect(controller.failure?.kind, VisionFailureKind.cameraUnavailable);
    });

    test('ignores a second call while initializing', () async {
      camera.initializeGate = Completer<void>();
      final controller = buildController();

      final first = controller.initialize();
      final second = controller.initialize();
      camera.initializeGate!.complete();
      await Future.wait([first, second]);

      expect(camera.initializeCalls, 1);
    });

    test('notifies listeners on each state change', () async {
      final controller = buildController();
      final seen = <VisionScanStatus>[];
      controller.addListener(() => seen.add(controller.status));

      await controller.initialize();
      await controller.scan();

      expect(seen, [
        VisionScanStatus.initializing,
        VisionScanStatus.ready,
        VisionScanStatus.scanning,
        VisionScanStatus.result,
      ]);
    });
  });

  group('scan', () {
    test('produces a result and deletes the photo', () async {
      final controller = buildController();
      await controller.initialize();

      await controller.scan();

      expect(controller.status, VisionScanStatus.result);
      expect(controller.result, 'result for fake://photo-0.jpg');
      expect(analysedPaths, ['fake://photo-0.jpg']);
      expect(camera.outstandingPhotos, isEmpty);
      expect(camera.discardedPhotos, ['fake://photo-0.jpg']);
    });

    test('analysis failure is an error and the photo is still deleted',
        () async {
      analyserError = StateError('model crashed');
      final controller = buildController();
      await controller.initialize();

      await controller.scan();

      expect(controller.status, VisionScanStatus.error);
      expect(controller.failure?.kind, VisionFailureKind.processingFailed);
      expect(controller.result, isNull);
      expect(camera.outstandingPhotos, isEmpty);
      expect(camera.discardedPhotos, hasLength(1));
    });

    test('a VisionFailure from analysis is passed through', () async {
      analyserError = const VisionFailure(
        VisionFailureKind.processingFailed,
        debugMessage: 'PlatformException',
      );
      final controller = buildController();
      await controller.initialize();

      await controller.scan();

      expect(controller.failure?.debugMessage, 'PlatformException');
    });

    test('capture failure is an error and nothing is analysed', () async {
      camera.captureFailure = const VisionFailure(
        VisionFailureKind.cameraUnavailable,
      );
      final controller = buildController();
      await controller.initialize();

      await controller.scan();

      expect(controller.status, VisionScanStatus.error);
      expect(analysedPaths, isEmpty);
      expect(camera.discardedPhotos, isEmpty);
    });

    test('is ignored when the camera is not ready', () async {
      final controller = buildController();

      await controller.scan();

      expect(controller.status, VisionScanStatus.idle);
      expect(analysedPaths, isEmpty);
    });

    test('is ignored while a scan is already running', () async {
      final gate = Completer<String>();
      final controller = VisionScanController<String>(
        camera: camera,
        analyse: (path) {
          analysedPaths.add(path);
          return gate.future;
        },
      );
      await controller.initialize();

      final first = controller.scan();
      await controller.scan();
      expect(controller.status, VisionScanStatus.scanning);

      gate.complete('done');
      await first;

      expect(analysedPaths, hasLength(1));
      expect(controller.result, 'done');
    });

    test('scanning again from a result replaces the result', () async {
      final controller = buildController();
      await controller.initialize();
      await controller.scan();

      await controller.scan();

      expect(controller.result, 'result for fake://photo-1.jpg');
      expect(camera.outstandingPhotos, isEmpty);
    });
  });

  group('retry', () {
    test('from a result goes back to ready', () async {
      final controller = buildController();
      await controller.initialize();
      await controller.scan();

      await controller.retry();

      expect(controller.status, VisionScanStatus.ready);
      expect(controller.result, isNull);
    });

    test('after a permission error opens the camera again', () async {
      camera.initializeFailure = const VisionFailure(
        VisionFailureKind.permissionDenied,
      );
      final controller = buildController();
      await controller.initialize();

      camera.initializeFailure = null; // user tapped Allow this time
      await controller.retry();

      expect(controller.status, VisionScanStatus.ready);
      expect(controller.failure, isNull);
      expect(camera.initializeCalls, 2);
    });
  });

  group('app lifecycle', () {
    test('suspend releases the camera and resume re-opens it', () async {
      final controller = buildController();
      await controller.initialize();

      await controller.suspend();
      expect(controller.status, VisionScanStatus.idle);
      expect(camera.isInitialized, isFalse);
      expect(camera.disposeCalls, 1);

      await controller.resume();
      expect(controller.status, VisionScanStatus.ready);
      expect(camera.initializeCalls, 2);
    });

    test('suspend is ignored while the camera is starting', () async {
      camera.initializeGate = Completer<void>();
      final controller = buildController();
      final pending = controller.initialize();

      await controller.suspend(); // e.g. OS permission dialog appears
      expect(camera.disposeCalls, 0);

      camera.initializeGate!.complete();
      await pending;
      expect(controller.status, VisionScanStatus.ready);
    });

    test('resume after a camera error retries (permission granted in '
        'Settings)', () async {
      camera.initializeFailure = const VisionFailure(
        VisionFailureKind.permissionPermanentlyDenied,
      );
      final controller = buildController();
      await controller.initialize();
      await controller.suspend();
      expect(controller.status, VisionScanStatus.error);

      camera.initializeFailure = null;
      await controller.resume();

      expect(controller.status, VisionScanStatus.ready);
    });

    test('resume does nothing while ready', () async {
      final controller = buildController();
      await controller.initialize();

      await controller.resume();

      expect(camera.initializeCalls, 1);
    });
  });

  group('dispose', () {
    test('releases the camera and the analyser', () async {
      final controller = buildController();
      await controller.initialize();

      controller.dispose();

      expect(camera.disposeCalls, 1);
      expect(disposeHookCalls, 1);
    });

    test('a scan finishing after dispose does not throw', () async {
      final gate = Completer<String>();
      final controller = VisionScanController<String>(
        camera: camera,
        analyse: (_) => gate.future,
      );
      await controller.initialize();

      final pending = controller.scan();
      controller.dispose();
      gate.complete('late');

      await expectLater(pending, completes);
      expect(camera.outstandingPhotos, isEmpty);
    });
  });
}

class _ThrowingCamera extends FakeVisionCamera {
  @override
  Future<void> initialize() async {
    throw StateError('plugin missing');
  }
}
