import 'package:flutter/material.dart';

class AIAvatar extends StatelessWidget {
  const AIAvatar({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.blue.shade200,
      child: Icon(Icons.smart_toy, size: size * 0.6, color: Colors.white),
    );
  }
}
