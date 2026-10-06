import '../../vision/vision_scan_controller.dart';
import '../models/face_detection_result.dart';
import '../services/face_detection_service.dart';

/// State for the face detection screen.
///
/// Thin wrapper over [VisionScanController]: takes one photo, runs on-device
/// face detection, deletes the photo, exposes the result.
class FaceRecognitionController
    extends VisionScanController<FaceDetectionResult> {
  FaceRecognitionController({
    required super.camera,
    required FaceDetectionService detector,
  }) : super(
         analyse: detector.detectFacesInFile,
         onDispose: detector.dispose,
       );
}
