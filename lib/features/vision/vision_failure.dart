/// Why a camera or on-device vision step could not complete.
enum VisionFailureKind {
  /// The user declined camera access; asking again is possible.
  permissionDenied,

  /// Camera access was denied earlier or is restricted (e.g. parental
  /// controls). The app cannot ask again; the user must change it in the
  /// phone's settings.
  permissionPermanentlyDenied,

  /// The device has no usable camera.
  noCamera,

  /// A camera exists but could not be opened or used right now.
  cameraUnavailable,

  /// The photo was taken but on-device analysis failed.
  processingFailed,
}

/// A user-safe description of a vision failure.
///
/// [debugMessage] is for developers only. It must never contain image data,
/// file contents or personal information; it holds at most an exception type
/// or platform error code.
class VisionFailure implements Exception {
  const VisionFailure(this.kind, {this.debugMessage});

  final VisionFailureKind kind;
  final String? debugMessage;

  /// Short headline suitable for large on-screen text.
  String get title {
    switch (kind) {
      case VisionFailureKind.permissionDenied:
      case VisionFailureKind.permissionPermanentlyDenied:
        return 'Camera access needed';
      case VisionFailureKind.noCamera:
        return 'No camera found';
      case VisionFailureKind.cameraUnavailable:
        return 'Camera not available';
      case VisionFailureKind.processingFailed:
        return 'Could not check the photo';
    }
  }

  /// Plain-language explanation of what happened and what to do next.
  String get userMessage {
    switch (kind) {
      case VisionFailureKind.permissionDenied:
        return 'NeuroEase needs the camera for this. '
            'Tap "Try again" and choose Allow.';
      case VisionFailureKind.permissionPermanentlyDenied:
        return 'Camera access is turned off for NeuroEase. '
            'Open your phone Settings, find NeuroEase and allow the camera.';
      case VisionFailureKind.noCamera:
        return 'This device does not seem to have a camera.';
      case VisionFailureKind.cameraUnavailable:
        return 'The camera may be in use by another app. '
            'Close other camera apps and try again.';
      case VisionFailureKind.processingFailed:
        return 'Something went wrong while checking the photo. '
            'Please try again.';
    }
  }

  /// Whether a "Try again" action makes sense. For a permanently denied
  /// permission, retrying helps once the user has changed it in Settings.
  bool get canRetry => kind != VisionFailureKind.noCamera;

  @override
  String toString() => 'VisionFailure(${kind.name})';
}
