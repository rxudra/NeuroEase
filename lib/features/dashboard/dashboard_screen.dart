import 'package:flutter/material.dart';

import '../ai_assistant/screens/memory_recall_screen.dart';
import '../auth/auth_service.dart';
import '../caregiver/screens/caregiver_home_screen.dart';
import '../home/screens/welcome_screen.dart';
import '../notifications/screens/notification_center_screen.dart';
import 'widgets/dashboard_widgets.dart';
import 'widgets/health_status_card.dart';
import 'widgets/medication_card.dart';
import 'widgets/memory_preview.dart';
import 'widgets/schedule_timeline.dart';
import 'widgets/sos_fab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({this.onSelectTab, super.key});

  final ValueChanged<int>? onSelectTab;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  var _isLoggingOut = false;

  final List<Map<String, dynamic>> _medications = [
    {'name': 'Vitamin D', 'time': '10:00 AM', 'taken': false},
    {'name': 'Amlodipine', 'time': '02:00 PM', 'taken': false},
  ];

  final List<Map<String, String>> _schedule = [
    {'time': '10:00', 'period': 'AM', 'title': 'Take Vitamin D'},
    {'time': '02:00', 'period': 'PM', 'title': 'Afternoon walk'},
    {'time': '07:30', 'period': 'PM', 'title': 'Call family'},
  ];

  final List<Map<String, String>> _memories = [
    {
      'title': 'Birthday at the park',
      'notes': 'Lovely time with family and cake.',
    },
    {'title': 'Garden walk', 'notes': 'Saw colorful flowers and birds.'},
  ];

  void _toggleTaken(int index) {
    setState(() {
      _medications[index]['taken'] = !_medications[index]['taken'];
    });
  }

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
    try {
      await _authService.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AuthService.messageFor(error))));
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  Future<void> _showSosDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.emergency_rounded, color: Colors.red, size: 36),
        title: const Text('Need urgent help?'),
        content: const Text(
          'This will notify your emergency contacts when SOS is connected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('SOS contacts will be available soon.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final name = AuthService().currentUser?.displayName?.split(' ').first;
    final greetingName = name == null || name.isEmpty ? 'Rudra' : name;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 20, 20, isWide ? 48 : 100),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App bar area
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Good Morning, $greetingName',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateTime.now().toLocal().toString().split(
                                    ' ',
                                  )[0],
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationCenterScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.notifications_none),
                          ),
                          IconButton(
                            tooltip: 'Log out',
                            onPressed: _isLoggingOut ? null : _logout,
                            icon: _isLoggingOut
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.logout),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => widget.onSelectTab?.call(4),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: colorScheme.primaryContainer,
                              foregroundColor: colorScheme.onPrimaryContainer,
                              child: const Icon(Icons.person),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Welcome / Health summary
                      DashboardCard(
                        color: colorScheme.primaryContainer,
                        onTap: () {},
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back, $greetingName',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Here is your health summary for today.',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              children: [
                                Text('Heart', style: theme.textTheme.labelSmall),
                                const SizedBox(height: 8),
                                Text(
                                  '72 bpm',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Quick Actions
                      const DashboardSectionTitle(title: 'Quick actions'),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: isWide ? 6 : 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.1,
                        children: [
                          DashboardQuickAction(
                            icon: Icons.medication_outlined,
                            label: 'Medication',
                            color: colorScheme.primary,
                            onTap: () => widget.onSelectTab?.call(1),
                          ),
                          DashboardQuickAction(
                            icon: Icons.book_outlined,
                            label: 'Memory Journal',
                            color: colorScheme.tertiary,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MemoryRecallScreen(),
                                ),
                              );
                            },
                          ),
                          DashboardQuickAction(
                            icon: Icons.smart_toy_outlined,
                            label: 'AI Assistant',
                            color: colorScheme.secondary,
                            onTap: () => widget.onSelectTab?.call(2),
                          ),
                          DashboardQuickAction(
                            icon: Icons.emergency_rounded,
                            label: 'SOS',
                            color: Colors.red,
                            onTap: _showSosDialog,
                          ),
                          DashboardQuickAction(
                            icon: Icons.schedule,
                            label: 'Schedule',
                            color: colorScheme.primaryContainer,
                            onTap: () => widget.onSelectTab?.call(3),
                          ),
                          DashboardQuickAction(
                            icon: Icons.people_outline,
                            label: 'Caregiver',
                            color: Colors.teal,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CaregiverHomeScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Today's Medications
                      DashboardSectionTitle(
                        title: "Today's Medications",
                        actionLabel: 'View all',
                        onAction: () => widget.onSelectTab?.call(1),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: _medications.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final med = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: MedicationCard(
                              name: med['name'] as String,
                              time: med['time'] as String,
                              taken: med['taken'] as bool,
                              onToggle: () => _toggleTaken(idx),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      // Upcoming Schedule
                      DashboardSectionTitle(
                        title: "Upcoming schedule",
                        actionLabel: 'View all',
                        onAction: () => widget.onSelectTab?.call(3),
                      ),
                      const SizedBox(height: 12),
                      ScheduleTimeline(items: _schedule),

                      const SizedBox(height: 20),

                      // Memory Journal Preview
                      const DashboardSectionTitle(title: 'Memory journal'),
                      const SizedBox(height: 12),
                      MemoryPreview(entries: _memories),

                      const SizedBox(height: 20),

                      // Health Status
                      const DashboardSectionTitle(title: 'Health status'),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: isWide ? 4 : 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: const [
                          HealthStatusCard(
                            icon: Icons.favorite,
                            title: 'Heart Rate',
                            value: '72 bpm',
                          ),
                          HealthStatusCard(
                            icon: Icons.directions_walk,
                            title: 'Steps',
                            value: '3,450',
                          ),
                          HealthStatusCard(
                            icon: Icons.bedtime,
                            title: 'Sleep',
                            value: '7h 12m',
                          ),
                          HealthStatusCard(
                            icon: Icons.watch,
                            title: 'Watch',
                            value: 'Connected',
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SosFab(onTap: _showSosDialog),
      ),
    );
  }
}
