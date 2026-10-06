import 'dart:ui' show Rect;

/// How sure the recogniser is, in words a user can act on.
enum ConfidenceLevel {
  /// At or above [RecognizedLabel.highThreshold].
  high,

  /// At or above [ObjectRecognitionResult.displayThreshold].
  medium,

  /// Below [ObjectRecognitionResult.displayThreshold]: never stated as fact.
  low,
}

/// A named thing the recogniser believes is in the photo, e.g. "Cup".
class RecognizedLabel {
  const RecognizedLabel({required this.name, required this.confidence});

  static const double highThreshold = 0.8;

  final String name;

  /// 0.0–1.0.
  final double confidence;

  ConfidenceLevel get level {
    if (confidence >= highThreshold) return ConfidenceLevel.high;
    if (confidence >= ObjectRecognitionResult.displayThreshold) {
      return ConfidenceLevel.medium;
    }
    return ConfidenceLevel.low;
  }

  /// "92%".
  String get percentText => '${(confidence * 100).round()}%';

  /// "Very likely" / "Likely" / "Not sure".
  String get confidenceText {
    switch (level) {
      case ConfidenceLevel.high:
        return 'Very likely';
      case ConfidenceLevel.medium:
        return 'Likely';
      case ConfidenceLevel.low:
        return 'Not sure';
    }
  }
}

/// A separate object located in the photo (position + coarse category).
class LocatedObject {
  const LocatedObject({
    required this.boundingBox,
    this.category,
    this.categoryConfidence,
  });

  /// Position in image pixels.
  final Rect boundingBox;

  /// Coarse category such as "Food" or "Home good", or null if unknown.
  final String? category;
  final double? categoryConfidence;
}

/// Outcome of checking one photo for objects.
///
/// Contains no image data and is deliberately not serialisable: results are
/// shown to the user and then discarded.
class ObjectRecognitionResult {
  ObjectRecognitionResult({
    required List<RecognizedLabel> labels,
    this.objects = const [],
    required this.analysedAt,
  }) : labels = List.unmodifiable(
         [...labels]..sort((a, b) => b.confidence.compareTo(a.confidence)),
       );

  ObjectRecognitionResult.empty({DateTime? analysedAt})
    : labels = const [],
      objects = const [],
      analysedAt = analysedAt ?? DateTime.now();

  /// Labels below this are never presented as what the object *is*.
  static const double displayThreshold = 0.6;

  /// At most this many names are shown, to avoid overwhelming the user.
  static const int maxLabelsShown = 3;

  /// All labels, most confident first.
  final List<RecognizedLabel> labels;
  final List<LocatedObject> objects;
  final DateTime analysedAt;

  /// Labels confident enough to state, most confident first (max 3).
  List<RecognizedLabel> get confidentLabels => labels
      .where((label) => label.confidence >= displayThreshold)
      .take(maxLabelsShown)
      .toList(growable: false);

  bool get hasConfidentResult => confidentLabels.isNotEmpty;

  /// Nothing at all was found.
  bool get isEmpty => labels.isEmpty && objects.isEmpty;

  int get objectCount => objects.length;

  /// Best low-confidence guess, only when nothing is confident.
  RecognizedLabel? get tentativeGuess {
    if (hasConfidentResult || labels.isEmpty) return null;
    return labels.first;
  }

  /// One-line headline, e.g. "I can see: Cup, Laptop and Table".
  String get summary {
    final names = confidentLabels.map((label) => label.name).toList();
    if (names.isNotEmpty) return 'I can see: ${_joinNames(names)}';
    if (!isEmpty) return 'Not sure what this is';
    return 'Nothing recognised';
  }

  static String _joinNames(List<String> names) {
    if (names.length == 1) return names.single;
    final allButLast = names.sublist(0, names.length - 1).join(', ');
    return '$allButLast and ${names.last}';
  }
}
