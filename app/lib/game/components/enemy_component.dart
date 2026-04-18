import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import '../mini_td_game.dart';
import '../systems/sound_service.dart';
import 'death_effect.dart';
import 'damage_number_component.dart';

abstract class EnemyComponent extends PositionComponent with HasGameReference<MiniTdGame> {
  int hp;
  final int maxHp;
  final double baseSpeed;
  final int goldReward;
  final int leakDamage;

  double speedMultiplier = 1.0;
  double _slowTimer = 0.0;
  int _currentWaypointIndex = 0;

  SpriteAnimationTicker? _animTicker;

  EnemyComponent({
    required int hp,
    required double baseSpeed,
    required this.goldReward,
    required this.leakDamage,
    double statMultiplier = 1.0,
  })  : hp = (hp * statMultiplier).toInt(),
        maxHp = (hp * statMultiplier).toInt(),
        baseSpeed = (baseSpeed * statMultiplier.clamp(1.0, 1.5)),
        super(size: Vector2(40, 40), anchor: Anchor.center);

  String get spritePath;

  Color get deathColor => const Color(0xFFFFEB3B);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = game.levelData.waypoints[0].clone();
    final animation = await game.loadSpriteAnimation(
      spritePath,
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: 0.1,
        textureSize: Vector2(128, 128),
      ),
    );
    _animTicker = SpriteAnimationTicker(animation);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animTicker?.update(dt);

    if (_currentWaypointIndex >= game.levelData.waypoints.length - 1) return;

    if (_slowTimer > 0) {
      _slowTimer -= dt;
      if (_slowTimer <= 0) speedMultiplier = 1.0;
    }

    final target = game.levelData.waypoints[_currentWaypointIndex + 1];
    final toTarget = target - position;
    final dist = toTarget.length;
    final step = baseSpeed * speedMultiplier * dt;

    // Always check snap-and-advance FIRST so the enemy never freezes at a waypoint.
    if (dist <= step) {
      position = target.clone();
      _currentWaypointIndex++;
      if (_currentWaypointIndex >= game.levelData.waypoints.length - 1) {
        _leak();
      }
    } else if (dist > 0.001) {
      final dir = toTarget / dist;
      angle = math.atan2(dir.y, dir.x);
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
    SoundService.instance.playLeak();
    game.hudBridge.lives.value -= leakDamage;
    if (game.hudBridge.lives.value < 0) game.hudBridge.lives.value = 0;
    removeFromParent();
  }

  void takeDamage(int amount) {
    hp -= amount;
    game.add(DamageNumberComponent(position: position.clone(), amount: amount));
    if (hp <= 0) {
      SoundService.instance.playHit();
      game.hudBridge.gold.value += goldReward;
      game.add(DeathEffect(position: position.clone(), color: deathColor));
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 1. Sprite
    _animTicker?.currentFrame.sprite.render(canvas, size: size);

    // 2. Frost tint when slowed
    if (speedMultiplier < 1.0) {
      final frostPaint = Paint()..color = const Color(0xFF81D4FA).withValues(alpha: 0.4);
      canvas.drawRect(size.toRect(), frostPaint);
    }

    // 3. HP bar (7px tall, snug above sprite)
    final hpRatio = (hp / maxHp).clamp(0.0, 1.0);
    final bgRect = Rect.fromLTWH(0, -8, size.x, 7);
    final fgRect = Rect.fromLTWH(0, -8, size.x * hpRatio, 7);
    canvas.drawRect(bgRect, Paint()..color = const Color(0xFFFF0000));
    canvas.drawRect(fgRect, Paint()..color = const Color(0xFF00FF00));
  }
}

class ScoutEnemy extends EnemyComponent {
  ScoutEnemy({super.statMultiplier = 1.0})
      : super(hp: 18, baseSpeed: 42, goldReward: 8, leakDamage: 1);

  @override
  String get spritePath => 'sprites/enemy_scout.png';

  @override
  Color get deathColor => const Color(0xFFF44336);
}

class TankEnemy extends EnemyComponent {
  TankEnemy({super.statMultiplier = 1.0})
      : super(hp: 48, baseSpeed: 24, goldReward: 16, leakDamage: 1) {
    size = Vector2(60, 60);
  }

  @override
  String get spritePath => 'sprites/enemy_tank.png';

  @override
  Color get deathColor => const Color(0xFFE65100);
}

class SwarmEnemy extends EnemyComponent {
  SwarmEnemy({super.statMultiplier = 1.0})
      : super(hp: 10, baseSpeed: 55, goldReward: 5, leakDamage: 1) {
    size = Vector2(28, 28);
  }

  @override
  String get spritePath => 'sprites/enemy_swarm.png';

  @override
  Color get deathColor => const Color(0xFFFDD835);
}
