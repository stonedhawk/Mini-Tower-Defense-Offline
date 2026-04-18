import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/hud_bridge.dart';
import 'config/game_constants.dart';
import 'models/level_data.dart';
import 'components/build_pad_component.dart';
import 'components/tower_component.dart';
import 'systems/wave_manager.dart';
import 'systems/sound_service.dart';
import 'package:flame/components.dart';
import 'systems/debug_overlay.dart';

class MiniTdGame extends FlameGame {
  final HudBridge hudBridge;
  final Function(bool win) onGameOver;
  final LevelData levelData;
  late final WaveManager _waveManager;
  double _elapsedTime = 0.0;
  double get elapsedTime => _elapsedTime;

  int _unlockedPadCount = 0;

  MiniTdGame({
    required this.hudBridge,
    required this.onGameOver,
    required this.levelData,
  }) 
      : super(
          camera: CameraComponent.withFixedResolution(
            width: GameConstants.logicalWidth,
            height: GameConstants.logicalHeight,
          ),
        ) {
    // Other initialization if needed
  }

  @override
  void update(double dt) {
    // Apply global speed multiplier
    final scaledDt = dt * hudBridge.gameSpeed.value;
    _elapsedTime += scaledDt;
    super.update(scaledDt);
  }

  void toggleSpeed() {
    hudBridge.gameSpeed.value = hudBridge.gameSpeed.value == 1.0 ? 2.0 : 1.0;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add background based on level theme
    add(RectangleComponent(
      position: Vector2.zero(),
      size: Vector2(GameConstants.logicalWidth, GameConstants.logicalHeight),
      paint: Paint()..color = levelData.backgroundColor,
    ));

    // Render path using segments from level waypoints
    for (int i = 0; i < levelData.waypoints.length - 1; i++) {
      final start = levelData.waypoints[i];
      final end = levelData.waypoints[i + 1];
      add(PathSegmentComponent(start: start, end: end));
    }

    // Render only the initial batch of build pads; more unlock as waves progress.
    _unlockedPadCount = levelData.initialPadCount;
    for (int i = 0; i < _unlockedPadCount; i++) {
      add(BuildPadComponent(
        padIndex: i,
        position: levelData.buildPads[i],
        size: Vector2.all(GameConstants.padSize),
      ));
    }

    // Initialize WaveManager
    _waveManager = WaveManager();
    await add(_waveManager);
    
    // Start game
    _waveManager.startNextWave();

    // Add Debug Overlay (hidden by default)
    add(DebugOverlay());
  }


  /// Reveals the next [count] build pads from the level's full pad list.
  /// Called by WaveManager every 3 waves. Silently caps at the full list length.
  void unlockNextPadBatch(int count) {
    final start = _unlockedPadCount;
    final end = (start + count).clamp(0, levelData.buildPads.length);
    for (int i = start; i < end; i++) {
      add(BuildPadComponent(
        padIndex: i,
        position: levelData.buildPads[i],
        size: Vector2.all(GameConstants.padSize),
      ));
    }
    _unlockedPadCount = end;
  }

  /// Called by WaveManager when all 10 defined waves are cleared.
  /// Pauses the engine and shows the in-game win overlay so the player can
  /// choose "Keep Going?" (endless) or "End Run" (result screen).
  void triggerWin() {
    pauseEngine();
    SoundService.instance.playWin();
    hudBridge.showWinOverlay.value = true;
  }

  /// Player tapped "Keep Going?" — resume from wave 11+ in endless mode.
  void resumeEndless() {
    hudBridge.showWinOverlay.value = false;
    hudBridge.isEndlessMode.value = true;
    resumeEngine();
  }

  void triggerGameOver({required bool win}) {
    pauseEngine();
    if (!win) SoundService.instance.playLose();
    onGameOver(win);
  }

  void onPadTapped(int index) {
    hudBridge.selectedPadIndex.value = index;
  }

  void buildTower(int padIndex, String towerType) {
    if (hudBridge.gold.value <= 0) return;

    int cost = 0;
    if (towerType == 'Dart') cost = 40;
    if (towerType == 'Cannon') cost = 70;
    if (towerType == 'Frost') cost = 60;
    if (towerType == 'Booster') cost = 100;

    if (hudBridge.gold.value >= cost && cost > 0) {
      final pad = children.whereType<BuildPadComponent>().firstWhere((p) => p.padIndex == padIndex);
      if (!pad.isOccupied) {
        hudBridge.gold.value -= cost;
        
        switch (towerType) {
          case 'Dart':
            add(DartTowerComponent(position: pad.position));
            break;
          case 'Cannon':
            add(CannonTowerComponent(position: pad.position));
            break;
          case 'Frost':
            add(FrostTowerComponent(position: pad.position));
            break;
          case 'Booster':
            add(BoosterTowerComponent(position: pad.position));
            break;
        }
        
        pad.isOccupied = true;
      }
    }
    hudBridge.selectedPadIndex.value = null; // dismiss UI
  }
}

// Helper to draw a visible line segment for the path
class PathSegmentComponent extends PositionComponent {
  final Vector2 start;
  final Vector2 end;

  PathSegmentComponent({required this.start, required this.end});

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = const Color(0xFFD7CCC8) // Light path color
      ..strokeWidth = 40.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start.toOffset(), end.toOffset(), paint);
  }
}
