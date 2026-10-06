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
    test('confidence levels use 0.8 and 0.6 thresholds', () {
      expect(_label('Cup', 0.8).level, ConfidenceLevel.high);
      expect(_label('Cup', 0.79).level, ConfidenceLevel.medium);
      expect(_label('Cup', 0.6).level, ConfidenceLevel.medium);
      expect(_label('Cup', 0.59).level, ConfidenceLevel.low);
    });

    test('confidence is described in words and as a percentage', () {
      expect(_label('Cup', 0.92).confidenceText, 'Very likely');
      expect(_label('Cup', 0.65).confidenceText, 'Likely');
      expect(_label('Cup', 0.51).confidenceText, 'Not sure');
      expect(_label('Cup', 0.916).percentText, '92%');
    });
  });

  group('ObjectRecognitionResult', () {
    test('empty result says nothing was recognised', () {
      final result = ObjectRecognitionResult.empty();
      expect(result.isEmpty, isTrue);
      expect(result.hasConfidentResult, isFalse);
      expect(result.tentativeGuess, isNull);
      expect(result.summary, 'Nothing recognised');
    });

    test('labels are sorted most confident first', () {
      final result = _result([
        _label('Table', 0.7),
        _label('Cup', 0.95),
        _label('Laptop', 0.8),
      ]);
      expect(result.labels.map((l) => l.name), ['Cup', 'Laptop', 'Table']);
    });

    test('summary joins up to three confident names', () {
      expect(_result([_label('Cup', 0.9)]).summary, 'I can see: Cup');
      expect(
        _result([_label('Cup', 0.9), _label('Mug', 0.7)]).summary,
        'I can see: Cup and Mug',
      );
      expect(
        _result([
          _label('Cup', 0.9),
          _label('Laptop', 0.8),
          _label('Table', 0.7),
          _label('Desk', 0.65),
        ]).summary,
        'I can see: Cup, Laptop and Table',
      );
    });

    test('low-confidence labels are never stated as fact', () {
      final result = _result([_label('Bottle', 0.55), _label('Jar', 0.52)]);
      expect(result.hasConfidentResult, isFalse);
      expect(result.confidentLabels, isEmpty);
      expect(result.summary, 'Not sure what this is');
      expect(result.tentativeGuess?.name, 'Bottle');
    });

    test('no tentative guess when a confident label exists', () {
      final result = _result([_label('Cup', 0.9), _label('Jar', 0.52)]);
      expect(result.tentativeGuess, isNull);
      expect(result.confidentLabels.map((l) => l.name), ['Cup']);
    });

    test('objects without labels are "not sure", not "nothing"', () {
      final result = _result(
        const [],
        objects: const [
          LocatedObject(boundingBox: Rect.fromLTWH(0, 0, 10, 10)),
        ],
      );
      expect(result.isEmpty, isFalse);
      expect(result.objectCount, 1);
      expect(result.summary, 'Not sure what this is');
    });

    test('labels list cannot be modified', () {
      final result = _result([_label('Cup', 0.9)]);
      expect(() => result.labels.add(_label('X', 1)), throwsUnsupportedError);
    });
  });
}
