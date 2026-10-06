import 'dart:async';

import 'package:app/features/object_recognition/models/object_recognition_result.dart';
import 'package:app/features/object_recognition/services/object_recognition_service.dart';

/// Returns a preset result; never touches ML Kit or real images.
class FakeObjectRecognitionService implements ObjectRecognitionService {
  FakeObjectRecognitionService({
    this.labels = const [],
    this.objects = const [],
    this.error,
  });

  List<RecognizedLabel> labels;
  List<LocatedObject> objects;
  Object? error;

  /// When set, recognition waits for it (lets tests observe "scanning").
  Completer<void>? gate;
  final List<String> analysedPaths = [];
  int disposeCalls = 0;

  @override
  Future<ObjectRecognitionResult> recognizeObjectsInFile(
    String imagePath,
  ) async {
    analysedPaths.add(imagePath);
    final pending = gate;
    if (pending != null) await pending.future;
    final failure = error;
    if (failure != null) throw failure;
    return ObjectRecognitionResult(
      labels: labels,
      objects: objects,
      analysedAt: DateTime(2026),
    );
  }

  @override
  Future<void> dispose() async {
    disposeCalls++;
  }
}
