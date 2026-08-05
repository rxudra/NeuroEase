import 'package:flutter/material.dart';
import '../models/emergency_event_model.dart';

class EmergencyTimeline extends StatelessWidget {
  const EmergencyTimeline({super.key, required this.events});

  final List<EmergencyEventModel> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Text('No events', style: Theme.of(context).textTheme.bodyLarge),
      );
    }
    return Column(
      children: events
          .map(
            (e) => ListTile(
              leading: _iconFor(e.type),
              title: Text(e.title),
              subtitle: Text(
                '${e.details}\n${e.time?.toLocal().toIso8601String() ?? ''}',
              ),
            ),
          )
          .toList(),
    );
  }

  Icon _iconFor(EmergencyEventType t) {
    switch (t) {
      case EmergencyEventType.fall:
        return const Icon(Icons.warning, color: Colors.orange);
      case EmergencyEventType.sosTriggered:
        return const Icon(Icons.volume_up, color: Colors.red);
      case EmergencyEventType.sosCancelled:
        return const Icon(Icons.cancel, color: Colors.grey);
      case EmergencyEventType.locationShared:
        return const Icon(Icons.location_on, color: Colors.blue);
      case EmergencyEventType.contactNotified:
        return const Icon(Icons.notifications, color: Colors.green);
    }
  }
}
