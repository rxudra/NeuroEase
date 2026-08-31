import 'dart:async';
import 'package:flutter/material.dart';

import '../models/emergency_contact_model.dart';
import '../models/emergency_event_model.dart';
import '../services/emergency_service.dart';
import '../widgets/contact_card.dart';
import '../widgets/countdown_card.dart';
import '../widgets/emergency_timeline.dart';
import '../widgets/safety_card.dart';
import '../widgets/sos_button.dart';
import '../widgets/status_indicator.dart';
import 'add_edit_contact_screen.dart';
import 'safety_tips_screen.dart';

class EmergencyHomeScreen extends StatefulWidget {
  const EmergencyHomeScreen({super.key});

  @override
  State<EmergencyHomeScreen> createState() => _EmergencyHomeScreenState();
}

class _EmergencyHomeScreenState extends State<EmergencyHomeScreen> {
  int _countdown = 0;
  Timer? _countdownTimer;
  StreamSubscription<List<EmergencyContactModel>>? _contactSub;

  @override
  void initState() {
    super.initState();
    EmergencyService.instance.initMock();
    _contactSub = EmergencyService.instance.stream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _contactSub?.cancel();
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
            details: 'In-app SOS emergency event recorded',
            time: DateTime.now(),
          ),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Emergency Alert Triggered — Emergency contact & caregiver notified',
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

  Future<void> _openAddContactScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditContactScreen()),
    );
  }

  Future<void> _openEditContactScreen(EmergencyContactModel contact) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditContactScreen(contact: contact)),
    );
  }

  Future<void> _confirmDeleteContact(EmergencyContactModel contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Contact?'),
        content: Text(
          'Are you sure you want to remove ${contact.name} from your emergency contacts?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await EmergencyService.instance.removeContact(contact.id);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${contact.name} removed')));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete contact: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = EmergencyService.instance;
    final contacts = service.getContacts();
    final events = service.getEvents();
    final status = service.status;

    final hasActiveSos =
        _countdown > 0 ||
        events.any((e) => e.type == EmergencyEventType.sosTriggered);

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency & SOS Response')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ACTIVE SOS WARNING BANNER
            if (hasActiveSos) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade400, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red.shade800,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _countdown > 0
                                ? 'Emergency Alert Dispatching...'
                                : 'Active Emergency Recorded',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _countdown > 0
                                ? 'Tap cancel below if activated by mistake.'
                                : 'Caregiver and emergency response log active.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // EMERGENCY HEADER STATUS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Status',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasActiveSos ? Colors.red : Colors.green,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hasActiveSos
                              ? 'Alert Triggered'
                              : 'Ready / Standing By',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: hasActiveSos
                                ? Colors.red
                                : Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SafetyTipsScreen()),
                  ),
                  icon: const Icon(Icons.shield_outlined, size: 16),
                  label: const Text('Safety Tips'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // SOS BUTTON & COUNTDOWN
            Center(child: SOSButton(onActivated: _onActivated)),
            const SizedBox(height: 12),
            if (_countdown > 0)
              CountdownCard(secondsLeft: _countdown, onCancel: _cancelAlert),
            const SizedBox(height: 16),

            // LIVE SYSTEM CONNECTIVITY CHIPS
            Text(
              'System Connections',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusIndicator(label: 'GPS Location', ok: status.gpsOk),
                StatusIndicator(label: 'Network', ok: status.internetOk),
              ],
            ),
            const SizedBox(height: 16),

            // SENSOR TELEMETRY CARD (HONEST DEVICE INTEGRATION)
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.watch_off_outlined,
                        color: Theme.of(context).colorScheme.outline,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Smartwatch Sensor: Disconnected',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'No live health sensor paired. Connect a BLE smartwatch to stream Heart Rate, SpO₂, and Fall Detection.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // EMERGENCY CONTACTS SECTION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Emergency Contacts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _openAddContactScreen,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Contact'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (contacts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'No emergency contacts added yet.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ),
              )
            else
              Column(
                children: contacts
                    .map(
                      (c) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: ContactCard(
                          contact: c,
                          onEdit: () => _openEditContactScreen(c),
                          onDelete: () => _confirmDeleteContact(c),
                        ),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 16),

            // RECENT EMERGENCY EVENTS TIMELINE
            Text(
              'Recent Events',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            EmergencyTimeline(events: events),
            const SizedBox(height: 16),

            // SAFETY TIPS CARD
            Text(
              'Safety Recommendations',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const SafetyCard(
              title: 'Night & Fall Safety',
              body:
                  'Keep hallways lit and ensure your emergency contacts are up to date.',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
