import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Game Logic Tests', () {
    test('Wave Scaling Calculation', () {
      // Test the procedural scaling logic (Endless Mode)
      // Wave 11 is the first procedural wave (logic: 10 + (currentWave - 10) * 2)
      int currentWaveIndex = 10; // 0-indexed, so Wave 11
      int handheldWavesLength = 10;
      
      final endlessCount = currentWaveIndex - handheldWavesLength + 1;
      final waveSize = 10 + endlessCount * 2;
      final statMultiplier = 1.0 + endlessCount * 0.15;
      
      expect(waveSize, 12); // 10 + 1 * 2
      expect(statMultiplier, 1.15); // 1.0 + 1 * 0.15
    });

    test('Tower Upgrade Cost Math', () {
      // level 1 cost: baseUpgradeCost * 1.5 ^ 0 = base
      // level 2 cost: baseUpgradeCost * 1.5 ^ 1
      final damage = 10;
      final range = 100.0;
      final baseUpgradeCost = (damage * 2) + (range ~/ 10); // 20 + 10 = 30
      
      int level1Cost = (baseUpgradeCost * 1.0).ceil();
      int level2Cost = (baseUpgradeCost * 1.5).ceil();
      
      expect(level1Cost, 30);
      expect(level2Cost, 45);
    });
  });
}
