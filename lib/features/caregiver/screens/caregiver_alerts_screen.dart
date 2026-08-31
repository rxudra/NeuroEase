import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/widgets/shared_empty_state.dart';
import '../models/alert_model.dart';
import '../models/patient_status_model.dart';
import '../services/caregiver_service.dart';
import '../widgets/alert_card.dart';
import 'caregiver_patient_detail_screen.dart';

class CaregiverAlertsScreen extends StatefulWidget {
  const CaregiverAlertsScreen({super.key});

  @override
  State<CaregiverAlertsScreen> createState() => _CaregiverAlertsScreenState();
}

class _CaregiverAlertsScreenState extends State<CaregiverAlertsScreen> {
  StreamSubscription<List<AlertModel>>? _alertsSub;

  @override
  void initState() {
    super.initState();
    _alertsSub = CaregiverService.instance.stream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _alertsSub?.cancel();
    super.dispose();
  }

  void _handleAlertTap(AlertModel alert) {
    CaregiverService.instance.markAlertRead(alert.id);

    final patients = CaregiverService.instance.getPatients();
    final matchingPatient = patients.firstWhere(
      (p) => p.patientId == alert.patientId,
      orElse: () => PatientStatusModel(
        patientId: alert.patientId,
        name: alert.title.replaceFirst('🚨 SOS EMERGENCY ALERT - ', ''),
      ),
    );

    if (matchingPatient.patientId.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CaregiverPatientDetailScreen(patientStatus: matchingPatient),
        ),
      );
    } else {
      _showAlertDetailDialog(alert);
    }
  }

  void _showAlertDetailDialog(AlertModel alert) {
    final isCritical = alert.severity >= 4 || alert.type == AlertType.fall;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isCritical ? Icons.warning_amber_rounded : Icons.info_outline,
              color: isCritical
                  ? Colors.red
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(alert.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert.details),
            const SizedBox(height: 12),
            if (alert.time != null)
              Text(
                'Time: ${alert.time!.toIso8601String().substring(0, 16).replaceAll("T", " ")}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            Text(
              'Severity: Level ${alert.severity}/5',
              style: TextStyle(
                color: isCritical ? Colors.red : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              CaregiverService.instance.dismissAlert(alert.id);
              Navigator.pop(ctx);
            },
            child: const Text('Dismiss Alert'),
          ),
        ],
      ),
    );
  }

  void _confirmDismissAll() {
    final alerts = CaregiverService.instance.getAlerts();
    if (alerts.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dismiss All Alerts'),
        content: Text(
          'Are you sure you want to dismiss all ${alerts.length} active alerts?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () async {
              for (final a in List.from(alerts)) {
                await CaregiverService.instance.dismissAlert(a.id);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Dismiss All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alerts = CaregiverService.instance.getAlerts();
    final unreadCount = alerts.where((a) => !a.isRead).length;
    final criticalCount = alerts
        .where((a) => a.severity >= 4 || a.type == AlertType.fall)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts Center'),
        actions: [
          if (alerts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Dismiss All',
              onPressed: _confirmDismissAll,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 0,
              color: criticalCount > 0
                  ? Colors.red.shade50
                  : Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: criticalCount > 0
                      ? Colors.red.shade200
                      : Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      criticalCount > 0
                          ? Icons.warning_amber_rounded
                          : Icons.notifications_active_outlined,
                      size: 28,
                      color: criticalCount > 0
                          ? Colors.red
                          : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            criticalCount > 0
                                ? '$criticalCount Critical Emergency Alert${criticalCount == 1 ? "" : "s"}'
                                : 'Caregiver Safety Alerts',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: criticalCount > 0
                                      ? Colors.red.shade900
                                      : null,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${alerts.length} total alert${alerts.length == 1 ? "" : "s"} • $unreadCount unread',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: criticalCount > 0
                                      ? Colors.red.shade800
                                      : Colors.grey.shade700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (alerts.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 32),
                child: SizedBox(
                  width: double.infinity,
                  child: SharedEmptyState(
                    title: 'No active alerts',
                    subtitle:
                        'Emergency and safety alerts from your linked patients will appear here.',
                  ),
                ),
              )
            else
              Column(
                children: alerts
                    .map(
                      (a) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: AlertCard(
                          alert: a,
                          onView: () => _handleAlertTap(a),
                          onDismiss: () =>
                              CaregiverService.instance.dismissAlert(a.id),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
