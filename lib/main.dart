import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/services/settings_service.dart';
import 'features/splash/screens/splash_screen.dart';

bool _printedFirstError = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    if (_printedFirstError) return;
    _printedFirstError = true;
    debugPrint('════════ FIRST ERROR START ════════');
    debugPrint('EXCEPTION: ${details.exception}');
    debugPrint('CONTEXT: ${details.context}');
    debugPrint('LIBRARY: ${details.library}');
    if (details.informationCollector != null) {
      for (final node in details.informationCollector!()) {
        debugPrint(node.toStringDeep());
      }
    }
    if (details.stack != null) {
      debugPrint('STACK TRACE:');
      debugPrint(details.stack.toString());
    }
    debugPrint('════════ FIRST ERROR END ════════');
  };
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const NeuroEaseApp());
}

class NeuroEaseApp extends StatelessWidget {
  const NeuroEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: SettingsService.instance.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'NeuroEase',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
