import 'dart:async';
import 'package:flutter/material.dart';

import '../../memory/screens/add_edit_memory_screen.dart';
import '../../memory/services/memory_service.dart';
import '../models/memory_model.dart';
import '../widgets/memory_card.dart';

class MemoryRecallScreen extends StatefulWidget {
  const MemoryRecallScreen({super.key});

  @override
  State<MemoryRecallScreen> createState() => _MemoryRecallScreenState();
}

class _MemoryRecallScreenState extends State<MemoryRecallScreen> {
  StreamSubscription<List<MemoryModel>>? _memorySub;

  @override
  void initState() {
    super.initState();
    _memorySub = MemoryService.instance.stream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _memorySub?.cancel();
    super.dispose();
  }

  Future<void> _openAddMemoryScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditMemoryScreen()),
    );
  }

  Future<void> _openEditMemoryScreen(MemoryModel memory) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditMemoryScreen(memory: memory)),
    );
  }

  Future<void> _confirmDeleteMemory(MemoryModel memory) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Memory?'),
        content: Text('Are you sure you want to delete "${memory.title}"?'),
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
        await MemoryService.instance.deleteMemory(memory.id);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('"${memory.title}" deleted')));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete memory: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final memories = MemoryService.instance.getMemories();

    if (memories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Memory Journal')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAddMemoryScreen,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Memory'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.menu_book_rounded,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No memories yet',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Save important moments, people, and events here.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _openAddMemoryScreen,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Memory'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Memory Journal')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddMemoryScreen,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Memory'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: memories
            .map(
              (m) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: MemoryCard(
                  memory: m,
                  onEdit: () => _openEditMemoryScreen(m),
                  onDelete: () => _confirmDeleteMemory(m),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
