import 'package:flutter/material.dart';
import '../../game/mini_td_game.dart';
import '../../game/components/hud_bridge.dart';
import 'package:flame/game.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GameScreen(),
                  ),
                );
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
    _game = MiniTdGame(hudBridge: _hudBridge);
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
        ],
      ),
    );
  }
}
