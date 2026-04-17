import 'package:flame/components.dart';
import '../mini_td_game.dart';
import '../config/waves.dart';
import '../components/enemy_component.dart';

class WaveManager extends Component with HasGameReference<MiniTdGame> {
  int currentWaveIndex = 0;
  int currentSpawnIndex = 0;
  double _spawnTimer = 0;
  bool isSpawning = false;
  
  void startNextWave() {
    if (currentWaveIndex < WaveConfig.waves.length) {
      isSpawning = true;
      currentSpawnIndex = 0;
      _spawnTimer = 0.7; // initial brief delay
      game.hudBridge.wave.value = currentWaveIndex + 1;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Check Loss Condition
    if (game.hudBridge.lives.value <= 0) {
      game.triggerGameOver(win: false);
      return;
    }

    if (!isSpawning) {
      if (currentWaveIndex >= WaveConfig.waves.length) return; // Already finished sequence

      // If finished spawning, check if screen is wiped
      final enemies = game.children.whereType<EnemyComponent>();
      if (enemies.isEmpty && currentSpawnIndex >= WaveConfig.waves[currentWaveIndex].length) {
        // Wave fully cleared
        game.hudBridge.gold.value += 20; // PRD: 20 gold wave clear bonus
        currentWaveIndex++;
        
        if (currentWaveIndex >= WaveConfig.waves.length) {
          game.triggerGameOver(win: true);
        } else {
          // MVP simple feature: Start next automatically (no Start wave button)
          startNextWave();
        }
      }
      return;
    }

    // Handle spawn interval
    _spawnTimer -= dt;
    if (_spawnTimer <= 0) {
      _spawnTimer = 0.7; // default interval
      final waveList = WaveConfig.waves[currentWaveIndex];
      final enemyType = waveList[currentSpawnIndex];
      
      switch (enemyType) {
        case 'Scout':
          game.add(ScoutEnemy());
          break;
        case 'Tank':
          game.add(TankEnemy());
          break;
        case 'Swarm':
          game.add(SwarmEnemy());
          break;
      }

      currentSpawnIndex++;
      if (currentSpawnIndex >= waveList.length) {
        isSpawning = false;
      }
    }
  }
}
