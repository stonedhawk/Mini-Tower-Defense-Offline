import 'package:flutter/foundation.dart';
import 'package:flame/components.dart';
import '../config/game_constants.dart';

/// A simple state bridge between the Flame game and the Flutter HUD overlays.
class HudBridge {
  final ValueNotifier<int> gold = ValueNotifier(GameConstants.startingGold);
  final ValueNotifier<int> lives = ValueNotifier(GameConstants.startingLives);
  final ValueNotifier<int> wave = ValueNotifier(GameConstants.startingWave);
  final ValueNotifier<int?> selectedPadIndex = ValueNotifier(null);
  final ValueNotifier<Vector2?> selectedTowerPosition = ValueNotifier(null);
  final ValueNotifier<double> gameSpeed = ValueNotifier(1.0);
  final ValueNotifier<int?> selectedTowerId = ValueNotifier(null);
  final ValueNotifier<String?> selectedBuildType = ValueNotifier(null);
  /// True while the "You Win!" overlay is visible between wave 10 and endless mode.
  final ValueNotifier<bool> showWinOverlay = ValueNotifier(false);
  /// Flips to true once the player chooses Keep Going — drives wave counter display.
  final ValueNotifier<bool> isEndlessMode = ValueNotifier(false);

  void reset() {
    gold.value = GameConstants.startingGold;
    lives.value = GameConstants.startingLives;
    wave.value = GameConstants.startingWave;
    selectedPadIndex.value = null;
    selectedTowerPosition.value = null;
    selectedBuildType.value = null;
    showWinOverlay.value = false;
    isEndlessMode.value = false;
  }
}
