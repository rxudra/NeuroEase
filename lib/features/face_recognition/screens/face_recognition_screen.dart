import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../vision/camera/device_vision_camera.dart';
import '../../vision/widgets/vision_scan_view.dart';
import '../controllers/face_recognition_controller.dart';
import '../models/face_detection_result.dart';
import '../services/face_enrollment_service.dart';
import '../services/mlkit_face_detection_service.dart';
import '../widgets/enroll_person_dialog.dart';
import '../widgets/face_result_panel.dart';
import '../widgets/manage_people_dialog.dart';

/// Tap-to-scan face detection & recognition. All processing happens on the device
/// and face data is stored exclusively locally.
class FaceRecognitionScreen extends StatefulWidget {
  const FaceRecognitionScreen({super.key, this.createController});

  /// Overrides controller creation (tests inject fakes here).
  final FaceRecognitionController Function()? createController;

  @override
  State<FaceRecognitionScreen> createState() => _FaceRecognitionScreenState();
}

class _FaceRecognitionScreenState extends State<FaceRecognitionScreen>
    with WidgetsBindingObserver {
  late final FaceRecognitionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = (widget.createController ?? _defaultController)();
    WidgetsBinding.instance.addObserver(this);
    _controller.initialize();
  }

  static FaceRecognitionController _defaultController() {
    final enrollmentService = FaceEnrollmentService();
    return FaceRecognitionController(
      camera: DeviceVisionCamera(preferredLens: CameraLensDirection.front),
      detector: MlKitFaceDetectionService(enrollmentService: enrollmentService),
      enrollmentService: enrollmentService,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Release the camera whenever the app is not in the foreground.
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _controller.suspend();
      case AppLifecycleState.resumed:
        _controller.resume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  void _onAddPersonPressed() {
    final lastResult = _controller.result;
    if (lastResult == null || !lastResult.hasFaces) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please point the camera at a face and scan first.'),
        ),
      );
      return;
    }

    _showEnrollmentDialog(lastResult.faces.first);
  }

  void _showEnrollmentDialog(DetectedFace face) {
    showDialog<void>(
      context: context,
      builder: (_) => EnrollPersonDialog(
        detectedFace: face,
        onSave: (person) async {
          await _controller.enrollPerson(person);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Saved ${person.name} (${person.relationship}) locally')),
            );
          }
        },
      ),
    );
  }

  void _showManagePeopleDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return ManagePeopleDialog(
            people: _controller.enrolledPeople,
            onDelete: (id) async {
              await _controller.deletePerson(id);
              setDialogState(() {});
              setState(() {});
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Recognition'),
        actions: [
          IconButton(
            key: const Key('add-person-button'),
            icon: const Icon(Icons.person_add_alt_1_outlined),
            tooltip: 'Add Person',
            onPressed: _onAddPersonPressed,
          ),
          IconButton(
            key: const Key('manage-people-button'),
            icon: const Icon(Icons.people_outline),
            tooltip: 'Manage People',
            onPressed: _showManagePeopleDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: VisionScanView<FaceDetectionResult>(
          controller: _controller,
          scanLabel: 'Check for faces',
          readyMessage: 'Point the camera at your face, then tap the button.',
          scanningMessage: 'Looking for faces…',
          resultBuilder: (context, result) {
            return Column(
              children: [
                FaceResultPanel(result: result),
                if (result.hasFaces) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const Key('enroll-face-button'),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Person'),
                    onPressed: () => _showEnrollmentDialog(result.faces.first),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
