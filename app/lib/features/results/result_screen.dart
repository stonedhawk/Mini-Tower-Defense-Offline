import 'package:flutter/material.dart';
import '../storage/save_service.dart';

class ResultScreen extends StatefulWidget {
  final int levelId;
  final bool didWin;
  final int waveReached;
  final bool isEndlessMode;

  const ResultScreen({
    super.key,
    required this.levelId,
    required this.didWin,
    required this.waveReached,
    this.isEndlessMode = false,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int _bestWave = 0;

  @override
  void initState() {
    super.initState();
    SaveService.saveBestWave(widget.levelId, widget.waveReached);
    _loadBestWave();
  }

  Future<void> _loadBestWave() async {
    final best = await SaveService.getBestWave(widget.levelId);
    if (mounted) setState(() => _bestWave = best);
  }

  @override
  Widget build(BuildContext context) {
    final headline = widget.didWin ? 'VICTORY' : 'GAME OVER';
    final headlineColor = widget.didWin ? Colors.greenAccent : Colors.redAccent;
    final waveLine = widget.isEndlessMode
        ? 'Waves Survived: ${widget.waveReached}'
        : 'Waves Cleared: ${widget.waveReached}';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              headline,
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: headlineColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              waveLine,
              style: const TextStyle(fontSize: 32, color: Colors.white),
            ),
            if (widget.isEndlessMode) ...[
              const SizedBox(height: 12),
              Text(
                'Best Score: $_bestWave waves',
                style: const TextStyle(fontSize: 22, color: Colors.amber),
              ),
            ],
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
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
