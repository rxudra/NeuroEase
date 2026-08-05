import 'package:flutter/material.dart';
import '../../schedule/models/schedule_task.dart';
import '../services/schedule_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({this.existing, super.key});

  final ScheduleTask? existing;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  String _description = '';
  String _category = 'Personal';
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  RepeatType _repeat = RepeatType.none;
  Priority _priority = Priority.medium;
  bool _notify = true;
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
      _color = e.colorValue;
    } else {
      _title = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing != null ? 'Edit Task' : 'Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                onSaved: (v) => _title = v ?? '',
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter a title' : null,
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
                          'Exercise',
                          'Meals',
                          'Sleep',
                          'Hydration',
                          'Memory Exercise',
                          'Personal',
                        ]
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                onChanged: (v) => setState(() => _category = v ?? 'Personal'),
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
              DropdownButtonFormField<RepeatType>(
                initialValue: _repeat,
                items: RepeatType.values
                    .map(
                      (r) => DropdownMenuItem(
                        value: r,
                        child: Text(r.toString().split('.').last),
                      ),
                    )
                    .toList(),
                onChanged: (v) =>
                    setState(() => _repeat = v ?? RepeatType.none),
                decoration: const InputDecoration(labelText: 'Repeat'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Priority>(
                initialValue: _priority,
                items: Priority.values
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.toString().split('.').last),
                      ),
                    )
                    .toList(),
                onChanged: (v) =>
                    setState(() => _priority = v ?? Priority.medium),
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
    final task = ScheduleTask(
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
      colorValue: _color,
      notificationEnabled: _notify,
    );
    if (widget.existing != null) {
      ScheduleService.instance.updateTask(task);
    } else {
      ScheduleService.instance.addTask(task);
    }
    Navigator.of(context).pop(task);
  }
}
