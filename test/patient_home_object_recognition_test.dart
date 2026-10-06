import 'package:app/features/dashboard/dashboard_screen.dart';
import 'package:app/features/object_recognition/screens/object_recognition_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Patient Home displays Find an Object button and navigates to ObjectRecognitionScreen', (
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

    final findObjButton = find.text('Find an Object');
    expect(findObjButton, findsOneWidget);
    expect(
      find.byKey(const Key('dashboard-quick-action-find-object')),
      findsOneWidget,
    );

    await tester.tap(findObjButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(ObjectRecognitionScreen), findsOneWidget);
  });
}
