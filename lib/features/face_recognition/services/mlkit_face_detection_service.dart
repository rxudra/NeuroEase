import 'dart:ui' show Offset;

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart'
    as mlkit;

import '../../vision/vision_failure.dart';
import '../models/face_detection_result.dart';
import 'face_detection_service.dart';

/// [FaceDetectionService] using Google ML Kit's on-device face detector.
///
/// The bundled model runs locally; no image is sent to any server. This is
/// the only file in the face feature that imports ML Kit.
class MlKitFaceDetectionService implements FaceDetectionService {
  MlKitFaceDetectionService({double minFaceSize = 0.15})
    : _options = mlkit.FaceDetectorOptions(
        enableLandmarks: true,
        enableClassification: true,
        performanceMode: mlkit.FaceDetectorMode.accurate,
        minFaceSize: minFaceSize,
      );

  final mlkit.FaceDetectorOptions _options;
  mlkit.FaceDetector? _detector;

  static const Map<mlkit.FaceLandmarkType, FaceLandmarkPoint> _landmarkMap = {
    mlkit.FaceLandmarkType.leftEye: FaceLandmarkPoint.leftEye,
    mlkit.FaceLandmarkType.rightEye: FaceLandmarkPoint.rightEye,
    mlkit.FaceLandmarkType.noseBase: FaceLandmarkPoint.noseBase,
    mlkit.FaceLandmarkType.leftMouth: FaceLandmarkPoint.leftMouth,
    mlkit.FaceLandmarkType.rightMouth: FaceLandmarkPoint.rightMouth,
    mlkit.FaceLandmarkType.bottomMouth: FaceLandmarkPoint.bottomMouth,
    mlkit.FaceLandmarkType.leftEar: FaceLandmarkPoint.leftEar,
    mlkit.FaceLandmarkType.rightEar: FaceLandmarkPoint.rightEar,
    mlkit.FaceLandmarkType.leftCheek: FaceLandmarkPoint.leftCheek,
    mlkit.FaceLandmarkType.rightCheek: FaceLandmarkPoint.rightCheek,
  };

  @override
  Future<FaceDetectionResult> detectFacesInFile(String imagePath) async {
    final detector = _detector ??= mlkit.FaceDetector(options: _options);
    try {
      final faces = await detector.processImage(
        mlkit.InputImage.fromFilePath(imagePath),
      );
      return FaceDetectionResult(
        faces: faces.map(_toDetectedFace).toList(growable: false),
        analysedAt: DateTime.now(),
      );
    } catch (e) {
      // Only the exception type is kept: never the image or its path.
      throw VisionFailure(
        VisionFailureKind.processingFailed,
        debugMessage: e.runtimeType.toString(),
      );
    }
  }

  DetectedFace _toDetectedFace(mlkit.Face face) {
    final landmarks = <FaceLandmarkPoint, Offset>{};
    for (final entry in face.landmarks.entries) {
      final point = _landmarkMap[entry.key];
      final landmark = entry.value;
      if (point != null && landmark != null) {
        landmarks[point] = Offset(
          landmark.position.x.toDouble(),
          landmark.position.y.toDouble(),
        );
      }
    }

    return DetectedFace(
      boundingBox: face.boundingBox,
      smilingProbability: face.smilingProbability,
      leftEyeOpenProbability: face.leftEyeOpenProbability,
      rightEyeOpenProbability: face.rightEyeOpenProbability,
      headTurnDegrees: face.headEulerAngleY,
      headTiltDegrees: face.headEulerAngleZ,
      landmarks: Map.unmodifiable(landmarks),
    );
  }

  @override
  Future<void> dispose() async {
    final detector = _detector;
    _detector = null;
    await detector?.close();
  }
}
