import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../mini_td_game.dart';
import 'death_effect.dart';

class EnemyComponent extends PositionComponent with HasGameReference<MiniTdGame> {
  int hp;
  final int maxHp;
  final double baseSpeed;
  final int goldReward;
  final int leakDamage;
  
  double speedMultiplier = 1.0;
  double _slowTimer = 0.0;
  
  int _currentWaypointIndex = 0;

  EnemyComponent({
    required int hp,
    required double baseSpeed,
    required this.goldReward,
    required this.leakDamage,
    double statMultiplier = 1.0,
  }) : hp = (hp * statMultiplier).toInt(),
       maxHp = (hp * statMultiplier).toInt(),
       baseSpeed = (baseSpeed * statMultiplier.clamp(1.0, 1.5)),
       super(size: Vector2(24, 24), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // game is only available after mount — cannot access it in the constructor
    position = game.levelData.waypoints[0].clone();
  }


  @override
  void update(double dt) {
    super.update(dt);
    
    if (_currentWaypointIndex >= game.levelData.waypoints.length - 1) {
      return;
    }

    if (_slowTimer > 0) {
      _slowTimer -= dt;
      if (_slowTimer <= 0) {
        speedMultiplier = 1.0;
      }
    }

    final target = game.levelData.waypoints[_currentWaypointIndex + 1];
    final dir = (target - position)..normalize();
    final step = baseSpeed * speedMultiplier * dt;

    if (position.distanceTo(target) <= step) {
      position = target.clone();
      _currentWaypointIndex++;
      
      if (_currentWaypointIndex >= game.levelData.waypoints.length - 1) {
        _leak();
      }
    } else {
      position.add(dir * step);
    }
  }

  double distanceToTargetOrExit() {
    double distance = 0;
    if (_currentWaypointIndex < game.levelData.waypoints.length - 1) {
      distance += position.distanceTo(game.levelData.waypoints[_currentWaypointIndex + 1]);
      for (int i = _currentWaypointIndex + 1; i < game.levelData.waypoints.length - 1; i++) {
        distance += game.levelData.waypoints[i].distanceTo(game.levelData.waypoints[i + 1]);
      }
    }
    return distance;
  }

  void applySlow(double multiplier, double duration) {
    speedMultiplier = multiplier;
    _slowTimer = duration;
  }

  void _leak() {
    game.hudBridge.lives.value -= leakDamage;
    if (game.hudBridge.lives.value < 0) {
      game.hudBridge.lives.value = 0;
    }
    removeFromParent();
  }

  /// Override in subclasses to choose the kill-burst colour.
  Color get deathColor => const Color(0xFFFFEB3B);

  void takeDamage(int amount) {
    hp -= amount;
    if (hp <= 0) {
      game.hudBridge.gold.value += goldReward;
      game.add(DeathEffect(position: position.clone(), color: deathColor));
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // 1. Unique Shape Drawing (to be overridden by subclasses)
    drawEnemyShape(canvas);

    // 2. Frost tint if slowed (Common logic)
    if (speedMultiplier < 1.0) {
        final frostPaint = Paint()..color = const Color(0xFF81D4FA).withValues(alpha: 0.4);
        canvas.drawRect(size.toRect(), frostPaint);
    }

    // 3. HP Bar (Common logic)
    final barWidth = size.x;
    final barHeight = 4.0;
    final hpRatio = (hp / maxHp).clamp(0.0, 1.0);
    final bgRect = Rect.fromLTWH(0, -6, barWidth, barHeight);
    final fgRect = Rect.fromLTWH(0, -6, barWidth * hpRatio, barHeight);
    final bgPaint = Paint()..color = const Color(0xFFFF0000);
    final fgPaint = Paint()..color = const Color(0xFF00FF00);
    canvas.drawRect(bgRect, bgPaint);
    canvas.drawRect(fgRect, fgPaint);
  }

  /// Subclasses should override this to draw their specific look
  void drawEnemyShape(Canvas canvas) {}
}

class ScoutEnemy extends EnemyComponent {
  ScoutEnemy({super.statMultiplier = 1.0}) : super(
    hp: 18,
    baseSpeed: 42,
    goldReward: 8,
    leakDamage: 1,
  );

  @override
  Color get deathColor => const Color(0xFFF44336); // red burst

  @override
  void drawEnemyShape(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFFF44336);
    canvas.drawCircle((size / 2).toOffset(), size.x / 2, paint);
  }
}

class TankEnemy extends EnemyComponent {
  TankEnemy({super.statMultiplier = 1.0}) : super(
    hp: 48,
    baseSpeed: 24,
    goldReward: 16,
    leakDamage: 1,
  ) {
    size = Vector2(32, 32);
  }

  @override
  Color get deathColor => const Color(0xFFE65100); // orange burst

  @override
  void drawEnemyShape(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFFE65100);
    canvas.drawRect(size.toRect(), paint);
  }
}

class SwarmEnemy extends EnemyComponent {
  SwarmEnemy({super.statMultiplier = 1.0}) : super(
    hp: 10,
    baseSpeed: 55,
    goldReward: 5,
    leakDamage: 1,
  ) {
    size = Vector2(16, 16);
  }

  @override
  Color get deathColor => const Color(0xFFFDD835); // yellow burst

  @override
  void drawEnemyShape(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFFFDD835);
    canvas.drawRect(size.toRect(), paint);
  }
}
