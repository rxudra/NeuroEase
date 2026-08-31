import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/features/settings/services/settings_service.dart';
import 'package:app/features/profile/screens/profile_screen.dart';
import 'package:app/features/profile/services/profile_service.dart';
import 'package:app/features/caregiver/screens/caregiver_patients_screen.dart';
import 'package:app/features/caregiver/services/caregiver_service.dart';
import 'package:app/features/emergency/screens/emergency_home_screen.dart';
import 'package:app/features/emergency/services/emergency_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Theme System Unit & Widget Tests', () {
    test('AppTheme lightTheme and darkTheme construct correctly', () {
      final light = AppTheme.lightTheme;
      final dark = AppTheme.darkTheme;

      expect(light.brightness, equals(Brightness.light));
      expect(dark.brightness, equals(Brightness.dark));

      expect(dark.scaffoldBackgroundColor, equals(AppColors.darkBackground));
      expect(dark.colorScheme.surface, equals(AppColors.darkSurface));
    });

    test(
      'SettingsService setThemeMode changes theme immediately and persists',
      () {
        final service = SettingsService.instance;

        service.setThemeMode(ThemeMode.dark);
        expect(service.themeMode.value, equals(ThemeMode.dark));

        service.setThemeMode(ThemeMode.light);
        expect(service.themeMode.value, equals(ThemeMode.light));

        service.setThemeMode(ThemeMode.system);
        expect(service.themeMode.value, equals(ThemeMode.system));
      },
    );

    testWidgets(
      'Patient screens render under Dark Theme without layout issues',
      (WidgetTester tester) async {
        ProfileService.instance.initMock();
        SettingsService.instance.setThemeMode(ThemeMode.dark);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            home: const ProfileScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Patient Medical History'), findsOneWidget);
        expect(find.text('Clinical Summary'), findsOneWidget);
      },
    );

    testWidgets(
      'Caregiver screens render under Dark Theme without layout issues',
      (WidgetTester tester) async {
        CaregiverService.instance.initMock();
        SettingsService.instance.setThemeMode(ThemeMode.dark);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            home: const CaregiverPatientsScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Linked Patients'), findsOneWidget);
      },
    );

    testWidgets(
      'Emergency & SOS Response renders accessible under Dark Theme',
      (WidgetTester tester) async {
        EmergencyService.instance.initMock();
        SettingsService.instance.setThemeMode(ThemeMode.dark);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            home: const EmergencyHomeScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Emergency & SOS Response'), findsOneWidget);
        expect(find.text('Emergency Status'), findsOneWidget);
      },
    );
  });
}
