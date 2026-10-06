import 'package:app/features/face_recognition/models/face_detection_result.dart';
import 'package:app/features/face_recognition/services/face_detection_service.dart';

/// Returns a preset result; never touches ML Kit or real images.
class FakeFaceDetectionService implements FaceDetectionService {
  FakeFaceDetectionService({this.faces = const [], this.error});

  List<DetectedFace> faces;
  Object? error;
  final List<String> analysedPaths = [];
  int disposeCalls = 0;

  @override
  Future<FaceDetectionResult> detectFacesInFile(String imagePath) async {
    analysedPaths.add(imagePath);
    final failure = error;
    if (failure != null) throw failure;
    return FaceDetectionResult(faces: faces, analysedAt: DateTime(2026));
  }

  @override
  Future<void> dispose() async {
    disposeCalls++;
  }
}
