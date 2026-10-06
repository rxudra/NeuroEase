import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart'
    as labeling;
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart'
    as detection;

import '../../vision/vision_failure.dart';
import '../models/object_recognition_result.dart';
import 'object_recognition_service.dart';

/// [ObjectRecognitionService] using two Google ML Kit on-device models:
///
/// * Image labeling names what is in the photo ("Cup", "Chair", ...; 400+
///   classes) with a confidence score. This is what the user is told.
/// * Object detection locates separate objects (bounding boxes) with a
///   coarse category ("Food", "Home good", ...). Kept for counts and future
///   overlays.
///
/// Both models are bundled with the app; no image leaves the device. This is
/// the only file in the object feature that imports ML Kit.
class MlKitObjectRecognitionService implements ObjectRecognitionService {
  MlKitObjectRecognitionService({double labelThreshold = 0.5})
    : _labelThreshold = labelThreshold;

  final double _labelThreshold;
  labeling.ImageLabeler? _labeler;
  detection.ObjectDetector? _detector;

  @override
  Future<ObjectRecognitionResult> recognizeObjectsInFile(
    String imagePath,
  ) async {
    final labeler = _labeler ??= labeling.ImageLabeler(
      options: labeling.ImageLabelerOptions(
        confidenceThreshold: _labelThreshold,
      ),
    );
    final detector = _detector ??= detection.ObjectDetector(
      options: detection.ObjectDetectorOptions(
        mode: detection.DetectionMode.single,
        classifyObjects: true,
        multipleObjects: true,
      ),
    );

    try {
      final labels = await labeler.processImage(
        labeling.InputImage.fromFilePath(imagePath),
      );
      final objects = await detector.processImage(
        detection.InputImage.fromFilePath(imagePath),
      );

      return ObjectRecognitionResult(
        labels: [
          for (final label in labels)
            RecognizedLabel(name: label.label, confidence: label.confidence),
        ],
        objects: [for (final object in objects) _toLocatedObject(object)],
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

  LocatedObject _toLocatedObject(detection.DetectedObject object) {
    detection.Label? best;
    for (final label in object.labels) {
      if (best == null || label.confidence > best.confidence) best = label;
    }
    return LocatedObject(
      boundingBox: object.boundingBox,
      category: best?.text,
      categoryConfidence: best?.confidence,
    );
  }

  @override
  Future<void> dispose() async {
    final labeler = _labeler;
    final detector = _detector;
    _labeler = null;
    _detector = null;
    await labeler?.close();
    await detector?.close();
  }
}
