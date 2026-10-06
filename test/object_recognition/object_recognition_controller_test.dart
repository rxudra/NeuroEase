import 'package:app/features/object_recognition/controllers/object_recognition_controller.dart';
import 'package:app/features/object_recognition/models/object_recognition_result.dart';
import 'package:app/features/vision/vision_failure.dart';
import 'package:app/features/vision/vision_scan_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_object_recognition_service.dart';
import '../support/fake_vision_camera.dart';

void main() {
  late FakeVisionCamera camera;
  late FakeObjectRecognitionService recognizer;
  late ObjectRecognitionController controller;

  setUp(() {
    camera = FakeVisionCamera();
    recognizer = FakeObjectRecognitionService();
    controller = ObjectRecognitionController(
      camera: camera,
      recognizer: recognizer,
    );
  });

  test('no detection is a valid result, not an error', () async {
    await controller.initialize();
    await controller.scan();

    expect(controller.status, VisionScanStatus.result);
    expect(controller.result?.isEmpty, isTrue);
    expect(controller.result?.summary, 'Object not clearly identified');
  });

  test('detections are exposed most confident first', () async {
    recognizer.labels = const [
      RecognizedLabel(name: 'Book', confidence: 0.78),
      RecognizedLabel(name: 'Cup', confidence: 0.92),
    ];
    await controller.initialize();
    await controller.scan();

    expect(controller.result?.confidentLabels.first.name, 'Cup');
    expect(controller.result?.summary, 'I can see: Cup and Book');
  });

  test('low-confidence detections report object not clearly identified', () async {
    recognizer.labels = const [
      RecognizedLabel(name: 'Pill bottle', confidence: 0.55),
    ];
    await controller.initialize();
    await controller.scan();

    expect(controller.result?.hasConfidentResult, isFalse);
    expect(controller.result?.summary, 'Object not clearly identified');
  });

  test('the photo is deleted after recognition', () async {
    await controller.initialize();
    await controller.scan();

    expect(recognizer.analysedPaths, hasLength(1));
    expect(camera.discardedPhotos, recognizer.analysedPaths);
    expect(camera.outstandingPhotos, isEmpty);
  });

  test('recognizer failure becomes a processing error', () async {
    recognizer.error = Exception('native crash');
    await controller.initialize();
    await controller.scan();

    expect(controller.status, VisionScanStatus.error);
    expect(controller.failure?.kind, VisionFailureKind.processingFailed);
    expect(camera.outstandingPhotos, isEmpty);
  });

  test('camera permission denied is reported', () async {
    camera.initializeFailure = const VisionFailure(
      VisionFailureKind.permissionDenied,
    );
    await controller.initialize();

    expect(controller.status, VisionScanStatus.error);
    expect(controller.failure?.kind, VisionFailureKind.permissionDenied);
  });

  test('dispose releases the recognizer and the camera', () async {
    await controller.initialize();
    controller.dispose();

    expect(recognizer.disposeCalls, 1);
    expect(camera.disposeCalls, 1);
  });
}
