import 'dart:ui' show Rect;

/// Set of broad scene / background / non-object labels to filter out.
const Set<String> _excludedLabels = {
  'room',
  'indoor',
  'interior design',
  'flooring',
  'floor',
  'wall',
  'tile',
  'ceiling',
  'roof',
  'wood',
  'hardwood',
  'building',
  'house',
  'space',
  'sky',
  'cloud',
  'tree',
  'plant',
  'grass',
  'outdoor',
  'pattern',
  'parallel',
  'line',
  'rectangle',
  'shape',
  'material',
  'design',
  'font',
  'graphics',
  'brand',
  'logo',
  'label',
  'text',
  'sleeve',
  'color',
  'monochrome',
  'still life',
  'tableware',
  'furniture',
  'person',
  'human',
  'face',
  'hand',
  'finger',
  'arm',
  'leg',
  'selfie',
  'skin',
  'hair',
  'smile',
  'dog',
  'cat',
  'pet',
  'animal',
};

/// Maps raw ML Kit labels to clean everyday object names for dementia assistance,
/// or returns null if the raw label is a broad scene/background label.
String? mapRecognizedObject(String rawName) {
  final clean = rawName.trim().toLowerCase();

  if (_excludedLabels.contains(clean)) {
    return null;
  }

  if (clean.contains('phone') ||
      clean.contains('telephone') ||
      clean.contains('smartphone') ||
      clean.contains('handset')) {
    return 'Phone';
  }
  if (clean.contains('glasses') ||
      clean.contains('eyewear') ||
      clean.contains('spectacles') ||
      clean.contains('sunglasses') ||
      clean.contains('goggles')) {
    return 'Glasses';
  }
  if (clean == 'key' ||
      clean == 'keys' ||
      clean.contains('keychain') ||
      clean.contains('keyring')) {
    return 'Keys';
  }
  if (clean.contains('wallet') ||
      clean.contains('purse') ||
      clean.contains('coin purse')) {
    return 'Wallet';
  }
  if (clean.contains('pill bottle') ||
      clean.contains('medicine bottle') ||
      clean.contains('medication')) {
    return 'Medicine bottle';
  }
  if (clean.contains('water bottle') || clean.contains('flask')) {
    return 'Water bottle';
  }
  if (clean.contains('bottle')) {
    return 'Bottle';
  }
  if (clean.contains('book') ||
      clean.contains('notebook') ||
      clean.contains('textbook') ||
      clean == 'novel' ||
      clean == 'publication') {
    return 'Book';
  }
  if (clean.contains('backpack') ||
      clean.contains('handbag') ||
      clean.contains('tote bag') ||
      clean.contains('luggage') ||
      clean.contains('suitcase')) {
    return 'Bag';
  }
  if (clean == 'bag') {
    return 'Bag';
  }
  if (clean.contains('chair') ||
      clean.contains('armchair') ||
      clean.contains('seat')) {
    return 'Chair';
  }
  if (clean.contains('remote') || clean.contains('remote control')) {
    return 'Remote';
  }
  if (clean.contains('cup') ||
      clean.contains('mug') ||
      clean.contains('coffee cup') ||
      clean.contains('teacup')) {
    return 'Cup';
  }
  if (clean.contains('laptop') ||
      clean == 'computer' ||
      clean.contains('netbook')) {
    return 'Laptop';
  }
  if (clean.contains('pen') || clean == 'pencil' || clean == 'marker') {
    return 'Pen';
  }
  if (clean.contains('clock') || clean.contains('watch')) {
    return 'Clock';
  }

  if (clean.length > 2) {
    return rawName[0].toUpperCase() + rawName.substring(1);
  }

  return null;
}

/// How sure the recogniser is, in honest verbal levels without fake percentages.
enum ConfidenceLevel {
  /// At or above [RecognizedLabel.highThreshold] (0.85).
  high,

  /// At or above [ObjectRecognitionResult.displayThreshold] (0.75).
  medium,

  /// Below [ObjectRecognitionResult.displayThreshold]: never stated as a match.
  low,
}

/// A named thing the recogniser believes is in the photo, e.g. "Phone".
class RecognizedLabel {
  const RecognizedLabel({required this.name, required this.confidence});

  static const double highThreshold = 0.85;

  final String name;

  /// Raw 0.0–1.0 confidence score from detector.
  final double confidence;

  ConfidenceLevel get level {
    if (confidence >= highThreshold) return ConfidenceLevel.high;
    if (confidence >= ObjectRecognitionResult.displayThreshold) {
      return ConfidenceLevel.medium;
    }
    return ConfidenceLevel.low;
  }

  /// "High confidence" / "Possible match" / "Not clearly identified".
  String get confidenceText {
    switch (level) {
      case ConfidenceLevel.high:
        return 'High confidence';
      case ConfidenceLevel.medium:
        return 'Possible match';
      case ConfidenceLevel.low:
        return 'Not clearly identified';
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
class ObjectRecognitionResult {
  ObjectRecognitionResult({
    required List<RecognizedLabel> labels,
    this.objects = const [],
    required this.analysedAt,
  }) : labels = List.unmodifiable(_processLabels(labels));

  ObjectRecognitionResult.empty({DateTime? analysedAt})
    : labels = const [],
      objects = const [],
      analysedAt = analysedAt ?? DateTime.now();

  /// Labels below this threshold (0.75) are filtered out completely.
  static const double displayThreshold = 0.75;

  /// At most this many names are shown.
  static const int maxLabelsShown = 3;

  /// Confident, filtered, mapped labels, most confident first.
  final List<RecognizedLabel> labels;
  final List<LocatedObject> objects;
  final DateTime analysedAt;

  static List<RecognizedLabel> _processLabels(List<RecognizedLabel> rawLabels) {
    final Map<String, double> topConfidenceByName = {};

    for (final item in rawLabels) {
      if (item.confidence < displayThreshold) continue;
      final mappedName = mapRecognizedObject(item.name);
      if (mappedName == null) continue;

      final existing = topConfidenceByName[mappedName];
      if (existing == null || item.confidence > existing) {
        topConfidenceByName[mappedName] = item.confidence;
      }
    }

    final sorted = topConfidenceByName.entries
        .map((e) => RecognizedLabel(name: e.key, confidence: e.value))
        .toList()
      ..sort((a, b) => b.confidence.compareTo(a.confidence));

    return sorted;
  }

  /// Labels confident enough to state, most confident first (max 3).
  List<RecognizedLabel> get confidentLabels => labels
      .where((label) => label.confidence >= displayThreshold)
      .take(maxLabelsShown)
      .toList(growable: false);

  bool get hasConfidentResult => confidentLabels.isNotEmpty;

  /// Nothing at all was found above threshold.
  bool get isEmpty => labels.isEmpty && objects.isEmpty;

  int get objectCount => objects.length;

  /// One-line headline, e.g. "I can see: Phone and Cup", or "Object not clearly identified".
  String get summary {
    final names = confidentLabels.map((label) => label.name).toList();
    if (names.isNotEmpty) return 'I can see: ${_joinNames(names)}';
    return 'Object not clearly identified';
  }

  static String _joinNames(List<String> names) {
    if (names.length == 1) return names.single;
    final allButLast = names.sublist(0, names.length - 1).join(', ');
    return '$allButLast and ${names.last}';
  }
}
