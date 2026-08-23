import 'package:flutter/material.dart';
import '../../../core/widgets/shared_empty_state.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({required this.title, this.subtitle, super.key});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: SharedEmptyState(title: title, subtitle: subtitle),
  );
}
