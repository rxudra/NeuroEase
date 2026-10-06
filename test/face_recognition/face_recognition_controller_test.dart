import 'dart:ui';

import 'package:app/features/face_recognition/controllers/face_recognition_controller.dart';
import 'package:app/features/face_recognition/models/face_detection_result.dart';
import 'package:app/features/vision/vision_failure.dart';
import 'package:app/features/vision/vision_scan_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_face_detection_service.dart';
import '../support/fake_vision_camera.dart';

void main() {
  late FakeVisionCamera camera;
  late FakeFaceDetectionService detector;
  late FaceRecognitionController controller;

  setUp(() {
    camera = FakeVisionCamera();
    detector = FakeFaceDetectionService();
    controller = FaceRecognitionController(camera: camera, detector: detector);
  });

  test('no face in the photo is a valid result, not an error', () async {
    await controller.initialize();
    await controller.scan();

    expect(controller.status, VisionScanStatus.result);
    expect(controller.result?.hasFaces, isFalse);
    expect(controller.result?.summary, 'No person detected');
  });

  test('faces found are exposed with their details', () async {
    detector.faces = const [
      DetectedFace(
        boundingBox: Rect.fromLTWH(0, 0, 50, 50),
        smilingProbability: 0.9,
      ),
      DetectedFace(boundingBox: Rect.fromLTWH(60, 0, 50, 50)),
    ];
    await controller.initialize();
    await controller.scan();

    expect(controller.result?.faceCount, 2);
    expect(controller.result?.faces.first.isLikelySmiling, isTrue);
  });

  test('the photo given to the detector is deleted afterwards', () async {
    await controller.initialize();
    await controller.scan();

    expect(detector.analysedPaths, hasLength(1));
    expect(camera.discardedPhotos, detector.analysedPaths);
    expect(camera.outstandingPhotos, isEmpty);
  });

  test('detector failure becomes a processing error', () async {
    detector.error = const VisionFailure(VisionFailureKind.processingFailed);
    await controller.initialize();
    await controller.scan();

    expect(controller.status, VisionScanStatus.error);
    expect(controller.failure?.kind, VisionFailureKind.processingFailed);
    expect(camera.outstandingPhotos, isEmpty);
  });

  test('dispose releases the detector and the camera', () async {
    await controller.initialize();
    controller.dispose();

    expect(detector.disposeCalls, 1);
    expect(camera.disposeCalls, 1);
  });
}
