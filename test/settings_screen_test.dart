import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/settings/screens/settings_screen.dart';
import 'package:app/features/profile/services/profile_service.dart';
import 'package:app/features/emergency/services/emergency_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsScreen Widget Tests', () {
    testWidgets(
      'renders SettingsScreen with settings categories and Sign Out button',
      (WidgetTester tester) async {
        ProfileService.instance.initMock();
        EmergencyService.instance.initMock();

        await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Account Profile'), findsOneWidget);
        expect(find.text('In-App Notifications'), findsOneWidget);
        expect(find.text('Emergency & Safety'), findsOneWidget);

        final appearanceFinder = find.text('Appearance & Accessibility');
        await tester.scrollUntilVisible(appearanceFinder, 200);
        expect(appearanceFinder, findsOneWidget);

        final aboutFinder = find.text('About & Privacy Policy');
        await tester.scrollUntilVisible(aboutFinder, 200);
        expect(aboutFinder, findsOneWidget);

        final signOutFinder = find.text('Sign Out');
        await tester.scrollUntilVisible(signOutFinder, 200);
        expect(signOutFinder, findsOneWidget);
      },
    );

    testWidgets('displays Theme Mode selection dialog on tap', (
      WidgetTester tester,
    ) async {
      ProfileService.instance.initMock();
      EmergencyService.instance.initMock();

      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pumpAndSettle();

      final themeTile = find.text('Theme Mode');
      await tester.scrollUntilVisible(themeTile, 200);
      expect(themeTile, findsOneWidget);

      await tester.tap(themeTile);
      await tester.pumpAndSettle();

      expect(find.text('Select Theme Mode'), findsOneWidget);
      expect(find.text('Light Mode'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('System Default'), findsWidgets);
    });
  });
}
