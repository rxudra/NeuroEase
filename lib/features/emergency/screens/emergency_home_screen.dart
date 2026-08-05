import 'package:flutter/material.dart';
import '../services/emergency_service.dart';
import '../models/emergency_event_model.dart';
import '../widgets/sos_button.dart';
import '../widgets/status_indicator.dart';
import '../widgets/countdown_card.dart';
import '../widgets/contact_card.dart';
import '../widgets/emergency_timeline.dart';
import '../widgets/safety_card.dart';
import 'safety_tips_screen.dart';

class EmergencyHomeScreen extends StatefulWidget {
  const EmergencyHomeScreen({super.key});

  @override
  State<EmergencyHomeScreen> createState() => _EmergencyHomeScreenState();
}

class _EmergencyHomeScreenState extends State<EmergencyHomeScreen> {
  int _countdown = 0;

  @override
  void initState() {
    super.initState();
    EmergencyService.instance.initMock();
  }

  void _onActivated() {
    setState(() {
      _countdown = 10;
    });
    EmergencyService.instance.addEvent(
      EmergencyEventModel(
        id: 'e${DateTime.now().millisecondsSinceEpoch}',
        type: EmergencyEventType.sosTriggered,
        title: 'SOS Activated',
        details: 'User triggered SOS',
        time: DateTime.now(),
      ),
    );
    // simulate countdown finishing
    Future.delayed(const Duration(seconds: 10), () {
      setState(() {
        _countdown = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = EmergencyService.instance;
    final contacts = service.getContacts();
    final events = service.getEvents();
    final status = service.status;

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ready',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.green),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SafetyTipsScreen()),
                  ),
                  child: const Text('Safety Tips'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(child: SOSButton(onActivated: _onActivated)),
            const SizedBox(height: 12),
            if (_countdown > 0) CountdownCard(secondsLeft: _countdown),
            const SizedBox(height: 12),
            Text('Live Status', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusIndicator(label: 'GPS', ok: status.gpsOk),
                StatusIndicator(label: 'Internet', ok: status.internetOk),
                StatusIndicator(label: 'Watch', ok: status.watchConnected),
                StatusIndicator(
                  label: 'Battery ${status.batteryPct}%',
                  ok: status.batteryPct > 20,
                ),
                StatusIndicator(
                  label: 'Heart ${status.heartRate} bpm',
                  ok: status.heartRate > 40,
                ),
                StatusIndicator(
                  label: 'SpO₂ ${status.spo2}%',
                  ok: status.spo2 > 90,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Emergency Contacts',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (contacts.isEmpty)
              Center(
                child: Text(
                  'No contacts',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
            else
              Column(
                children: contacts
                    .map(
                      (c) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: ContactCard(contact: c),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 12),
            Text(
              'Recent Events',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            EmergencyTimeline(events: events),
            const SizedBox(height: 12),
            Text('Safety Tips', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SafetyCard(
              title: 'Night Safety',
              body: 'Keep a light on in hallways.',
            ),
          ],
        ),
      ),
    );
  }
}
