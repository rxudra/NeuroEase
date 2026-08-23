import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/navigation/app_shell.dart';
import '../caregiver/screens/caregiver_home_screen.dart';
import '../home/screens/welcome_screen.dart';
import 'auth_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const WelcomeScreen();
        }

        return FutureBuilder<String>(
          future: AuthService().getUserRole(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Colors.white,
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final role = roleSnapshot.data ?? 'patient';
            if (role == 'caregiver') {
              return const CaregiverHomeScreen();
            }

            return const AppShell();
          },
        );
      },
    );
  }
}
