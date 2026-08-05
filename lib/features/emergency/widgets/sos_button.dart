import 'dart:async';

import 'package:flutter/material.dart';

class SOSButton extends StatefulWidget {
  const SOSButton({super.key, required this.onActivated});

  final VoidCallback onActivated;

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _holdTimer;
  int _count = 3;
  bool _holding = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _holdTimer?.cancel();
    super.dispose();
  }

  void _startHold() {
    setState(() {
      _holding = true;
      _count = 3;
    });
    _controller.repeat(reverse: true);
    _holdTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _count -= 1;
        if (_count <= 0) {
          _complete();
          t.cancel();
        }
      });
    });
  }

  void _cancelHold() {
    _holdTimer?.cancel();
    _controller.stop();
    setState(() {
      _holding = false;
      _count = 3;
    });
  }

  void _complete() async {
    _controller.stop();
    setState(() {
      _holding = false;
    });
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Confirm Emergency'),
          content: const Text('Are you sure you want to trigger SOS?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      widget.onActivated();
    }
    setState(() {
      _count = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _startHold(),
      onLongPressEnd: (_) => _cancelHold(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final scale = 1 + (_controller.value * 0.08);
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 51),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'SOS',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_holding)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_count',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.red),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _cancelHold,
                  child: const Text('Cancel'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
