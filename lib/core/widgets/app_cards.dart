import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  const AppCard({this.onTap, this.color, required this.child, super.key});

  final VoidCallback? onTap;
  final Color? color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color ?? Theme.of(context).cardColor,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(20), child: child),
      ),
    );
  }
}
