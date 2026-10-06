import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../vision/camera/device_vision_camera.dart';
import '../../vision/widgets/vision_scan_view.dart';
import '../controllers/face_recognition_controller.dart';
import '../models/face_detection_result.dart';
import '../services/mlkit_face_detection_service.dart';
import '../widgets/face_result_panel.dart';

/// Tap-to-scan face detection. All processing happens on the device and the
/// photo is deleted immediately after it is checked.
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
    return FaceRecognitionController(
      camera: DeviceVisionCamera(preferredLens: CameraLensDirection.front),
      detector: MlKitFaceDetectionService(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face Recognition')),
      body: SafeArea(
        child: VisionScanView<FaceDetectionResult>(
          controller: _controller,
          scanLabel: 'Check for faces',
          readyMessage: 'Point the camera at your face, then tap the button.',
          scanningMessage: 'Looking for faces…',
          resultBuilder: (context, result) => FaceResultPanel(result: result),
        ),
      ),
    );
  }
}
