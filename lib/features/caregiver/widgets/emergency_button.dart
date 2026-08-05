import 'package:flutter/material.dart';

class EmergencyButton extends StatelessWidget {
  const EmergencyButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.warning),
      label: const Text('SOS'),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
    );
  }
}
