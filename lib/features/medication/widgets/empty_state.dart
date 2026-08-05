import 'package:flutter/material.dart';
import '../../../core/widgets/app_cards.dart';
import '../../../core/widgets/shared_empty_state.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({required this.title, required this.message, super.key});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: SharedEmptyState(title: title, subtitle: message),
    );
  }
}
