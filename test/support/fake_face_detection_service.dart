import 'package:app/features/face_recognition/models/enrolled_person.dart';
import 'package:app/features/face_recognition/models/face_detection_result.dart';
import 'package:app/features/face_recognition/services/face_detection_service.dart';

/// Returns a preset result; never touches ML Kit or real images.
class FakeFaceDetectionService implements FaceDetectionService {
  FakeFaceDetectionService({
    this.faces = const [],
    this.matchedPerson,
    this.error,
  });

  List<DetectedFace> faces;
  EnrolledPerson? matchedPerson;
  Object? error;
  final List<String> analysedPaths = [];
  int disposeCalls = 0;

  @override
  Future<FaceDetectionResult> detectFacesInFile(String imagePath) async {
    analysedPaths.add(imagePath);
    final failure = error;
    if (failure != null) throw failure;
    return FaceDetectionResult(
      faces: faces,
      matchedPerson: matchedPerson,
      analysedAt: DateTime(2026),
    );
  }

  @override
  Future<void> dispose() async {
    disposeCalls++;
  }
}
