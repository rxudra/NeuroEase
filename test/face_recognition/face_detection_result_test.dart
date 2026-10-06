import 'dart:ui';

import 'package:app/features/face_recognition/models/face_detection_result.dart';
import 'package:flutter_test/flutter_test.dart';

const _box = Rect.fromLTWH(10, 20, 100, 120);

void main() {
  group('FaceDetectionResult', () {
    test('empty result has no faces', () {
      final result = FaceDetectionResult.empty();
      expect(result.hasFaces, isFalse);
      expect(result.faceCount, 0);
      expect(result.summary, 'No person detected');
    });

    test('summary returns person detected when faces present', () {
      final one = FaceDetectionResult(
        faces: const [DetectedFace(boundingBox: _box)],
        analysedAt: DateTime(2026),
      );
      final three = FaceDetectionResult(
        faces: const [
          DetectedFace(boundingBox: _box),
          DetectedFace(boundingBox: _box),
          DetectedFace(boundingBox: _box),
        ],
        analysedAt: DateTime(2026),
      );
      expect(one.summary, '👤 Person detected');
      expect(three.summary, '👤 Person detected');
      expect(three.hasFaces, isTrue);
    });
  });

  group('DetectedFace', () {
    test('smiling uses the 0.7 threshold', () {
      expect(
        const DetectedFace(boundingBox: _box, smilingProbability: 0.7)
            .isLikelySmiling,
        isTrue,
      );
      expect(
        const DetectedFace(boundingBox: _box, smilingProbability: 0.69)
            .isLikelySmiling,
        isFalse,
      );
      expect(const DetectedFace(boundingBox: _box).isLikelySmiling, isFalse);
    });

    test('eyesOpen needs both estimates', () {
      expect(
        const DetectedFace(
          boundingBox: _box,
          leftEyeOpenProbability: 0.9,
          rightEyeOpenProbability: 0.8,
        ).eyesOpen,
        isTrue,
      );
      expect(
        const DetectedFace(
          boundingBox: _box,
          leftEyeOpenProbability: 0.9,
          rightEyeOpenProbability: 0.1,
        ).eyesOpen,
        isFalse,
      );
      expect(
        const DetectedFace(boundingBox: _box, leftEyeOpenProbability: 0.9)
            .eyesOpen,
        isNull,
      );
    });

    test('facing camera within 20 degrees either way', () {
      expect(
        const DetectedFace(boundingBox: _box, headTurnDegrees: -20)
            .isFacingCamera,
        isTrue,
      );
      expect(
        const DetectedFace(boundingBox: _box, headTurnDegrees: 35)
            .isFacingCamera,
        isFalse,
      );
      expect(const DetectedFace(boundingBox: _box).isFacingCamera, isNull);
    });

    test('description combines known attributes', () {
      const face = DetectedFace(
        boundingBox: _box,
        headTurnDegrees: 3,
        smilingProbability: 0.95,
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.9,
      );
      expect(face.description, 'Looking at the camera, smiling, eyes open');
    });

    test('description capitalises when only some attributes are known', () {
      const face = DetectedFace(boundingBox: _box, smilingProbability: 0.9);
      expect(face.description, 'Smiling');
    });

    test('description falls back when nothing is known', () {
      expect(const DetectedFace(boundingBox: _box).description, 'Face found');
    });

    test('landmarks default to empty', () {
      expect(const DetectedFace(boundingBox: _box).landmarks, isEmpty);
    });
  });
}
