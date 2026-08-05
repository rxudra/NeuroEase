import 'package:flutter/material.dart';
import '../../../core/widgets/app_cards.dart';

class MemoryPreview extends StatelessWidget {
  const MemoryPreview({required this.entries, super.key});

  final List<Map<String, String>> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: entries
          .map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: AppCard(
                child: Row(
                  children: [
                    const Icon(Icons.photo, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e['title'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            e['notes'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
