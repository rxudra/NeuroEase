import 'dart:async';

import 'package:app/features/object_recognition/controllers/object_recognition_controller.dart';
import 'package:app/features/object_recognition/models/object_recognition_result.dart';
import 'package:app/features/object_recognition/screens/object_recognition_screen.dart';
import 'package:app/features/vision/vision_failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_object_recognition_service.dart';
import '../support/fake_vision_camera.dart';

void main() {
  late FakeVisionCamera camera;
  late FakeObjectRecognitionService recognizer;

  setUp(() {
    camera = FakeVisionCamera();
    recognizer = FakeObjectRecognitionService();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ObjectRecognitionScreen(
          createController: () => ObjectRecognitionController(
            camera: camera,
            recognizer: recognizer,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> tapAndWait(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pump();
    await tester.pump();
  }

  testWidgets('loading state while the camera starts, then ready', (
    tester,
  ) async {
    camera.initializeGate = Completer<void>();
    await pumpScreen(tester);

    expect(find.text('Find an Object'), findsOneWidget);
    expect(find.text('Starting the camera…'), findsOneWidget);
    expect(find.byKey(const Key('vision-initializing')), findsOneWidget);

    camera.initializeGate!.complete();
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('fake-camera-preview')), findsOneWidget);
    expect(find.text('Identify object'), findsOneWidget);
  });

  testWidgets('shows a scanning state while the photo is checked', (
    tester,
  ) async {
    recognizer.gate = Completer<void>();
    await pumpScreen(tester);

    await tester.tap(find.text('Identify object'));
    await tester.pump();

    expect(find.byKey(const Key('vision-status-scanning')), findsOneWidget);
    expect(find.text('Looking at the object…'), findsOneWidget);
    expect(find.text('Please wait…'), findsOneWidget);

    recognizer.gate!.complete();
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('object-result-panel')), findsOneWidget);
  });

  testWidgets('confident detections are listed with confidence in words', (
    tester,
  ) async {
    recognizer.labels = const [
      RecognizedLabel(name: 'Cup', confidence: 0.92),
      RecognizedLabel(name: 'Book', confidence: 0.78),
    ];
    await pumpScreen(tester);

    await tapAndWait(tester, 'Identify object');

    expect(find.text('I can see: Cup and Book'), findsOneWidget);
    expect(find.text('Cup — High confidence'), findsOneWidget);
    expect(find.text('Book — Possible match'), findsOneWidget);
    expect(find.byKey(const Key('object-safety-note')), findsOneWidget);
    expect(find.text('Scan again'), findsOneWidget);
  });

  testWidgets('only the top three detections are shown', (tester) async {
    recognizer.labels = const [
      RecognizedLabel(name: 'Cup', confidence: 0.95),
      RecognizedLabel(name: 'Laptop', confidence: 0.9),
      RecognizedLabel(name: 'Book', confidence: 0.85),
      RecognizedLabel(name: 'Pen', confidence: 0.8),
    ];
    await pumpScreen(tester);

    await tapAndWait(tester, 'Identify object');

    expect(find.byKey(const Key('object-label-Book')), findsOneWidget);
    expect(find.byKey(const Key('object-label-Pen')), findsNothing);
  });

  testWidgets('low confidence shows object not clearly identified', (
    tester,
  ) async {
    recognizer.labels = const [
      RecognizedLabel(name: 'Pill bottle', confidence: 0.55),
    ];
    await pumpScreen(tester);

    await tapAndWait(tester, 'Identify object');

    expect(find.text('Object not clearly identified'), findsOneWidget);
    expect(find.textContaining('Move the object closer'), findsOneWidget);
    expect(find.textContaining('I can see'), findsNothing);
    expect(find.byKey(const Key('object-safety-note')), findsOneWidget);
  });

  testWidgets('no detection is handled gracefully', (tester) async {
    await pumpScreen(tester);

    await tapAndWait(tester, 'Identify object');

    expect(find.text('Object not clearly identified'), findsOneWidget);
    expect(find.textContaining('Move the object closer'), findsOneWidget);
  });

  testWidgets('several located objects are counted', (tester) async {
    recognizer.labels = const [
      RecognizedLabel(name: 'Bottle', confidence: 0.9),
    ];
    recognizer.objects = const [
      LocatedObject(boundingBox: Rect.fromLTWH(0, 0, 10, 10)),
      LocatedObject(boundingBox: Rect.fromLTWH(20, 0, 10, 10)),
    ];
    await pumpScreen(tester);

    await tapAndWait(tester, 'Identify object');

    expect(find.text('2 separate objects in view'), findsOneWidget);
  });

  testWidgets('processing error shows a message and Try again', (
    tester,
  ) async {
    recognizer.error = const VisionFailure(VisionFailureKind.processingFailed);
    await pumpScreen(tester);

    await tapAndWait(tester, 'Identify object');

    expect(find.text('Could not check the photo'), findsOneWidget);
    await tapAndWait(tester, 'Try again');
    expect(find.text('Identify object'), findsOneWidget);
  });

  testWidgets('camera permission denied shows guidance', (tester) async {
    camera.initializeFailure = const VisionFailure(
      VisionFailureKind.permissionPermanentlyDenied,
    );
    await pumpScreen(tester);

    expect(find.text('Camera access needed'), findsOneWidget);
    expect(find.textContaining('Settings'), findsOneWidget);
  });
}
