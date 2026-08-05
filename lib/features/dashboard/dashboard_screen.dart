import 'package:flutter/material.dart';

import '../ai_assistant/ai_assistant_screen.dart';
import '../auth/auth_service.dart';
import '../caregiver/caregiver_screen.dart';
import '../home/screens/welcome_screen.dart';
import '../reminders/reminders_screen.dart';
import '../settings/settings_screen.dart';
import 'widgets/dashboard_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  var _selectedIndex = 0;
  var _isLoggingOut = false;

  static const _labels = ['Home', 'Reminders', 'Assistant', 'Caregiver', 'Settings'];

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthService.messageFor(error))),
      );
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

  Widget _buildBody() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: switch (_selectedIndex) {
        0 => _DashboardHome(
            key: const ValueKey('home'),
            onSelectTab: (index) => setState(() => _selectedIndex = index),
            onSos: _showSosDialog,
          ),
        1 => const RemindersScreen(key: ValueKey('reminders')),
        2 => const AIAssistantScreen(key: ValueKey('assistant')),
        3 => const CaregiverScreen(key: ValueKey('caregiver')),
        _ => const SettingsScreen(key: ValueKey('settings')),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHome = _selectedIndex == 0;
    return Scaffold(
      appBar: isHome
          ? null
          : AppBar(
              title: Text(_labels[_selectedIndex]),
              actions: [
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
              ],
            ),
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.medication_outlined), selectedIcon: Icon(Icons.medication), label: 'Reminders'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'Assistant'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Caregiver'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome({required this.onSelectTab, required this.onSos, super.key});

  final ValueChanged<int> onSelectTab;
  final VoidCallback onSos;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final name = AuthService().currentUser?.displayName?.split(' ').first;
    final greetingName = name == null || name.isEmpty ? 'there' : name;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, isWide ? 32 : 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Good day, $greetingName', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              Text('Here is your gentle plan for today.', style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: colorScheme.primaryContainer,
                          foregroundColor: colorScheme.onPrimaryContainer,
                          child: const Icon(Icons.favorite_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const DashboardSectionTitle(title: 'Quick actions'),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: isWide ? 4 : 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: isWide ? 1.25 : 1.45,
                      children: [
                        DashboardQuickAction(icon: Icons.medication_outlined, label: 'Medicine', color: colorScheme.primary, onTap: () => onSelectTab(1)),
                        DashboardQuickAction(icon: Icons.auto_awesome_outlined, label: 'Talk to AI', color: colorScheme.tertiary, onTap: () => onSelectTab(2)),
                        DashboardQuickAction(icon: Icons.people_outline, label: 'Caregiver', color: Colors.teal, onTap: () => onSelectTab(3)),
                        DashboardQuickAction(icon: Icons.emergency_rounded, label: 'SOS', color: Colors.red, onTap: onSos),
                      ],
                    ),
                    const SizedBox(height: 28),
                    DashboardCard(
                      color: colorScheme.primaryContainer,
                      onTap: () => onSelectTab(1),
                      child: Row(
                        children: [
                          CircleAvatar(radius: 28, backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary, child: const Icon(Icons.medication_rounded, size: 28)),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Next medicine', style: theme.textTheme.labelLarge), const SizedBox(height: 4), Text('Vitamin D', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text('Today at 10:00 AM', style: theme.textTheme.bodyMedium)])),
                          Icon(Icons.arrow_forward_ios_rounded, color: colorScheme.onPrimaryContainer, size: 18),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const DashboardSectionTitle(title: "Today's schedule", actionLabel: 'View all'),
                    const SizedBox(height: 8),
                    DashboardCard(child: Column(children: const [
                      _ScheduleItem(time: '10:00', period: 'AM', title: 'Take Vitamin D', icon: Icons.medication_outlined),
                      Divider(height: 28),
                      _ScheduleItem(time: '02:00', period: 'PM', title: 'Afternoon walk', icon: Icons.directions_walk_outlined),
                      Divider(height: 28),
                      _ScheduleItem(time: '07:30', period: 'PM', title: 'Call family', icon: Icons.call_outlined),
                    ])),
                    const SizedBox(height: 28),
                    _ResponsivePair(
                      isWide: isWide,
                      first: DashboardCard(
                        color: colorScheme.tertiaryContainer,
                        onTap: () => onSelectTab(2),
                        child: _FeatureCardContent(icon: Icons.psychology_outlined, title: 'Memory training', subtitle: 'Try today\'s gentle brain exercise.', action: 'Start now', color: colorScheme.onTertiaryContainer),
                      ),
                      second: DashboardCard(
                        color: colorScheme.secondaryContainer,
                        onTap: () => onSelectTab(3),
                        child: _FeatureCardContent(icon: Icons.favorite_outline, title: 'Caregiver status', subtitle: 'Priya checked in 20 minutes ago.', action: 'View update', color: colorScheme.onSecondaryContainer),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DashboardCard(
                      color: const Color(0xFFFFE9E8),
                      onTap: onSos,
                      child: Row(children: [const Icon(Icons.emergency_rounded, color: Colors.red, size: 32), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Emergency SOS', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: Colors.red.shade900)), const SizedBox(height: 4), const Text('Get help from your trusted contacts quickly.')])), const Icon(Icons.chevron_right_rounded, color: Colors.red)]),
                    ),
                    const SizedBox(height: 28),
                    const DashboardSectionTitle(title: 'Recent activity'),
                    DashboardActivityTile(icon: Icons.check_circle_outline, title: 'Morning medicine completed', subtitle: 'Today, 8:30 AM', color: Colors.green),
                    DashboardActivityTile(icon: Icons.auto_awesome_outlined, title: 'Memory exercise completed', subtitle: 'Yesterday, 5:15 PM', color: colorScheme.tertiary),
                    DashboardActivityTile(icon: Icons.favorite_outline, title: 'Caregiver check-in', subtitle: 'Yesterday, 1:00 PM', color: Colors.teal),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ResponsivePair extends StatelessWidget {
  const _ResponsivePair({required this.isWide, required this.first, required this.second});

  final bool isWide;
  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    if (!isWide) return Column(children: [first, const SizedBox(height: 12), second]);
    return Row(children: [Expanded(child: first), const SizedBox(width: 12), Expanded(child: second)]);
  }
}

class _FeatureCardContent extends StatelessWidget {
  const _FeatureCardContent({required this.icon, required this.title, required this.subtitle, required this.action, required this.color});

  final IconData icon;
  final String title;
  final String subtitle;
  final String action;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 30),
      const SizedBox(height: 16),
      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: color)),
      const SizedBox(height: 6),
      Text(subtitle),
      const SizedBox(height: 16),
      Text(action, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
    ]);
  }
}

class _ScheduleItem extends StatelessWidget {
  const _ScheduleItem({required this.time, required this.period, required this.title, required this.icon});

  final String time;
  final String period;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(children: [SizedBox(width: 54, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(time, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), Text(period, style: Theme.of(context).textTheme.labelSmall)])), Container(width: 2, height: 40, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 14), Icon(icon, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 14), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)))]);
  }
}
