import 'package:flutter/material.dart';
import '../../game/mini_td_game.dart';
import '../../game/components/hud_bridge.dart';
import '../results/result_screen.dart';
import '../storage/save_service.dart';
import 'package:flame/game.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bestWave = 0;

  @override
  void initState() {
    super.initState();
    _loadBestWave();
  }

  Future<void> _loadBestWave() async {
    final best = await SaveService.getBestWave();
    setState(() {
      _bestWave = best;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Mini Tower Defense',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Best Wave Reached: $_bestWave',
              style: const TextStyle(fontSize: 24, color: Colors.amber),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GameScreen(),
                  ),
                );
                // Refresh best wave when coming back from game
                _loadBestWave();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: const Text('Start Run', style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final HudBridge _hudBridge;
  late final MiniTdGame _game;

  @override
  void initState() {
    super.initState();
    _hudBridge = HudBridge();
    _game = MiniTdGame(
      hudBridge: _hudBridge,
      onGameOver: (win) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              didWin: win,
              waveReached: _hudBridge.wave.value,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game),
          // HUD Overlay
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: _hudBridge.gold,
                  builder: (context, gold, child) => Text(
                    'Gold: $gold',
                    style: const TextStyle(fontSize: 24, color: Colors.amber, fontWeight: FontWeight.bold),
                  ),
                ),
                ValueListenableBuilder<int>(
                  valueListenable: _hudBridge.wave,
                  builder: (context, wave, child) => Text(
                    'Wave: $wave/10',
                    style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                ValueListenableBuilder<int>(
                  valueListenable: _hudBridge.lives,
                  builder: (context, lives, child) => Text(
                    'Lives: $lives',
                    style: const TextStyle(fontSize: 24, color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Pause/Back buttons
          Positioned(
            top: 20,
            right: 20,
            // Adjust position slightly to be below the row or beside it if more space
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          // Tower Selection Overlay
          ValueListenableBuilder<int?>(
            valueListenable: _hudBridge.selectedPadIndex,
            builder: (context, padIndex, child) {
              if (padIndex == null) return const SizedBox.shrink();

              return Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTowerButton('Dart', 40, Colors.grey, padIndex),
                        const SizedBox(width: 8),
                        _buildTowerButton('Cannon', 70, Colors.blueGrey, padIndex),
                        const SizedBox(width: 8),
                        _buildTowerButton('Frost', 60, Colors.lightBlue, padIndex),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.redAccent),
                          onPressed: () => _hudBridge.selectedPadIndex.value = null,
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTowerButton(String type, int cost, Color color, int padIndex) {
    return ElevatedButton(
      onPressed: () => _game.buildTower(padIndex, type),
      style: ElevatedButton.styleFrom(backgroundColor: color),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('\$$cost'),
        ],
      ),
    );
  }
}
