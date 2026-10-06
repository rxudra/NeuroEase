import '../models/face_detection_result.dart';

/// Detects faces in a photo, entirely on the device.
///
/// This is face *detection* (is there a face, where, simple expression
/// estimates). It does not identify who a person is: identity matching
/// would require storing biometric templates and needs a separate consent
/// and security design before it is built.
abstract class FaceDetectionService {
  /// Analyses the photo at [imagePath]. Throws `VisionFailure` on failure.
  /// Does not keep, copy or upload the photo.
  Future<FaceDetectionResult> detectFacesInFile(String imagePath);

  /// Releases native detector resources.
  Future<void> dispose();
}
