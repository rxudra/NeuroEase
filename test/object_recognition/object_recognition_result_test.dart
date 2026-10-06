import 'dart:ui';

import 'package:app/features/object_recognition/models/object_recognition_result.dart';
import 'package:flutter_test/flutter_test.dart';

RecognizedLabel _label(String name, double confidence) =>
    RecognizedLabel(name: name, confidence: confidence);

ObjectRecognitionResult _result(
  List<RecognizedLabel> labels, {
  List<LocatedObject> objects = const [],
}) =>
    ObjectRecognitionResult(
      labels: labels,
      objects: objects,
      analysedAt: DateTime(2026),
    );

void main() {
  group('RecognizedLabel', () {
    test('confidence levels use 0.85 and 0.75 thresholds', () {
      expect(_label('Cup', 0.85).level, ConfidenceLevel.high);
      expect(_label('Cup', 0.84).level, ConfidenceLevel.medium);
      expect(_label('Cup', 0.75).level, ConfidenceLevel.medium);
      expect(_label('Cup', 0.74).level, ConfidenceLevel.low);
    });

    test('confidence is described in honest verbal levels', () {
      expect(_label('Cup', 0.92).confidenceText, 'High confidence');
      expect(_label('Cup', 0.78).confidenceText, 'Possible match');
      expect(_label('Cup', 0.51).confidenceText, 'Not clearly identified');
    });
  });

  group('ObjectRecognitionResult', () {
    test('empty result states object not clearly identified', () {
      final result = ObjectRecognitionResult.empty();
      expect(result.isEmpty, isTrue);
      expect(result.hasConfidentResult, isFalse);
      expect(result.summary, 'Object not clearly identified');
    });

    test('labels are sorted most confident first and mapped', () {
      final result = _result([
        _label('Chair', 0.78),
        _label('Mobile phone', 0.95),
        _label('Laptop', 0.82),
      ]);
      expect(result.labels.map((l) => l.name), ['Phone', 'Laptop', 'Chair']);
    });

    test('broad scene labels and weak confidence are filtered out', () {
      final result = _result([
        _label('Room', 0.90),
        _label('Flooring', 0.85),
        _label('Chair', 0.70),
        _label('Dog', 0.70),
      ]);
      expect(result.hasConfidentResult, isFalse);
      expect(result.confidentLabels, isEmpty);
      expect(result.summary, 'Object not clearly identified');
    });

    test('summary joins up to three confident names', () {
      expect(_result([_label('Mobile phone', 0.9)]).summary, 'I can see: Phone');
      expect(
        _result([_label('Cup', 0.9), _label('Mug', 0.78)]).summary,
        'I can see: Cup',
      );
      expect(
        _result([
          _label('Mobile phone', 0.9),
          _label('Laptop computer', 0.85),
          _label('Book', 0.78),
          _label('Pen', 0.76),
        ]).summary,
        'I can see: Phone, Laptop and Book',
      );
    });

    test('low-confidence labels are never stated as fact', () {
      final result = _result([_label('Bottle', 0.55), _label('Jar', 0.52)]);
      expect(result.hasConfidentResult, isFalse);
      expect(result.confidentLabels, isEmpty);
      expect(result.summary, 'Object not clearly identified');
    });

    test('objects without labels are handled safely', () {
      final result = _result(
        const [],
        objects: const [
          LocatedObject(boundingBox: Rect.fromLTWH(0, 0, 10, 10)),
        ],
      );
      expect(result.isEmpty, isFalse);
      expect(result.objectCount, 1);
      expect(result.summary, 'Object not clearly identified');
    });

    test('labels list cannot be modified', () {
      final result = _result([_label('Cup', 0.9)]);
      expect(() => result.labels.add(_label('X', 1)), throwsUnsupportedError);
    });
  });
}
