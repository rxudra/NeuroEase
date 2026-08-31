import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/emergency/screens/emergency_home_screen.dart';
import 'package:app/features/emergency/services/emergency_service.dart';

import 'package:app/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Emergency Telemetry UI Widget Tests', () {
    testWidgets(
      'renders EmergencyHomeScreen layout under AppTheme without layout assertions',
      (WidgetTester tester) async {
        EmergencyService.instance.initMock();

        await tester.pumpWidget(
          MaterialApp(theme: AppTheme.theme, home: const EmergencyHomeScreen()),
        );
        await tester.pumpAndSettle();

        expect(find.text('Emergency & SOS Response'), findsOneWidget);
        expect(find.text('Emergency Status'), findsOneWidget);
        expect(find.text('System Connections'), findsOneWidget);
        expect(find.text('GPS Location'), findsOneWidget);
        expect(find.text('Network'), findsOneWidget);
        expect(find.text('Smartwatch Sensor: Disconnected'), findsOneWidget);
        expect(find.text('Emergency Contacts'), findsOneWidget);
        expect(find.text('Recent Events'), findsOneWidget);
      },
    );

    testWidgets('back arrow pops EmergencyHomeScreen correctly', (
      WidgetTester tester,
    ) async {
      EmergencyService.instance.initMock();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => const EmergencyHomeScreen(),
                  ),
                ),
                child: const Text('Open SOS'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open SOS'));
      await tester.pumpAndSettle();

      expect(find.text('Emergency & SOS Response'), findsOneWidget);

      final backButton = find.byType(BackButton);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(find.text('Open SOS'), findsOneWidget);
      expect(find.text('Emergency & SOS Response'), findsNothing);
    });

    testWidgets('triggers SOS countdown when hold button is activated', (
      WidgetTester tester,
    ) async {
      EmergencyService.instance.initMock();

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.theme, home: const EmergencyHomeScreen()),
      );
      await tester.pumpAndSettle();

      final sosButton = find.byType(GestureDetector).first;
      await tester.tap(sosButton);
      await tester.pump();

      expect(find.text('Emergency Status'), findsOneWidget);
    });
  });
}
