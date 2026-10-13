import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import '../models/enrolled_person.dart';
import '../models/face_detection_result.dart';

/// Strategy function for matching a detected face against enrolled profiles.
typedef FaceMatcher = EnrolledPerson? Function(
  DetectedFace face,
  List<EnrolledPerson> enrolledPeople,
);

/// Local service for managing enrolled family members and care team profiles.
/// All profile information is stored exclusively on-device.
class FaceEnrollmentService extends ChangeNotifier {
  FaceEnrollmentService({
    this.storagePath,
    this.matcher,
  });

  final String? storagePath;
  final FaceMatcher? matcher;
  final List<EnrolledPerson> _enrolledPeople = [];
  bool _initialized = false;

  List<EnrolledPerson> get enrolledPeople => List.unmodifiable(_enrolledPeople);

  /// Loads enrolled profiles from local device storage.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _loadFromDisk();
  }

  /// Adds a new enrolled person profile and persists it to local device storage.
  Future<void> enrollPerson(EnrolledPerson person) async {
    await initialize();
    _enrolledPeople.removeWhere((p) => p.id == person.id);
    _enrolledPeople.add(person);
    _saveToDisk();
    notifyListeners();
  }

  /// Removes an enrolled person profile and updates local device storage.
  Future<void> deletePerson(String id) async {
    await initialize();
    _enrolledPeople.removeWhere((p) => p.id == id);
    _saveToDisk();
    notifyListeners();
  }

  /// Clears all enrolled people (used in tests / reset).
  Future<void> clearAll() async {
    await initialize();
    _enrolledPeople.clear();
    _saveToDisk();
    notifyListeners();
  }

  /// Matches a detected face against enrolled profiles.
  ///
  /// ML Kit Face Detection provides bounding box, facial landmarks, and pose estimates,
  /// but does NOT provide identity recognition or facial embeddings.
  /// Because no verified on-device embedding model (e.g. MobileFaceNet running on TFLite)
  /// is currently bundled in this build, live detection returns null ("Identity not confirmed")
  /// rather than faking matches or misidentifying people.
  /// A custom [FaceMatcher] can be supplied for unit testing or when a verified model is added.
  EnrolledPerson? matchFace(DetectedFace face) {
    final activeMatcher = matcher;
    if (activeMatcher != null) {
      return activeMatcher(face, _enrolledPeople);
    }
    return null;
  }

  File? _getStorageFile() {
    try {
      final path = storagePath ?? '${Directory.systemTemp.path}/neuroease_enrolled_people.json';
      return File(path);
    } catch (_) {
      return null;
    }
  }

  void _loadFromDisk() {
    try {
      final file = _getStorageFile();
      if (file == null || !file.existsSync()) return;
      final content = file.readAsStringSync();
      if (content.trim().isEmpty) return;

      final List<dynamic> jsonList = jsonDecode(content) as List<dynamic>;
      _enrolledPeople.clear();
      for (final item in jsonList) {
        if (item is Map<String, dynamic>) {
          _enrolledPeople.add(EnrolledPerson.fromJson(item));
        }
      }
    } catch (_) {
      // Best effort local storage read fallback
    }
  }

  void _saveToDisk() {
    try {
      final file = _getStorageFile();
      if (file == null) return;
      final jsonList = _enrolledPeople.map((p) => p.toJson()).toList();
      file.writeAsStringSync(jsonEncode(jsonList));
    } catch (_) {
      // Best effort local storage write fallback
    }
  }
}
