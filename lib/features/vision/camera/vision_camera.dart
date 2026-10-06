import 'package:flutter/widgets.dart';

/// Camera access used by the vision features.
///
/// Controllers depend on this interface rather than on the `camera` plugin,
/// so all state handling can be unit-tested without a physical camera.
///
/// Implementations throw `VisionFailure` for every expected failure.
abstract class VisionCamera {
  /// Whether the camera is open and ready to take a photo.
  bool get isInitialized;

  /// Opens the camera. Triggers the operating system's permission prompt the
  /// first time it is called.
  Future<void> initialize();

  /// Takes one still photo and returns the path of a temporary file.
  ///
  /// The caller must pass the path to [discardPhoto] as soon as it has been
  /// analysed. Photos are never kept.
  Future<String> capturePhoto();

  /// Deletes a temporary photo created by [capturePhoto]. Never throws.
  Future<void> discardPhoto(String path);

  /// The live camera preview, or an empty box when not initialized.
  Widget buildPreview();

  /// Releases the camera. Safe to call more than once; [initialize] may be
  /// called again afterwards (e.g. when the app returns to the foreground).
  Future<void> dispose();
}
