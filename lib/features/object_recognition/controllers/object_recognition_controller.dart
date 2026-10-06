import '../../vision/vision_scan_controller.dart';
import '../models/object_recognition_result.dart';
import '../services/object_recognition_service.dart';

/// State for the object recognition screen.
///
/// Thin wrapper over [VisionScanController]: takes one photo, recognises
/// objects on-device, deletes the photo, exposes the result.
class ObjectRecognitionController
    extends VisionScanController<ObjectRecognitionResult> {
  ObjectRecognitionController({
    required super.camera,
    required ObjectRecognitionService recognizer,
  }) : super(
         analyse: recognizer.recognizeObjectsInFile,
         onDispose: recognizer.dispose,
       );
}
