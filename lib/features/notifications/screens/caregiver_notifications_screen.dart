import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/widgets/shared_empty_state.dart';
import '../models/notification_item.dart';
import '../services/notification_service.dart';
import '../widgets/notification_tile.dart';

class CaregiverNotificationsScreen extends StatefulWidget {
  const CaregiverNotificationsScreen({super.key});

  @override
  State<CaregiverNotificationsScreen> createState() =>
      _CaregiverNotificationsScreenState();
}

class _CaregiverNotificationsScreenState
    extends State<CaregiverNotificationsScreen> {
  final _searchController = TextEditingController();
  String _category = 'All';
  bool _unreadOnly = false;
  bool _loading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<NotificationItem> _items = [];
  StreamSubscription<List<NotificationItem>>? _streamSub;

  @override
  void initState() {
    super.initState();
    _streamSub = NotificationService.instance.stream.listen(
      (_) {
        _load();
      },
      onError: (err) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = err.toString();
            _loading = false;
          });
        }
      },
    );
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _hasError = false;
      _errorMessage = '';
    });
    try {
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = NotificationService.instance.categories();
    final unreadCount = NotificationService.instance.unreadCount;
    final isSearching =
        _searchController.text.trim().isNotEmpty ||
        _category != 'All' ||
        _unreadOnly;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          unreadCount > 0 ? 'Notifications ($unreadCount)' : 'Notifications',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            tooltip: 'Mark all as read',
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
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _load();
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Text(_category),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
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
                  : _hasError
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Failed to load notifications',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (_errorMessage.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                _errorMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _load,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _items.isEmpty
                  ? SharedEmptyState(
                      title: isSearching
                          ? 'No matching notifications'
                          : 'No notifications',
                      subtitle: isSearching
                          ? 'Try adjusting your search or filters.'
                          : 'Caregiver notifications and updates will appear here.',
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        itemCount: _items.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (ctx, i) {
                          final it = _items[i];
                          return Dismissible(
                            key: Key(it.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Theme.of(context).colorScheme.error,
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) async {
                              await NotificationService.instance.dismiss(it.id);
                              await _load();
                            },
                            child: NotificationTile(
                              item: it,
                              onTap: () async {
                                if (!it.read) {
                                  await NotificationService.instance.markRead(
                                    it.id,
                                  );
                                }
                                await _load();
                              },
                            ),
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
