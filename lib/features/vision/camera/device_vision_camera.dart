import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';

import '../vision_failure.dart';
import 'vision_camera.dart';

/// Loads the list of cameras on the device. Injectable for tests.
typedef CameraListLoader = Future<List<CameraDescription>> Function();

/// [VisionCamera] backed by the official `camera` plugin.
///
/// This is the only file in the vision features that talks to the camera
/// plugin directly. Runtime permission prompts are handled by the plugin
/// itself when [initialize] is called.
class DeviceVisionCamera implements VisionCamera {
  DeviceVisionCamera({
    this.preferredLens = CameraLensDirection.back,
    CameraListLoader? loadCameras,
  }) : _loadCameras = loadCameras ?? availableCameras;

  /// Which camera to use when the device has several.
  final CameraLensDirection preferredLens;

  final CameraListLoader _loadCameras;
  CameraController? _controller;

  @override
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  @override
  Future<void> initialize() async {
    if (isInitialized) return;

    final List<CameraDescription> cameras;
    try {
      cameras = await _loadCameras();
    } on CameraException catch (e) {
      throw visionFailureFromCameraException(e);
    } catch (e) {
      throw VisionFailure(
        VisionFailureKind.cameraUnavailable,
        debugMessage: e.runtimeType.toString(),
      );
    }

    if (cameras.isEmpty) {
      throw const VisionFailure(VisionFailureKind.noCamera);
    }

    final description = cameras.firstWhere(
      (camera) => camera.lensDirection == preferredLens,
      orElse: () => cameras.first,
    );

    // Audio is never needed: only still photos are taken.
    final controller = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      await controller.dispose();
      throw visionFailureFromCameraException(e);
    }

    _controller = controller;
  }

  @override
  Future<String> capturePhoto() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      throw const VisionFailure(VisionFailureKind.cameraUnavailable);
    }
    try {
      final photo = await controller.takePicture();
      return photo.path;
    } on CameraException catch (e) {
      throw visionFailureFromCameraException(e);
    }
  }

  @override
  Future<void> discardPhoto(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Best effort: the file lives in the app's private temporary
      // directory, which the operating system also clears.
    }
  }

  @override
  Widget buildPreview() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }
    return CameraPreview(controller);
  }

  @override
  Future<void> dispose() async {
    final controller = _controller;
    _controller = null;
    await controller?.dispose();
  }
}

/// Maps the `camera` plugin's error codes to a [VisionFailure].
///
/// Error codes are documented in the camera plugin README.
VisionFailure visionFailureFromCameraException(CameraException e) {
  switch (e.code) {
    case 'CameraAccessDenied':
      return VisionFailure(
        VisionFailureKind.permissionDenied,
        debugMessage: e.code,
      );
    case 'CameraAccessDeniedWithoutPrompt':
    case 'CameraAccessRestricted':
      return VisionFailure(
        VisionFailureKind.permissionPermanentlyDenied,
        debugMessage: e.code,
      );
    default:
      return VisionFailure(
        VisionFailureKind.cameraUnavailable,
        debugMessage: e.code,
      );
  }
}
