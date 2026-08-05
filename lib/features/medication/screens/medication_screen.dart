import 'package:flutter/material.dart';
import '../../dashboard/widgets/dashboard_widgets.dart';
import '../services/medication_service.dart';
import '../widgets/summary_card.dart';
import '../widgets/medication_card.dart';
import '../widgets/empty_state.dart';
import 'add_medication_screen.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final _service = MedicationService.instance;

  @override
  Widget build(BuildContext context) {
    final meds = _service.getUpcomingForDate(DateTime.now());
    final completed = _service.getCompletedToday(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMedicationScreen()),
          );
          setState(() {});
        },
        label: const Text('Add Medication'),
        icon: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SummaryCard(total: meds.length, taken: completed.length, missed: 0),
            const SizedBox(height: 16),
            const DashboardSectionTitle(title: 'Upcoming medicines'),
            const SizedBox(height: 12),
            if (meds.isEmpty)
              const EmptyState(
                title: 'No meds',
                message: 'You have no upcoming medicines for today.',
              )
            else
              Column(
                children: meds
                    .map(
                      (m) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: MedicationCard(med: m),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 20),
            const DashboardSectionTitle(title: 'Completed today'),
            const SizedBox(height: 8),
            if (completed.isEmpty)
              const EmptyState(
                title: 'None yet',
                message: 'No medicines taken yet today.',
              )
            else
              Column(
                children: completed
                    .map(
                      (m) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: MedicationCard(med: m),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 20),
            const DashboardSectionTitle(title: 'Missed medicines'),
            const SizedBox(height: 8),
            // mock: none
            const EmptyState(
              title: 'All caught up',
              message: 'No missed medicines.',
            ),
          ],
        ),
      ),
    );
  }
}
