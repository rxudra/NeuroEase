import 'package:flutter/material.dart';
import '../../appointments/services/appointment_service.dart';
import '../../appointments/widgets/appointment_card.dart';
import '../../reminders/widgets/empty_state.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final list = AppointmentService.instance.getAll();
    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: list.isEmpty
            ? const EmptyState(
                title: 'No appointments',
                subtitle: 'Add an appointment to get started',
              )
            : Column(
                children: list
                    .map(
                      (a) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: AppointmentCard(appointment: a),
                      ),
                    )
                    .toList(),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Add Appointment'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
