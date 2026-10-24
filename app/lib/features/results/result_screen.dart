import 'package:flutter/material.dart';
import '../../app/ftue_truth.dart';
import '../storage/save_service.dart';

/// Number of waves the player fully cleared.
///
/// `waveReached` is the wave number shown in the HUD when the run ended.
/// A loss happens during that wave, so it does not count as cleared.
/// A win ends right after the last wave is cleared, so it does.
int wavesCleared({required bool didWin, required int waveReached}) {
  if (didWin) return waveReached;
  return waveReached > 0 ? waveReached - 1 : 0;
}

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
    // No ftue step describes the victory screen, so a win reports unknown.
    FtueTruth.report(widget.didWin ? FtueStep.unknown : FtueStep.gameOver);
    _saveAndLoadBestWave();
  }

  /// Saves this run first so a new record shows up as the best right away.
  Future<void> _saveAndLoadBestWave() async {
    await SaveService.saveBestWave(widget.levelId, widget.waveReached);
    final best = await SaveService.getBestWave(widget.levelId);
    if (mounted) setState(() => _bestWave = best);
  }

  @override
  Widget build(BuildContext context) {
    final headline = widget.didWin ? 'VICTORY' : 'GAME OVER';
    final headlineColor = widget.didWin ? Colors.greenAccent : Colors.redAccent;
    final cleared = wavesCleared(
      didWin: widget.didWin,
      waveReached: widget.waveReached,
    );
    final waveLine = widget.isEndlessMode
        ? 'Waves Survived: $cleared'
        : 'Waves Cleared: $cleared';

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
                'Best Wave: $_bestWave',
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
