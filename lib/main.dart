import 'package:flutter/material.dart';

import 'features/splash/screens/splash_screen.dart';

void main() {
  runApp(const NeuroEaseApp());
}

class NeuroEaseApp extends StatelessWidget {
  const NeuroEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NeuroEase',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}