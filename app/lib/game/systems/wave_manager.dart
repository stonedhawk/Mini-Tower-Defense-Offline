import 'package:flame/components.dart';
import '../mini_td_game.dart';
import '../components/enemy_component.dart';
import 'sound_service.dart';

class WaveManager extends Component with HasGameReference<MiniTdGame> {
  int currentWaveIndex = 0;
  int currentSpawnIndex = 0;
  double _spawnTimer = 0;
  bool isSpawning = false;

  void startNextWave() {
    isSpawning = true;
    currentSpawnIndex = 0;
    _spawnTimer = 0.7;
    game.hudBridge.wave.value = currentWaveIndex + 1;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Loss condition
    if (game.hudBridge.lives.value <= 0) {
      game.triggerGameOver(win: false);
      return;
    }

    if (!isSpawning) {
      final enemies = game.children.whereType<EnemyComponent>();
      bool waveFinished = false;

      if (currentWaveIndex < game.levelData.waves.length) {
        waveFinished = enemies.isEmpty &&
            currentSpawnIndex >= game.levelData.waves[currentWaveIndex].length;
      } else {
        final expectedCount =
            10 + (currentWaveIndex - game.levelData.waves.length + 1) * 2;
        waveFinished =
            enemies.isEmpty && currentSpawnIndex >= expectedCount;
      }

      if (waveFinished) {
        game.hudBridge.gold.value += 20;
        SoundService.instance.playWaveClear();
        currentWaveIndex++;

        // Win condition — all defined waves cleared (skip if already in endless)
        if (currentWaveIndex >= game.levelData.waves.length &&
            !game.hudBridge.isEndlessMode.value) {
          game.triggerWin();
          return;
        }

        // Unlock 2 new build pads every 3 waves (after waves 3 and 6)
        if (currentWaveIndex == 3 || currentWaveIndex == 6) {
          game.unlockNextPadBatch(2);
        }

        startNextWave();
      }
      return;
    }

    // Spawn interval
    _spawnTimer -= dt;
    if (_spawnTimer <= 0) {
      _spawnTimer = 0.7;

      String enemyType = 'Scout';
      // Start with the map's difficulty multiplier; endless mode stacks on top.
      double statMultiplier = game.levelData.difficultyMultiplier;
      int waveSize = 0;

      if (currentWaveIndex < game.levelData.waves.length) {
        final waveList = game.levelData.waves[currentWaveIndex];
        enemyType = waveList[currentSpawnIndex];
        waveSize = waveList.length;
      } else {
        final endlessCount = currentWaveIndex - game.levelData.waves.length + 1;
        waveSize = 10 + endlessCount * 2;
        statMultiplier = game.levelData.difficultyMultiplier * (1.0 + endlessCount * 0.15);

        final rand = (currentSpawnIndex + currentWaveIndex * 7) % 10;
        if (rand < 5) {
          enemyType = 'Scout';
        } else if (rand < 8) {
          enemyType = 'Swarm';
        } else {
          enemyType = 'Tank';
        }
      }

      switch (enemyType) {
        case 'Scout':
          game.add(ScoutEnemy(statMultiplier: statMultiplier));
          break;
        case 'Tank':
          game.add(TankEnemy(statMultiplier: statMultiplier));
          break;
        case 'Swarm':
          game.add(SwarmEnemy(statMultiplier: statMultiplier));
          break;
      }

      currentSpawnIndex++;
      if (currentSpawnIndex >= waveSize) {
        isSpawning = false;
      }
    }
  }
}
