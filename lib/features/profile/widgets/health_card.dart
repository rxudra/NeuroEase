import 'package:flutter/material.dart';
import '../../../core/widgets/stat_card.dart';

class HealthCard extends StatelessWidget {
  const HealthCard({required this.title, required this.value, super.key});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => StatCard(title: title, value: value);
}
