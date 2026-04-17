import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../config/path_points.dart';
import '../mini_td_game.dart';

class EnemyComponent extends PositionComponent with HasGameReference<MiniTdGame> {
  int hp;
  final double speed;
  final int goldReward;
  final int leakDamage;
  
  int _currentWaypointIndex = 0;

  EnemyComponent({
    required this.hp,
    required this.speed,
    required this.goldReward,
    required this.leakDamage,
  }) {
    position = PathConfig.waypoints[0].clone();
    size = Vector2(24, 24);
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (_currentWaypointIndex >= PathConfig.waypoints.length - 1) {
      return;
    }

    final target = PathConfig.waypoints[_currentWaypointIndex + 1];
    final dir = (target - position)..normalize();
    final step = speed * dt;

    if (position.distanceTo(target) <= step) {
      position = target.clone();
      _currentWaypointIndex++;
      
      if (_currentWaypointIndex >= PathConfig.waypoints.length - 1) {
        _leak();
      }
    } else {
      position.add(dir * step);
    }
  }

  double distanceToTargetOrExit() {
    double distance = 0;
    if (_currentWaypointIndex < PathConfig.waypoints.length - 1) {
      distance += position.distanceTo(PathConfig.waypoints[_currentWaypointIndex + 1]);
      for (int i = _currentWaypointIndex + 1; i < PathConfig.waypoints.length - 1; i++) {
        distance += PathConfig.waypoints[i].distanceTo(PathConfig.waypoints[i + 1]);
      }
    }
    return distance;
  }

  void _leak() {
    game.hudBridge.lives.value -= leakDamage;
    if (game.hudBridge.lives.value < 0) {
      game.hudBridge.lives.value = 0;
    }
    removeFromParent();
  }

  void takeDamage(int amount) {
    hp -= amount;
    if (hp <= 0) {
      game.hudBridge.gold.value += goldReward;
      removeFromParent();
    }
  }
}

class ScoutEnemy extends EnemyComponent {
  ScoutEnemy() : super(
    hp: 18,
    speed: 42,
    goldReward: 8,
    leakDamage: 1,
  );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = const Color(0xFFF44336); // Red dot
    canvas.drawCircle((size / 2).toOffset(), size.x / 2, paint);
  }
}
