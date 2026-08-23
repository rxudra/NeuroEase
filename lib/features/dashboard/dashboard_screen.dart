import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../ai_assistant/screens/memory_recall_screen.dart';
import '../auth/auth_service.dart';
import '../caregiver/screens/caregiver_home_screen.dart';
import '../emergency/screens/emergency_home_screen.dart';
import '../home/screens/welcome_screen.dart';
import '../medication/models/medication_model.dart';
import '../medication/services/medication_service.dart';
import '../notifications/screens/notification_center_screen.dart';
import 'widgets/dashboard_widgets.dart';
import 'widgets/medication_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({this.onSelectTab, super.key});

  final ValueChanged<int>? onSelectTab;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  var _isLoggingOut = false;
  StreamSubscription<List<MedicationModel>>? _medSub;

  @override
  void initState() {
    super.initState();
    _medSub = MedicationService.instance.stream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _medSub?.cancel();
    super.dispose();
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

  void _openEmergencyScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EmergencyHomeScreen()),
    );
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    return '$weekday, $month ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    String greetingName = 'User';
    try {
      final user = _authService.currentUser;
      final emailName = (user?.email != null && user!.email!.contains('@'))
          ? user.email!.split('@').first
          : null;
      final rawName = user?.displayName ?? emailName;
      if (rawName != null && rawName.trim().isNotEmpty) {
        greetingName = rawName.trim();
      }
    } catch (_) {}

    final activeMeds = MedicationService.instance.getActiveForDate(now);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 20, 20, isWide ? 48 : 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Area
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Good Morning, $greetingName',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatCurrentDate(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const NotificationCenterScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Log out',
                            onPressed: _isLoggingOut ? null : _logout,
                            icon: _isLoggingOut
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.logout_rounded,
                                    color: AppColors.textPrimary,
                                  ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => widget.onSelectTab?.call(4),
                            child: const CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primaryContainer,
                              foregroundColor: AppColors.primary,
                              child: Icon(Icons.person_rounded),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Health Summary Card
                      DashboardCard(
                        color: AppColors.primaryContainer,
                        onTap: null,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back, $greetingName 👋',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    activeMeds.isNotEmpty
                                        ? '${activeMeds.length} active medication${activeMeds.length > 1 ? "s" : ""} scheduled for today'
                                        : 'Here is your health summary for today.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.favorite_rounded,
                                        color: AppColors.error,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '72 bpm',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Heart Rate',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Quick Actions Section
                      const DashboardSectionTitle(title: 'Quick actions'),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: isWide ? 6 : 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: isWide ? 1.05 : 0.95,
                        children: [
                          DashboardQuickAction(
                            icon: Icons.medication_outlined,
                            label: 'Medication',
                            color: AppColors.primary,
                            onTap: () => widget.onSelectTab?.call(1),
                          ),
                          DashboardQuickAction(
                            icon: Icons.book_outlined,
                            label: 'Memory',
                            color: AppColors.tertiary,
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
                            color: AppColors.secondary,
                            onTap: () => widget.onSelectTab?.call(2),
                          ),
                          DashboardQuickAction(
                            icon: Icons.emergency_rounded,
                            label: 'SOS',
                            color: AppColors.error,
                            onTap: _openEmergencyScreen,
                          ),
                          DashboardQuickAction(
                            icon: Icons.calendar_today_outlined,
                            label: 'Schedule',
                            color: AppColors.primaryLight,
                            onTap: () => widget.onSelectTab?.call(3),
                          ),
                          DashboardQuickAction(
                            icon: Icons.people_outline_rounded,
                            label: 'Caregiver',
                            color: AppColors.secondary,
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

                      const SizedBox(height: 24),

                      // Today's Medications Section
                      DashboardSectionTitle(
                        title: "Today's Medications",
                        actionLabel: 'View all',
                        onAction: () => widget.onSelectTab?.call(1),
                      ),
                      const SizedBox(height: 12),
                      if (activeMeds.isEmpty)
                        DashboardCard(
                          onTap: () => widget.onSelectTab?.call(1),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primaryContainer,
                                child: const Icon(
                                  Icons.medication_outlined,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'No medications scheduled for today',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Tap to manage your daily medications',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textMuted,
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: activeMeds.map((m) {
                            final t = m.times.isNotEmpty
                                ? m.times.first
                                : const TimeOfDay(hour: 10, minute: 0);
                            final hour = t.hourOfPeriod == 0
                                ? 12
                                : t.hourOfPeriod;
                            final minute = t.minute.toString().padLeft(2, '0');
                            final period = t.period == DayPeriod.am
                                ? 'AM'
                                : 'PM';
                            final timeText = m.times.isNotEmpty
                                ? '$hour:$minute $period'
                                : 'No time set';
                            final timeStr = m.dosage.isNotEmpty
                                ? '${m.dosage} • $timeText'
                                : timeText;
                            final taken = MedicationService.instance.isTaken(
                              m,
                              t,
                              now,
                            );

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: MedicationCard(
                                name: m.name,
                                time: timeStr,
                                taken: taken,
                                onToggle: () {
                                  setState(() {
                                    MedicationService.instance.toggleTaken(
                                      m,
                                      t,
                                      now,
                                    );
                                  });
                                },
                              ),
                            );
                          }).toList(),
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
    );
  }
}
