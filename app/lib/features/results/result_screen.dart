import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final bool didWin;
  final int waveReached;

  const ResultScreen({
    super.key,
    required this.didWin,
    required this.waveReached,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              didWin ? 'VICTORY' : 'GAME OVER',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: didWin ? Colors.greenAccent : Colors.redAccent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Waves Cleared: $waveReached',
              style: const TextStyle(fontSize: 32, color: Colors.white),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                // Pop back to home screen
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: const Text('Back to Menu', style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
    );
  }
}
