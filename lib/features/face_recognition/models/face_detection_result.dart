import 'dart:ui' show Offset, Rect;

import 'enrolled_person.dart';

/// Facial landmarks NeuroEase exposes. Independent of the ML library so the
/// rest of the app never imports ML Kit types.
enum FaceLandmarkPoint {
  leftEye,
  rightEye,
  noseBase,
  leftMouth,
  rightMouth,
  bottomMouth,
  leftEar,
  rightEar,
  leftCheek,
  rightCheek,
}

/// One face found in a photo.
class DetectedFace {
  const DetectedFace({
    required this.boundingBox,
    this.smilingProbability,
    this.leftEyeOpenProbability,
    this.rightEyeOpenProbability,
    this.headTurnDegrees,
    this.headTiltDegrees,
    this.landmarks = const {},
  });

  /// Smiling probability at or above which a face is described as smiling.
  static const double smilingThreshold = 0.7;

  /// Eye-open probability at or above which an eye is treated as open.
  static const double eyeOpenThreshold = 0.5;

  /// Head turn (left/right) within which a face counts as facing the camera.
  static const double facingCameraMaxDegrees = 20;

  /// Position of the face in the photo, in image pixels.
  final Rect boundingBox;

  /// 0.0–1.0, or null when the detector could not estimate it.
  final double? smilingProbability;
  final double? leftEyeOpenProbability;
  final double? rightEyeOpenProbability;

  /// Left/right head rotation (Euler Y), in degrees.
  final double? headTurnDegrees;

  /// Sideways head tilt (Euler Z), in degrees.
  final double? headTiltDegrees;

  /// Landmark positions in image pixels. Missing landmarks are omitted.
  final Map<FaceLandmarkPoint, Offset> landmarks;

  bool get isLikelySmiling =>
      (smilingProbability ?? 0) >= smilingThreshold;

  /// True/false when both eye estimates exist, otherwise null (unknown).
  bool? get eyesOpen {
    final left = leftEyeOpenProbability;
    final right = rightEyeOpenProbability;
    if (left == null || right == null) return null;
    return left >= eyeOpenThreshold && right >= eyeOpenThreshold;
  }

  /// Null when the head angle is unknown.
  bool? get isFacingCamera {
    final turn = headTurnDegrees;
    if (turn == null) return null;
    return turn.abs() <= facingCameraMaxDegrees;
  }

  /// Short plain-language description, e.g. "Looking at the camera, smiling".
  String get description {
    final parts = <String>[];
    final facing = isFacingCamera;
    if (facing != null) {
      parts.add(facing ? 'Looking at the camera' : 'Turned away');
    }
    if (isLikelySmiling) parts.add('smiling');
    final eyes = eyesOpen;
    if (eyes != null) parts.add(eyes ? 'eyes open' : 'eyes closed');
    if (parts.isEmpty) return 'Face found';
    final text = parts.join(', ');
    return text[0].toUpperCase() + text.substring(1);
  }
}

/// Outcome of checking one photo for faces.
class FaceDetectionResult {
  const FaceDetectionResult({
    required this.faces,
    required this.analysedAt,
    this.matchedPerson,
  });

  FaceDetectionResult.empty({DateTime? analysedAt})
    : faces = const [],
      matchedPerson = null,
      analysedAt = analysedAt ?? DateTime.now();

  final List<DetectedFace> faces;
  final EnrolledPerson? matchedPerson;
  final DateTime analysedAt;

  int get faceCount => faces.length;
  bool get hasFaces => faces.isNotEmpty;
  bool get isKnownPerson => matchedPerson != null;

  /// Headline for the result:
  /// - Known match: "Hello, [Name]"
  /// - Unconfirmed match: "Person detected"
  /// - No face: "No person detected"
  String get summary {
    final person = matchedPerson;
    if (person != null) {
      return 'Hello, ${person.name}';
    }
    if (hasFaces) {
      return 'Person detected';
    }
    return 'No person detected';
  }

  /// Subtitle for the result panel:
  /// - Known match: "[Saved relationship]"
  /// - Unconfirmed match: "Identity not confirmed"
  /// - No face: "Move closer and make sure your face is visible."
  String get subtitle {
    final person = matchedPerson;
    if (person != null) {
      return person.relationship;
    }
    if (hasFaces) {
      return 'Identity not confirmed';
    }
    return 'Move closer and make sure your face is visible.';
  }
}
