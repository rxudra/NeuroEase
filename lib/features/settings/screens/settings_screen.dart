import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../auth/auth_gate.dart';
import '../../auth/auth_service.dart';
import '../../backend/data/firestore_user_repository.dart';
import '../../emergency/screens/emergency_home_screen.dart';
import '../../emergency/services/emergency_service.dart';
import '../../notifications/screens/notification_center_screen.dart';
import '../../profile/models/patient_model.dart';
import '../../profile/screens/profile_screen.dart';
import '../../profile/services/profile_service.dart';
import '../services/settings_service.dart';
import '../widgets/setting_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settings = SettingsService.instance;
  bool _loading = true;
  PatientModel? _patient;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    _loadPatientProfile();
  }

  void _loadPatientProfile() {
    try {
      final user = _currentUser;
      if (user != null) {
        FirestoreUserRepository()
            .getById(user.uid)
            .then((fetched) {
              if (mounted) {
                setState(() {
                  _patient = fetched ?? ProfileService.instance.getPatient();
                  _loading = false;
                });
              }
            })
            .catchError((_) {
              ProfileService.instance.initMock();
              if (mounted) {
                setState(() {
                  _patient = ProfileService.instance.getPatient();
                  _loading = false;
                });
              }
            });
      } else {
        ProfileService.instance.initMock();
        _patient = ProfileService.instance.getPatient();
      }
    } catch (_) {
      try {
        ProfileService.instance.initMock();
        _patient = ProfileService.instance.getPatient();
      } catch (_) {}
    } finally {
      _loading = false;
    }
  }

  User? get _currentUser {
    try {
      return AuthService().currentUser;
    } catch (_) {
      return null;
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of NeuroEase?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isSigningOut = true);
      try {
        await AuthService().signOut();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthGate()),
          (route) => false,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign out: ${e.toString()}')),
        );
      } finally {
        if (mounted) setState(() => _isSigningOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    final patient = _patient ?? ProfileService.instance.getPatient();

    final name = (patient.fullName.isNotEmpty)
        ? patient.fullName
        : (user?.displayName ?? user?.email?.split('@').first ?? 'Patient');
    final email = user?.email ?? patient.email;
    final phone = patient.phone.isNotEmpty ? patient.phone : 'Not recorded';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';
    final emergencyContactsCount = EmergencyService.instance
        .getContacts()
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // PROFILE & ACCOUNT HEADER
                SettingSection(
                  title: 'Account Profile',
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        backgroundImage: patient.photoUrl.isNotEmpty
                            ? NetworkImage(patient.photoUrl)
                            : null,
                        child: patient.photoUrl.isEmpty
                            ? Text(
                                initial,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (email.isNotEmpty)
                            Text(
                              email,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          if (phone != 'Not recorded')
                            Text(
                              'Phone: $phone',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      trailing: TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          ).then((_) => _loadPatientProfile());
                        },
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // IN-APP NOTIFICATIONS SECTION
                SettingSection(
                  title: 'In-App Notifications',
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: _settings.notificationsEnabled,
                      builder: (context, enabled, _) => SwitchListTile(
                        value: enabled,
                        title: const Text('Enable In-App Notifications'),
                        subtitle: const Text(
                          'Receive reminders, dosage alerts, and status updates',
                        ),
                        onChanged: (v) =>
                            _settings.notificationsEnabled.value = v,
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _settings.soundEnabled,
                      builder: (context, sound, _) => SwitchListTile(
                        value: sound,
                        title: const Text('Notification Sound & Haptics'),
                        subtitle: const Text(
                          'Play audio alert on new notification',
                        ),
                        onChanged: (v) => _settings.soundEnabled.value = v,
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.notifications_active_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: const Text('Notification Center'),
                      subtitle: const Text(
                        'View and manage past notifications',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationCenterScreen(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // EMERGENCY & SAFETY PREFERENCES
                SettingSection(
                  title: 'Emergency & Safety',
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.emergency_outlined,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      title: const Text('Emergency Contacts & SOS Setup'),
                      subtitle: Text(
                        '$emergencyContactsCount emergency contact${emergencyContactsCount == 1 ? "" : "s"} configured',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EmergencyHomeScreen(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // APPEARANCE & ACCESSIBILITY
                SettingSection(
                  title: 'Appearance & Accessibility',
                  children: [
                    ValueListenableBuilder<ThemeMode>(
                      valueListenable: _settings.themeMode,
                      builder: (context, mode, _) => ListTile(
                        leading: Icon(
                          mode == ThemeMode.dark
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: const Text('Theme Mode'),
                        subtitle: Text(
                          mode == ThemeMode.light
                              ? 'Light Mode'
                              : mode == ThemeMode.dark
                              ? 'Dark Mode'
                              : 'System Default',
                        ),
                        onTap: () async {
                          final chosen = await showDialog<ThemeMode>(
                            context: context,
                            builder: (ctx) => SimpleDialog(
                              title: const Text('Select Theme Mode'),
                              children: [
                                SimpleDialogOption(
                                  child: const Text('Light Mode'),
                                  onPressed: () =>
                                      Navigator.of(ctx).pop(ThemeMode.light),
                                ),
                                SimpleDialogOption(
                                  child: const Text('Dark Mode'),
                                  onPressed: () =>
                                      Navigator.of(ctx).pop(ThemeMode.dark),
                                ),
                                SimpleDialogOption(
                                  child: const Text('System Default'),
                                  onPressed: () =>
                                      Navigator.of(ctx).pop(ThemeMode.system),
                                ),
                              ],
                            ),
                          );
                          if (chosen != null) {
                            _settings.setThemeMode(chosen);
                          }
                        },
                      ),
                    ),
                    ValueListenableBuilder<double>(
                      valueListenable: _settings.textScale,
                      builder: (context, scale, _) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.text_fields_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: const Text('Text Scaling & Size'),
                            subtitle: Text(
                              '${(scale * 100).round()}% scale factor',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Slider(
                              value: scale,
                              min: 0.8,
                              max: 1.4,
                              divisions: 6,
                              label: '${(scale * 100).round()}%',
                              onChanged: (v) => _settings.textScale.value = v,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ABOUT & PRIVACY
                SettingSection(
                  title: 'About & Privacy Policy',
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: const Text('About NeuroEase'),
                      subtitle: const Text('Version 1.0.0'),
                      onTap: () => showAboutDialog(
                        context: context,
                        applicationName: 'NeuroEase',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2026 NeuroEase Health Systems',
                        children: [
                          const SizedBox(height: 12),
                          const Text(
                            'NeuroEase provides real-time health monitoring, emergency response, medication schedule tracking, and caregiver alerts for cognitive wellness.',
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.privacy_tip_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: const Text('Privacy & Security Policy'),
                      subtitle: const Text(
                        'Learn how your medical data is protected',
                      ),
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Data Privacy & Security'),
                          content: const SingleChildScrollView(
                            child: Text(
                              'NeuroEase secures all patient profile, medication schedule, and emergency alert records using Firebase Cloud Firestore scoped strictly by user authentication rules.\n\nOnly linked caregivers and authorized patient accounts may read health telemetry and emergency status data.',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // SIGN OUT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red.shade800,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.red.shade200),
                      ),
                    ),
                    onPressed: _isSigningOut ? null : _signOut,
                    icon: _isSigningOut
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.red,
                            ),
                          )
                        : const Icon(Icons.logout_rounded),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}
