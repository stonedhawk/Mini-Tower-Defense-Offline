import 'package:flutter/material.dart';
import '../storage/save_service.dart';

class ResultScreen extends StatefulWidget {
  final int levelId;
  final bool didWin;
  final int waveReached;

  const ResultScreen({
    super.key,
    required this.levelId,
    required this.didWin,
    required this.waveReached,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {

  @override
  void initState() {
    super.initState();
    SaveService.saveBestWave(widget.levelId, widget.waveReached);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.didWin ? 'VICTORY' : 'GAME OVER',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: widget.didWin ? Colors.greenAccent : Colors.redAccent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Waves Cleared: ${widget.waveReached}',
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
