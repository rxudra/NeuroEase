import 'package:app/features/dashboard/dashboard_screen.dart';
import 'package:app/features/face_recognition/screens/face_recognition_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Patient Home displays Face Recognition button and navigates to FaceRecognitionScreen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final faceRecButton = find.text('Face Recognition');
    expect(faceRecButton, findsOneWidget);
    expect(
      find.byKey(const Key('dashboard-quick-action-face-recognition')),
      findsOneWidget,
    );

    await tester.tap(faceRecButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(FaceRecognitionScreen), findsOneWidget);
  });
}
