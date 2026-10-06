import 'package:flutter/foundation.dart';

import 'camera/vision_camera.dart';
import 'vision_failure.dart';

/// Where a tap-to-scan vision screen currently is.
enum VisionScanStatus {
  /// Camera closed (not started yet, or released while the app is in the
  /// background).
  idle,

  /// Opening the camera / waiting for the permission prompt.
  initializing,

  /// Camera preview is live and a scan can be started.
  ready,

  /// A photo is being taken and analysed on-device.
  scanning,

  /// A result is available in [VisionScanController.result].
  result,

  /// Something failed; see [VisionScanController.failure].
  error,
}

/// Analyses one temporary photo and returns a result.
typedef VisionAnalyser<T> = Future<T> Function(String imagePath);

/// Shared tap-to-scan state machine for the vision features.
///
/// Flow: [initialize] opens the camera, [scan] takes one still photo, hands
/// its temporary path to the analyser, then always deletes the photo, even
/// when analysis fails. No photo, frame or result is persisted or uploaded.
///
/// Widgets observe this controller; they never touch the camera or ML code.
class VisionScanController<T> extends ChangeNotifier {
  VisionScanController({
    required this.camera,
    required this.analyse,
    this.onDispose,
  });

  final VisionCamera camera;

  /// Analyses one temporary photo.
  final VisionAnalyser<T> analyse;

  /// Releases the analyser's native resources; called from [dispose].
  final Future<void> Function()? onDispose;

  VisionScanStatus _status = VisionScanStatus.idle;
  T? _result;
  VisionFailure? _failure;
  bool _disposed = false;

  VisionScanStatus get status => _status;

  /// Latest result. Only set while [status] is [VisionScanStatus.result].
  T? get result => _result;

  /// Latest failure. Only set while [status] is [VisionScanStatus.error].
  VisionFailure? get failure => _failure;

  bool get isBusy =>
      _status == VisionScanStatus.initializing ||
      _status == VisionScanStatus.scanning;

  /// Whether the live preview can be shown.
  bool get showPreview =>
      camera.isInitialized &&
      (_status == VisionScanStatus.ready ||
          _status == VisionScanStatus.scanning ||
          _status == VisionScanStatus.result);

  /// Opens the camera. Safe to call repeatedly.
  Future<void> initialize() async {
    if (_disposed || _status == VisionScanStatus.initializing) return;
    if (camera.isInitialized) {
      if (_status == VisionScanStatus.idle ||
          _status == VisionScanStatus.error) {
        _failure = null;
        _setStatus(VisionScanStatus.ready);
      }
      return;
    }

    _failure = null;
    _result = null;
    _setStatus(VisionScanStatus.initializing);

    try {
      await camera.initialize();
      if (_disposed) return;
      _setStatus(VisionScanStatus.ready);
    } on VisionFailure catch (failure) {
      _fail(failure);
    } catch (e) {
      _fail(
        VisionFailure(
          VisionFailureKind.cameraUnavailable,
          debugMessage: e.runtimeType.toString(),
        ),
      );
    }
  }

  /// Takes one photo, analyses it on-device and deletes it.
  ///
  /// Ignored while busy or when the camera is not ready.
  Future<void> scan() async {
    if (_disposed || isBusy || !camera.isInitialized) return;

    _result = null;
    _failure = null;
    _setStatus(VisionScanStatus.scanning);

    String? photoPath;
    try {
      photoPath = await camera.capturePhoto();
      final result = await analyse(photoPath);
      if (_disposed) return;
      _result = result;
      _setStatus(VisionScanStatus.result);
    } on VisionFailure catch (failure) {
      _fail(failure);
    } catch (e) {
      _fail(
        VisionFailure(
          VisionFailureKind.processingFailed,
          debugMessage: e.runtimeType.toString(),
        ),
      );
    } finally {
      if (photoPath != null) {
        await camera.discardPhoto(photoPath);
      }
    }
  }

  /// Goes back to the live preview after a result or a failure.
  Future<void> retry() async {
    if (_disposed || isBusy) return;
    if (camera.isInitialized) {
      _result = null;
      _failure = null;
      _setStatus(VisionScanStatus.ready);
    } else {
      await initialize();
    }
  }

  /// Releases the camera, e.g. when the app goes to the background.
  /// A failure state is kept so the user still sees the explanation.
  ///
  /// Ignored while the camera is starting: the operating system's permission
  /// dialog briefly makes the app inactive, and closing the camera then would
  /// break the first launch.
  Future<void> suspend() async {
    if (_disposed || _status == VisionScanStatus.initializing) return;
    await camera.dispose();
    if (_disposed) return;
    _result = null;
    if (_status != VisionScanStatus.error) {
      _setStatus(VisionScanStatus.idle);
    }
  }

  /// Re-opens the camera after [suspend]. Also retries after a camera
  /// failure, e.g. when the user has just allowed the camera in Settings.
  Future<void> resume() async {
    if (_disposed) return;
    final cameraFailed =
        _status == VisionScanStatus.error && !camera.isInitialized;
    if (_status == VisionScanStatus.idle || cameraFailed) {
      await initialize();
    }
  }

  void _fail(VisionFailure failure) {
    if (_disposed) return;
    _result = null;
    _failure = failure;
    _setStatus(VisionScanStatus.error);
  }

  void _setStatus(VisionScanStatus status) {
    if (_disposed) return;
    _status = status;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    camera.dispose();
    onDispose?.call();
    super.dispose();
  }
}
