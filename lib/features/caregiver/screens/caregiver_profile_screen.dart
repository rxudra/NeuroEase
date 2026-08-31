import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../auth/auth_gate.dart';
import '../../auth/auth_service.dart';
import '../../emergency/screens/emergency_home_screen.dart';
import '../../settings/services/settings_service.dart';
import '../models/caregiver_model.dart';
import '../services/caregiver_service.dart';

class CaregiverProfileScreen extends StatefulWidget {
  const CaregiverProfileScreen({super.key});

  @override
  State<CaregiverProfileScreen> createState() => _CaregiverProfileScreenState();
}

class _CaregiverProfileScreenState extends State<CaregiverProfileScreen> {
  StreamSubscription? _serviceSub;
  StreamSubscription? _patientsSub;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    _serviceSub = CaregiverService.instance.stream.listen((_) {
      if (mounted) setState(() {});
    });
    _patientsSub = CaregiverService.instance.patientsStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _serviceSub?.cancel();
    _patientsSub?.cancel();
    super.dispose();
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
        content: const Text(
          'Are you sure you want to sign out of your Caregiver Workspace?',
        ),
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

  void _showEditProfileDialog(CaregiverModel caregiver) {
    final nameController = TextEditingController(text: caregiver.name);
    final phoneController = TextEditingController(text: caregiver.phone);
    String roleValue =
        (caregiver.role == 'Primary Caregiver' ||
            caregiver.role == 'Secondary Caregiver')
        ? caregiver.role
        : 'Primary Caregiver';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Caregiver Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: roleValue,
                  decoration: const InputDecoration(
                    labelText: 'Caregiver Role',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.shield_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Primary Caregiver',
                      child: Text('Primary Caregiver'),
                    ),
                    DropdownMenuItem(
                      value: 'Secondary Caregiver',
                      child: Text('Secondary Caregiver'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => roleValue = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                final newPhone = phoneController.text.trim();
                if (newName.isNotEmpty) {
                  final updated = CaregiverModel(
                    id: caregiver.id,
                    name: newName,
                    phone: newPhone,
                    role: roleValue,
                    avatarUrl: caregiver.avatarUrl,
                  );
                  await CaregiverService.instance.updateCaregiverProfile(
                    updated,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = CaregiverService.instance;
    final caregiver = service.caregiver;
    final user = _currentUser;

    final displayName = caregiver.name.isNotEmpty
        ? caregiver.name
        : user?.displayName ?? user?.email?.split('@').first ?? 'Caregiver';
    final email = user?.email ?? 'caregiver@neuroease.app';
    final phone = caregiver.phone.isNotEmpty ? caregiver.phone : 'Not recorded';
    final role = caregiver.role.isNotEmpty
        ? caregiver.role
        : 'Primary Caregiver';

    final patientsCount = service.getPatients().length;
    final alertsCount = service.getAlerts().length;
    final familyCount = service.getFamily().length;

    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'C';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: () => _showEditProfileDialog(caregiver),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PROFILE HEADER CARD
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      backgroundImage: caregiver.avatarUrl.isNotEmpty
                          ? NetworkImage(caregiver.avatarUrl)
                          : null,
                      child: caregiver.avatarUrl.isEmpty
                          ? Text(
                              initial,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              role,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            email,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // WORKSPACE STATISTICS ROW
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    label: 'Patients',
                    value: '$patientsCount',
                    icon: Icons.people_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    label: 'Alerts',
                    value: '$alertsCount',
                    icon: Icons.warning_amber_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    label: 'Family',
                    value: '$familyCount',
                    icon: Icons.family_restroom,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ACCOUNT DETAILS CARD
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Account Details',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildDetailRow(
                      context,
                      label: 'Full Name',
                      value: displayName,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      label: 'Email Address',
                      value: email,
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      label: 'Phone Number',
                      value: phone,
                      icon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      label: 'Assigned Role',
                      value: role,
                      icon: Icons.shield_outlined,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // WORKSPACE SETTINGS & QUICK ACTIONS
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.edit_note,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Edit Profile Information'),
                    subtitle: const Text('Update name, phone number, or role'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showEditProfileDialog(caregiver),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.emergency_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Emergency & Safety Protocol'),
                    subtitle: const Text(
                      'View patient safety & emergency settings',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmergencyHomeScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: SettingsService.instance.themeMode,
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
                          SettingsService.instance.setThemeMode(chosen);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

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
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
