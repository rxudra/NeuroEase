import 'package:flutter/material.dart';

import '../../notifications/screens/notification_center_screen.dart';
import '../services/settings_service.dart';
import '../widgets/setting_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settings = SettingsService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            SettingSection(
              title: 'Profile',
              children: [
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: const Text('John Doe'),
                  subtitle: const Text('john.doe@example.com'),
                  trailing: TextButton(
                    onPressed: () {},
                    child: const Text('Edit'),
                  ),
                ),
              ],
            ),

            SettingSection(
              title: 'Appearance',
              children: [
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: _settings.themeMode,
                  builder: (context, mode, _) => ListTile(
                    title: const Text('Theme'),
                    subtitle: Text(
                      mode == ThemeMode.light
                          ? 'Light'
                          : mode == ThemeMode.dark
                          ? 'Dark'
                          : 'System',
                    ),
                    onTap: () async {
                      final chosen = await showDialog<ThemeMode>(
                        context: context,
                        builder: (ctx) => SimpleDialog(
                          title: const Text('Select theme'),
                          children: [
                            SimpleDialogOption(
                              child: const Text('Light'),
                              onPressed: () =>
                                  Navigator.of(ctx).pop(ThemeMode.light),
                            ),
                            SimpleDialogOption(
                              child: const Text('Dark'),
                              onPressed: () =>
                                  Navigator.of(ctx).pop(ThemeMode.dark),
                            ),
                            SimpleDialogOption(
                              child: const Text('System'),
                              onPressed: () =>
                                  Navigator.of(ctx).pop(ThemeMode.system),
                            ),
                          ],
                        ),
                      );
                      if (chosen != null) _settings.themeMode.value = chosen;
                    },
                  ),
                ),
              ],
            ),

            SettingSection(
              title: 'Accessibility',
              children: [
                ValueListenableBuilder<double>(
                  valueListenable: _settings.textScale,
                  builder: (context, scale, _) => Column(
                    children: [
                      ListTile(
                        title: const Text('Text size'),
                        subtitle: Text('${(scale * 100).round()}%'),
                      ),
                      Slider(
                        value: scale,
                        min: 0.8,
                        max: 1.4,
                        divisions: 6,
                        onChanged: (v) => _settings.textScale.value = v,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SettingSection(
              title: 'Notifications',
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: _settings.notificationsEnabled,
                  builder: (context, enabled, _) => SwitchListTile(
                    value: enabled,
                    title: const Text('Enable notifications'),
                    onChanged: (v) => _settings.notificationsEnabled.value = v,
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _settings.soundEnabled,
                  builder: (context, sound, _) => SwitchListTile(
                    value: sound,
                    title: const Text('Sound'),
                    onChanged: (v) => _settings.soundEnabled.value = v,
                  ),
                ),
                ListTile(
                  title: const Text('Notification center'),
                  subtitle: const Text('Manage your in-app notifications'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationCenterScreen(),
                    ),
                  ),
                ),
              ],
            ),

            SettingSection(
              title: 'Language',
              children: [
                ListTile(
                  title: const Text('Language'),
                  subtitle: const Text('English (placeholder)'),
                  onTap: () {},
                ),
              ],
            ),

            SettingSection(
              title: 'About & Privacy',
              children: [
                ListTile(
                  title: const Text('About'),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'NeuroEase',
                    applicationVersion: '1.0.0',
                    children: [const Text('Mock MVP application.')],
                  ),
                ),
                ListTile(
                  title: const Text('Privacy'),
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Privacy'),
                      content: const Text('Privacy placeholder.'),
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

            SettingSection(
              title: 'Account',
              children: [
                ListTile(
                  title: const Text('Logout'),
                  leading: const Icon(Icons.logout),
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('This will sign you out (mock).'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
