import '../models/object_recognition_result.dart';

/// Recognises objects in a photo, entirely on the device.
abstract class ObjectRecognitionService {
  /// Analyses the photo at [imagePath]. Throws `VisionFailure` on failure.
  /// Does not keep, copy or upload the photo.
  Future<ObjectRecognitionResult> recognizeObjectsInFile(String imagePath);

  /// Releases native resources.
  Future<void> dispose();
}
