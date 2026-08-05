import 'package:flutter/material.dart';

class VoiceChatScreen extends StatefulWidget {
  const VoiceChatScreen({super.key});

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> {
  bool _listening = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Chat')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_listening ? Icons.mic : Icons.mic_none, size: 96),
            const SizedBox(height: 12),
            Text(
              _listening ? 'Listening...' : 'Tap to start',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => setState(() => _listening = !_listening),
              child: Text(_listening ? 'Stop' : 'Start'),
            ),
          ],
        ),
      ),
    );
  }
}
