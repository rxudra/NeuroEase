import 'package:flutter/material.dart';
import '../../../core/widgets/shared_empty_state.dart';
import '../services/search_service.dart';
import '../widgets/search_result_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  List<SearchResultItem> _results = [];

  Future<void> _doSearch(String q) async {
    if (q.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _results = [];
    });
    final res = await SearchService.instance.search(q.trim());
    if (!mounted) return;
    setState(() {
      _loading = false;
      _results = res;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search medicines, reminders, tasks, contacts',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _doSearch(_controller.text),
                ),
              ),
              onSubmitted: _doSearch,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('Amlodipine'),
                  onPressed: () => _doSearch('Amlodipine'),
                ),
                ActionChip(
                  label: const Text('Doctor'),
                  onPressed: () => _doSearch('Doctor'),
                ),
                ActionChip(
                  label: const Text('Medication'),
                  onPressed: () => _doSearch('Medication'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_results.isEmpty)
              Expanded(
                child: SharedEmptyState(
                  title: 'No results',
                  subtitle: 'Try different keywords',
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (ctx, i) =>
                      SearchResultTile(item: _results[i], onTap: () {}),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
