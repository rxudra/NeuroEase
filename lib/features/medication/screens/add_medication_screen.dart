import 'package:flutter/material.dart';
import '../models/medication_model.dart';
import '../services/medication_service.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({this.med, super.key});

  final MedicationModel? med;

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  String _type = 'Tablet';
  String _frequency = 'Once';
  TimeOfDay _time = TimeOfDay.now();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  String _food = 'Anytime';
  bool _reminder = true;
  final _notesController = TextEditingController();
  var _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.med != null) {
      final m = widget.med!;
      _nameController.text = m.name;
      _dosageController.text = m.dosage;
      _type = m.type.isNotEmpty ? m.type : 'Tablet';
      _frequency = m.frequency.isNotEmpty ? m.frequency : 'Once';
      _time = m.times.isNotEmpty ? m.times.first : TimeOfDay.now();
      _startDate = m.startDate;
      _endDate = m.endDate;
      _food = m.foodInstruction.isNotEmpty ? m.foodInstruction : 'Anytime';
      _reminder = m.isReminderEnabled;
      _notesController.text = m.notes;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) setState(() => _time = t);
  }

  Future<void> _pickStartDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _startDate = d);
  }

  Future<void> _pickEndDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _endDate = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final isEditing = widget.med != null;
      final med = MedicationModel(
        id: isEditing
            ? widget.med!.id
            : DateTime.now().microsecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        type: _type,
        frequency: _frequency,
        times: [_time],
        foodInstruction: _food,
        notes: _notesController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        isReminderEnabled: _reminder,
      );

      if (isEditing) {
        await MedicationService.instance.updateMedication(widget.med!.id, med);
      } else {
        await MedicationService.instance.addMedication(med);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Medication updated'
                : 'Medication added successfully',
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save medication: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.med != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Medication' : 'Add Medication'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Medicine Name'),
                validator: (v) =>
                    (v?.trim().isEmpty ?? true) ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(labelText: 'Dosage'),
                validator: (v) =>
                    (v?.trim().isEmpty ?? true) ? 'Enter dosage' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _type,
                items: ['Capsule', 'Tablet', 'Syrup', 'Injection']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _type = v ?? _type),
                decoration: const InputDecoration(labelText: 'Medicine Type'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _frequency,
                items: ['Once', 'Twice', 'Three times', 'Custom']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _frequency = v ?? _frequency),
                decoration: const InputDecoration(labelText: 'Frequency'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Text('Time: ${_time.format(context)}')),
                  TextButton(onPressed: _pickTime, child: const Text('Pick')),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Start: ${_startDate.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickStartDate,
                    child: const Text('Pick'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'End: ${_endDate.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickEndDate,
                    child: const Text('Pick'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _food,
                items: ['Before Food', 'After Food', 'Anytime']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _food = v ?? _food),
                decoration: const InputDecoration(labelText: 'Food'),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Enable reminder'),
                value: _reminder,
                onChanged: (v) => setState(() => _reminder = v),
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEditing ? 'Save Changes' : 'Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
