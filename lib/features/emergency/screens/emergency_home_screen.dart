import 'dart:async';
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
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    EmergencyService.instance.initMock();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _onActivated() {
    _countdownTimer?.cancel();
    setState(() {
      _countdown = 10;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_countdown > 1) {
        setState(() {
          _countdown -= 1;
        });
      } else {
        timer.cancel();
        _countdownTimer = null;
        setState(() {
          _countdown = 0;
        });

        EmergencyService.instance.addEvent(
          EmergencyEventModel(
            id: 'e${DateTime.now().millisecondsSinceEpoch}',
            type: EmergencyEventType.sosTriggered,
            title: 'Emergency Alert Triggered',
            details: 'In-app emergency event recorded',
            time: DateTime.now(),
          ),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Emergency Alert Triggered — In-app event recorded',
              ),
            ),
          );
        }
      }
    });
  }

  void _cancelAlert() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    if (mounted) {
      setState(() {
        _countdown = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emergency alert cancelled.')),
      );
    }
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
            if (_countdown > 0)
              CountdownCard(secondsLeft: _countdown, onCancel: _cancelAlert),
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
