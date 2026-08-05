import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import '../services/reminder_service.dart';

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({this.existing, super.key});

  final ReminderModel? existing;

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  String _description = '';
  String _category = 'Custom';
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  RepeatOption _repeat = RepeatOption.once;
  ReminderPriority _priority = ReminderPriority.medium;
  bool _notify = true;
  String _sound = 'default';
  bool _vibration = true;
  String _notes = '';
  int _color = Colors.blue.toARGB32();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _title = e.title;
      _description = e.description;
      _category = e.category;
      _date = e.date;
      _time = e.time;
      _repeat = e.repeat;
      _priority = e.priority;
      _notify = e.notificationEnabled;
      _sound = e.sound;
      _vibration = e.vibration;
      _notes = e.notes;
      _color = e.colorValue;
    } else {
      _title = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing != null ? 'Edit Reminder' : 'Add Reminder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Reminder Name'),
                onSaved: (v) => _title = v ?? '',
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (v) => _description = v ?? '',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                items:
                    [
                          'Medication',
                          'Doctor Visit',
                          'Meals',
                          'Hydration',
                          'Exercise',
                          'Sleep',
                          'Memory Exercise',
                          'Custom',
                        ]
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                onChanged: (v) => setState(() => _category = v ?? 'Custom'),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Date'),
                        child: Text(
                          _date.toLocal().toIso8601String().split('T').first,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Time'),
                        child: Text(_time.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<RepeatOption>(
                initialValue: _repeat,
                items: RepeatOption.values
                    .map(
                      (r) => DropdownMenuItem(
                        value: r,
                        child: Text(r.toString().split('.').last),
                      ),
                    )
                    .toList(),
                onChanged: (v) =>
                    setState(() => _repeat = v ?? RepeatOption.once),
                decoration: const InputDecoration(labelText: 'Repeat'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ReminderPriority>(
                initialValue: _priority,
                items: ReminderPriority.values
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.toString().split('.').last),
                      ),
                    )
                    .toList(),
                onChanged: (v) =>
                    setState(() => _priority = v ?? ReminderPriority.medium),
                decoration: const InputDecoration(labelText: 'Priority'),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Enable notification'),
                value: _notify,
                onChanged: (v) => setState(() => _notify = v),
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) setState(() => _time = t);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final rem = ReminderModel(
      id:
          widget.existing?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: _title,
      description: _description,
      category: _category,
      date: DateTime(_date.year, _date.month, _date.day),
      time: _time,
      repeat: _repeat,
      priority: _priority,
      enabled: true,
      completed: false,
      notificationEnabled: _notify,
      sound: _sound,
      vibration: _vibration,
      notes: _notes,
      colorValue: _color,
    );
    if (widget.existing != null) {
      ReminderService.instance.update(rem);
    } else {
      ReminderService.instance.add(rem);
    }
    Navigator.of(context).pop(rem);
  }
}
