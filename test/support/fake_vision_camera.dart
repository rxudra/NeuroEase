import 'dart:async';

import 'package:app/features/vision/camera/vision_camera.dart';
import 'package:app/features/vision/vision_failure.dart';
import 'package:flutter/widgets.dart';

/// In-memory [VisionCamera] for tests. No real camera, no real files.
class FakeVisionCamera implements VisionCamera {
  FakeVisionCamera({this.initializeFailure, this.captureFailure});

  /// Thrown by [initialize] when set.
  VisionFailure? initializeFailure;

  /// Thrown by [capturePhoto] when set.
  VisionFailure? captureFailure;

  /// When set, [initialize] waits for it (lets tests observe "initializing").
  Completer<void>? initializeGate;

  bool _initialized = false;
  int initializeCalls = 0;
  int disposeCalls = 0;
  int _photoCounter = 0;

  /// Paths handed out by [capturePhoto] and not yet discarded.
  final Set<String> outstandingPhotos = {};
  final List<String> discardedPhotos = [];

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    initializeCalls++;
    final gate = initializeGate;
    if (gate != null) await gate.future;
    final failure = initializeFailure;
    if (failure != null) throw failure;
    _initialized = true;
  }

  @override
  Future<String> capturePhoto() async {
    final failure = captureFailure;
    if (failure != null) throw failure;
    final path = 'fake://photo-${_photoCounter++}.jpg';
    outstandingPhotos.add(path);
    return path;
  }

  @override
  Future<void> discardPhoto(String path) async {
    outstandingPhotos.remove(path);
    discardedPhotos.add(path);
  }

  @override
  Widget buildPreview() =>
      const SizedBox.expand(key: Key('fake-camera-preview'));

  @override
  Future<void> dispose() async {
    disposeCalls++;
    _initialized = false;
  }
}
