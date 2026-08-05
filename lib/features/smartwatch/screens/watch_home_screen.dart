import 'package:flutter/material.dart';
import '../services/smartwatch_service.dart';
import '../widgets/watch_card.dart';
import '../widgets/health_card.dart';
import '../widgets/battery_card.dart';
import '../widgets/connection_chip.dart';

class WatchHomeScreen extends StatefulWidget {
  const WatchHomeScreen({super.key});

  @override
  State<WatchHomeScreen> createState() => _WatchHomeScreenState();
}

class _WatchHomeScreenState extends State<WatchHomeScreen> {
  @override
  void initState() {
    super.initState();
    SmartwatchService.instance.initMock();
  }

  @override
  Widget build(BuildContext context) {
    final svc = SmartwatchService.instance;
    final devices = svc.getDevices();
    final latest = svc.getLatest();
    final connection = svc.getConnection();

    return Scaffold(
      appBar: AppBar(title: const Text('Smartwatch')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Connected Device',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ConnectionChip(status: connection.status),
              ],
            ),
            const SizedBox(height: 12),
            if (devices.isNotEmpty)
              WatchCard(device: devices.first)
            else
              Center(
                child: Text(
                  'No device paired',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: HealthCard(reading: latest, title: 'Live Health'),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 140,
                  child: BatteryCard(
                    pct: devices.isNotEmpty ? devices.first.batteryPct : 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Quick Stats', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('Steps ${latest.steps}')),
                Chip(label: Text('Calories ${latest.calories}')),
                Chip(label: Text('Distance ${latest.distanceMeters}m')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
