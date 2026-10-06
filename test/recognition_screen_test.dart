import 'package:app/features/recognition/recognition_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('hub lists both features and the privacy note', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RecognitionScreen()));

    expect(find.text('Camera help'), findsOneWidget);
    expect(find.byKey(const Key('recognition-tile-face')), findsOneWidget);
    expect(find.text('Face detection'), findsOneWidget);
    expect(find.byKey(const Key('recognition-tile-object')), findsOneWidget);
    expect(find.text('What is this?'), findsOneWidget);
    expect(find.textContaining('Nothing is saved or uploaded'), findsOneWidget);
  });
}
