import 'package:flutter/foundation.dart';
import '../config/game_constants.dart';

/// A simple state bridge between the Flame game and the Flutter HUD overlays.
class HudBridge {
  final ValueNotifier<int> gold = ValueNotifier(GameConstants.startingGold);
  final ValueNotifier<int> lives = ValueNotifier(GameConstants.startingLives);
  final ValueNotifier<int> wave = ValueNotifier(GameConstants.startingWave);
  final ValueNotifier<int?> selectedPadIndex = ValueNotifier(null);

  void reset() {
    gold.value = GameConstants.startingGold;
    lives.value = GameConstants.startingLives;
    wave.value = GameConstants.startingWave;
    selectedPadIndex.value = null;
  }
}
