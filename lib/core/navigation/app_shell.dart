import 'package:flutter/material.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/medication/screens/medication_screen.dart';
import '../../features/ai_assistant/screens/ai_home_screen.dart';
import '../../features/schedule/screens/schedule_home_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/auth/auth_service.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final List<Widget> _pages = const [
    DashboardScreen(),
    MedicationScreen(),
    AIHomeScreen(),
    ScheduleHomeScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // If user is not authenticated, show Dashboard which will redirect to Welcome
    if (AuthService().currentUser == null) {
      _index = 0;
    }
  }

  void _onTap(int i) {
    setState(() {
      _index = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Medications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'AI'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
