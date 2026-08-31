import 'dart:io';
import 'package:flutter/material.dart';

class SettingsService {
  SettingsService._internal() {
    _loadThemeFromDisk();
  }
  static final SettingsService instance = SettingsService._internal();

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);
  final ValueNotifier<double> textScale = ValueNotifier(1.0);

  // Notification preferences (UI-only)
  final ValueNotifier<bool> notificationsEnabled = ValueNotifier(true);
  final ValueNotifier<bool> soundEnabled = ValueNotifier(true);

  File _getThemeFile() {
    final dir = Directory.systemTemp;
    return File('${dir.path}/neuroease_theme_mode.txt');
  }

  void _loadThemeFromDisk() {
    try {
      final file = _getThemeFile();
      if (file.existsSync()) {
        final content = file.readAsStringSync().trim();
        if (content == 'light') {
          themeMode.value = ThemeMode.light;
        } else if (content == 'dark') {
          themeMode.value = ThemeMode.dark;
        } else if (content == 'system') {
          themeMode.value = ThemeMode.system;
        }
      }
    } catch (_) {}
  }

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    try {
      final file = _getThemeFile();
      file.writeAsStringSync(mode.name);
    } catch (_) {}
  }
}
