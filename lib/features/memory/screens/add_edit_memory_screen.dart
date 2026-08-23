import 'package:flutter/material.dart';

import '../../ai_assistant/models/memory_model.dart';
import '../services/memory_service.dart';

class AddEditMemoryScreen extends StatefulWidget {
  const AddEditMemoryScreen({this.memory, super.key});

  final MemoryModel? memory;

  @override
  State<AddEditMemoryScreen> createState() => _AddEditMemoryScreenState();
}

class _AddEditMemoryScreenState extends State<AddEditMemoryScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _detailsController;
  late final TextEditingController _peopleController;

  late String _selectedCategory;
  late DateTime _selectedDate;

  bool _isSaving = false;

  static const List<String> _categories = [
    'Personal',
    'Family',
    'Medical',
    'Event',
  ];

  @override
  void initState() {
    super.initState();
    final m = widget.memory;
    _titleController = TextEditingController(text: m?.title ?? '');
    _detailsController = TextEditingController(text: m?.details ?? '');
    _peopleController = TextEditingController(text: m?.people.join(', ') ?? '');
    _selectedCategory = (m != null && _categories.contains(m.category))
        ? m.category
        : 'Personal';
    _selectedDate = m?.time ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    _peopleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final isEditing = widget.memory != null;
      final memoryId = isEditing
          ? widget.memory!.id
          : DateTime.now().microsecondsSinceEpoch.toString();

      final parsedPeople = _peopleController.text
          .split(',')
          .map((p) => p.trim())
          .where((p) => p.isNotEmpty)
          .toList();

      final model = MemoryModel(
        id: memoryId,
        title: _titleController.text.trim(),
        details: _detailsController.text.trim(),
        category: _selectedCategory,
        time: _selectedDate,
        people: parsedPeople,
        createdAt: widget.memory?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEditing) {
        await MemoryService.instance.updateMemory(model);
      } else {
        await MemoryService.instance.addMemory(model);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Memory updated successfully'
                : 'Memory added successfully',
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save memory: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.memory != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Memory' : 'Add Memory')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    hintText: 'e.g. Family Dinner',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title for your memory';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category *',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: _categories
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedCategory = val);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _detailsController,
                  decoration: const InputDecoration(
                    labelText: 'Details / Description *',
                    hintText: 'Describe this memory in detail...',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter details for your memory';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date *',
                      prefixIcon: Icon(Icons.calendar_today_rounded),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _peopleController,
                  decoration: const InputDecoration(
                    labelText: 'People Involved',
                    hintText: 'e.g. Mom, Dad, Rahul (separated by commas)',
                    prefixIcon: Icon(Icons.people_outline_rounded),
                  ),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(isEditing ? 'Save Changes' : 'Add Memory'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
