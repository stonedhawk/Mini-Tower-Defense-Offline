import 'package:flutter/material.dart';
import '../../game/mini_td_game.dart';
import '../../game/components/hud_bridge.dart';
import '../results/result_screen.dart';
import '../storage/save_service.dart';
import 'package:flame/game.dart';
import 'package:flame/extensions.dart';
import '../../game/components/tower_component.dart';
import '../../game/config/levels.dart';
import '../../game/models/level_data.dart';
import '../../game/systems/debug_overlay.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<int, int> _bestWaves = {};

  @override
  void initState() {
    super.initState();
    _loadAllBestWaves();
  }

  Future<void> _loadAllBestWaves() async {
    final waves = <int, int>{};
    for (final level in LevelRegistry.allLevels) {
      waves[level.id] = await SaveService.getBestWave(level.id);
    }
    setState(() {
      _bestWaves = waves;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Text(
            'Mini Tower Defense',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Select a Battlefield',
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              itemCount: LevelRegistry.allLevels.length,
              itemBuilder: (context, index) {
                final level = LevelRegistry.allLevels[index];
                return _buildLevelCard(level);
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: Text(
              'v1.0.0.0',
              style: TextStyle(color: Colors.white24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(LevelData level) {
    final bestWave = _bestWaves[level.id] ?? 0;
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.95, end: 1.0),
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: GestureDetector(
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => GameScreen(level: level),
              ),
            );
            _loadAllBestWaves();
          },
          child: Container(
            width: 250,
            margin: const EdgeInsets.only(right: 30),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: level.backgroundColor.withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Center(
                      child: Hero(
                        tag: 'level-icon-${level.id}',
                        child: Icon(Icons.map, size: 80, color: level.backgroundColor),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.name,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Best Wave: $bestWave',
                        style: const TextStyle(fontSize: 16, color: Colors.amber),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Text(
                            'START MISSION',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.blueAccent),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final LevelData level;
  const GameScreen({super.key, required this.level});

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
      levelData: widget.level,
      onGameOver: (win) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              levelId: widget.level.id,
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
          // Existing HUD Row
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
                // Speed toggle button
                IconButton(
                  icon: ValueListenableBuilder<double>(
                    valueListenable: _hudBridge.gameSpeed,
                    builder: (context, speed, child) => Icon(
                      speed == 1.0 ? Icons.speed : Icons.double_arrow,
                      color: Colors.white,
                    ),
                  ),
                  tooltip: 'Toggle 1X/2X Speed',
                  onPressed: () => _game.toggleSpeed(),
                ),
              ],
            ),
          ),
          // Version overlay (bottom right) - Double tap for Debug Mode
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              onDoubleTap: () {
                DebugOverlay.isEnabled = !DebugOverlay.isEnabled;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Debug Mode ${DebugOverlay.isEnabled ? 'Enabled' : 'Disabled'}'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Text(
                'v1.0.0.0',
                style: const TextStyle(fontSize: 12, color: Colors.white70, decoration: TextDecoration.underline),
              ),
            ),
          ),
          // Tower tooltip overlay (Floating near selected tower)
          ValueListenableBuilder<int?>(
            valueListenable: _hudBridge.selectedTowerId,
            builder: (context, towerId, child) {
              if (towerId == null) return const SizedBox.shrink();
              
              final towers = _game.children.whereType<TowerComponent>().where((t) => t.hashCode == towerId);
              if (towers.isEmpty) return const SizedBox.shrink();
              final tower = towers.first;

              return ValueListenableBuilder<Vector2?>(
                valueListenable: _hudBridge.selectedTowerPosition,
                builder: (context, pos, child) {
                  if (pos == null) return const SizedBox.shrink();
                  
                  // Position the tooltip near the tower
                  return Positioned(
                    left: pos.x - 100, // Center roughly
                    top: pos.y - 160,  // Above the tower
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                           Text(
                            tower is DartTowerComponent ? 'Dart Tower' :
                            tower is CannonTowerComponent ? 'Cannon' :
                            tower is FrostTowerComponent ? 'Frost Tower' : 'Booster Tower',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Divider(color: Colors.white24),
                          Text('Level: ${tower.level}', style: const TextStyle(color: Colors.white70)),
                          if (tower is! BoosterTowerComponent) ...[
                            Text('Damage: ${tower.damage}', style: const TextStyle(color: Colors.white70)),
                            Text('Range: ${tower.attackRange.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70)),
                          ] else ...[
                            Text('Buff: Attack Speed +25%', style: const TextStyle(color: Colors.orange)),
                            Text('Range: ${tower.attackRange.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70)),
                          ],
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: tower.canUpgrade
                                    ? Colors.amber
                                    : Colors.grey.shade700,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: tower.canUpgrade
                                  ? () {
                                      tower.upgrade();
                                      _hudBridge.selectedTowerId.value = null;
                                      _hudBridge.selectedTowerPosition.value =
                                          null;
                                    }
                                  : null,
                              child: Text(
                                tower.canUpgrade
                                    ? 'Upgrade (${tower.upgradeCost}G)'
                                    : 'MAX LEVEL',
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _hudBridge.selectedTowerId.value = null;
                              _hudBridge.selectedTowerPosition.value = null;
                            },
                            child: const Text('Close', style: TextStyle(color: Colors.white54)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // Pause/Back buttons
          Positioned(
            top: 60,
            right: 20,
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
                        const SizedBox(width: 8),
                        _buildTowerButton('Booster', 100, Colors.orange, padIndex),
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
