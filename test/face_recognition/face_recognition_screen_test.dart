import 'dart:async';

import 'package:app/features/face_recognition/controllers/face_recognition_controller.dart';
import 'package:app/features/face_recognition/models/face_detection_result.dart';
import 'package:app/features/face_recognition/screens/face_recognition_screen.dart';
import 'package:app/features/vision/vision_failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_face_detection_service.dart';
import '../support/fake_vision_camera.dart';

const _box = Rect.fromLTWH(0, 0, 40, 40);

void main() {
  late FakeVisionCamera camera;
  late FakeFaceDetectionService detector;

  setUp(() {
    camera = FakeVisionCamera();
    detector = FakeFaceDetectionService();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FaceRecognitionScreen(
          createController: () =>
              FaceRecognitionController(camera: camera, detector: detector),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> tapAndSettleScan(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pump();
    await tester.pump();
  }

  FilledButton actionButton(WidgetTester tester) => tester.widget<FilledButton>(
    find.byKey(const Key('vision-action-button')),
  );

  testWidgets('shows a loading state while the camera starts', (tester) async {
    camera.initializeGate = Completer<void>();
    await pumpScreen(tester);

    expect(find.text('Face Recognition'), findsOneWidget);
    expect(find.byKey(const Key('vision-initializing')), findsOneWidget);
    expect(find.text('Starting the camera…'), findsOneWidget);
    expect(find.text('Please wait…'), findsOneWidget);
    expect(actionButton(tester).onPressed, isNull);

    camera.initializeGate!.complete();
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('fake-camera-preview')), findsOneWidget);
    expect(
      find.text('Point the camera at your face, then tap the button.'),
      findsOneWidget,
    );
    expect(find.text('Check for faces'), findsOneWidget);
    expect(actionButton(tester).onPressed, isNotNull);
  });

  testWidgets('no face shows a calm hint and lets the user scan again', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tapAndSettleScan(tester, 'Check for faces');

    expect(find.text('No person detected'), findsOneWidget);
    expect(find.textContaining('Move closer and make sure your face is visible.'), findsOneWidget);
    expect(find.text('Scan again'), findsOneWidget);
    expect(camera.outstandingPhotos, isEmpty);
  });

  testWidgets('face detected shows person detected and success text', (tester) async {
    detector.faces = const [
      DetectedFace(
        boundingBox: _box,
        headTurnDegrees: 0,
        smilingProbability: 0.9,
      ),
    ];
    await pumpScreen(tester);

    await tapAndSettleScan(tester, 'Check for faces');

    expect(find.text('👤 Person detected'), findsOneWidget);
    expect(find.text('Face detected successfully.'), findsOneWidget);
  });

  testWidgets('permission denied shows guidance and recovers on retry', (
    tester,
  ) async {
    camera.initializeFailure = const VisionFailure(
      VisionFailureKind.permissionDenied,
    );
    await pumpScreen(tester);

    expect(find.byKey(const Key('vision-status-error')), findsOneWidget);
    expect(find.text('Camera access needed'), findsOneWidget);
    expect(find.byIcon(Icons.no_photography_outlined), findsOneWidget);

    camera.initializeFailure = null; // user allows the camera
    await tapAndSettleScan(tester, 'Try again');

    expect(find.text('Check for faces'), findsOneWidget);
  });

  testWidgets('no camera shows a message and no retry button', (tester) async {
    camera.initializeFailure = const VisionFailure(VisionFailureKind.noCamera);
    await pumpScreen(tester);

    expect(find.text('No camera found'), findsOneWidget);
    expect(find.byKey(const Key('vision-action-button')), findsNothing);
  });

  testWidgets('processing failure shows an error and allows retry', (
    tester,
  ) async {
    detector.error = const VisionFailure(VisionFailureKind.processingFailed);
    await pumpScreen(tester);

    await tapAndSettleScan(tester, 'Check for faces');

    expect(find.text('Could not check the photo'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(camera.outstandingPhotos, isEmpty);
  });

  testWidgets('leaving the screen releases camera and detector', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));

    expect(camera.disposeCalls, greaterThanOrEqualTo(1));
    expect(detector.disposeCalls, 1);
  });
}
