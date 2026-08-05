import 'package:flutter/material.dart';
import '../models/insight_model.dart';

class InsightCard extends StatelessWidget {
  const InsightCard({super.key, required this.insight});

  final InsightModel insight;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(insight.title),
        trailing: Text(insight.value),
      ),
    );
  }
}
