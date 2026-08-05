import 'package:flutter/material.dart';

import '../../../core/widgets/shared_empty_state.dart';
import '../models/notification_item.dart';
import '../services/notification_service.dart';
import '../widgets/notification_tile.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  final _searchController = TextEditingController();
  String _category = 'All';
  bool _unreadOnly = false;
  bool _loading = true;
  List<NotificationItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });
    final cats = NotificationService.instance.categories();
    if (!cats.contains(_category)) {
      _category = 'All';
    }
    final res = await NotificationService.instance.fetch(
      category: _category,
      unreadOnly: _unreadOnly,
      query: _searchController.text,
    );
    if (!mounted) return;
    setState(() {
      _items = res;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = NotificationService.instance.categories();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: () async {
              await NotificationService.instance.markAllRead();
              await _load();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search notifications',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _load,
                      ),
                    ),
                    onSubmitted: (_) => _load(),
                  ),
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String>(
                  initialValue: _category,
                  onSelected: (v) {
                    setState(() => _category = v);
                    _load();
                  },
                  itemBuilder: (_) => categories
                      .map((c) => PopupMenuItem(value: c, child: Text(c)))
                      .toList(),
                  child: Row(
                    children: [
                      Text(_category),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Unread only'),
                const SizedBox(width: 8),
                Switch(
                  value: _unreadOnly,
                  onChanged: (v) {
                    setState(() => _unreadOnly = v);
                    _load();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isEmpty
                  ? const SharedEmptyState(
                      title: 'No notifications',
                      subtitle:
                          'You have no notifications matching the filters',
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        itemCount: _items.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (ctx, i) {
                          final it = _items[i];
                          return NotificationTile(
                            item: it,
                            onTap: () async {
                              if (!it.read) {
                                await NotificationService.instance.markRead(
                                  it.id,
                                );
                              }
                              await _load();
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
