import 'package:flutter/material.dart';

import '../../vision/camera/device_vision_camera.dart';
import '../../vision/widgets/vision_scan_view.dart';
import '../controllers/object_recognition_controller.dart';
import '../models/object_recognition_result.dart';
import '../services/mlkit_object_recognition_service.dart';
import '../widgets/object_result_panel.dart';

/// Tap-to-scan object recognition. All processing happens on the device and
/// the photo is deleted immediately after it is checked.
class ObjectRecognitionScreen extends StatefulWidget {
  const ObjectRecognitionScreen({super.key, this.createController});

  /// Overrides controller creation (tests inject fakes here).
  final ObjectRecognitionController Function()? createController;

  @override
  State<ObjectRecognitionScreen> createState() =>
      _ObjectRecognitionScreenState();
}

class _ObjectRecognitionScreenState extends State<ObjectRecognitionScreen>
    with WidgetsBindingObserver {
  late final ObjectRecognitionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = (widget.createController ?? _defaultController)();
    WidgetsBinding.instance.addObserver(this);
    _controller.initialize();
  }

  static ObjectRecognitionController _defaultController() {
    return ObjectRecognitionController(
      camera: DeviceVisionCamera(),
      recognizer: MlKitObjectRecognitionService(),
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
      appBar: AppBar(title: const Text('What is this?')),
      body: SafeArea(
        child: VisionScanView<ObjectRecognitionResult>(
          controller: _controller,
          scanLabel: 'Identify object',
          readyMessage: 'Point the camera at an object, then tap the button.',
          scanningMessage: 'Looking at the object…',
          resultBuilder: (context, result) =>
              ObjectResultPanel(result: result),
        ),
      ),
    );
  }
}
