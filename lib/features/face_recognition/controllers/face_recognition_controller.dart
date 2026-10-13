import '../../vision/vision_scan_controller.dart';
import '../models/enrolled_person.dart';
import '../models/face_detection_result.dart';
import '../services/face_detection_service.dart';
import '../services/face_enrollment_service.dart';

/// State for the face recognition screen.
///
/// Thin wrapper over [VisionScanController]: takes one photo, runs on-device
/// face detection and matching against local enrolled family profiles.
class FaceRecognitionController
    extends VisionScanController<FaceDetectionResult> {
  FaceRecognitionController({
    required super.camera,
    required FaceDetectionService detector,
    FaceEnrollmentService? enrollmentService,
  })  : _enrollmentService = enrollmentService ?? FaceEnrollmentService(),
        super(
          analyse: detector.detectFacesInFile,
          onDispose: detector.dispose,
        );

  final FaceEnrollmentService _enrollmentService;

  FaceEnrollmentService get enrollmentService => _enrollmentService;
  List<EnrolledPerson> get enrolledPeople => _enrollmentService.enrolledPeople;

  @override
  Future<void> initialize() async {
    await _enrollmentService.initialize();
    await super.initialize();
  }

  Future<void> enrollPerson(EnrolledPerson person) async {
    await _enrollmentService.enrollPerson(person);
    notifyListeners();
  }

  Future<void> deletePerson(String id) async {
    await _enrollmentService.deletePerson(id);
    notifyListeners();
  }
}
