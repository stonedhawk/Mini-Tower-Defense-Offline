import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import '../mini_td_game.dart';
import '../systems/sound_service.dart';
import 'enemy_component.dart';
import 'projectile_component.dart';

abstract class TowerComponent extends PositionComponent
    with HasGameReference<MiniTdGame>, TapCallbacks {
  double attackRange;
  int damage;
  double cooldown;
  double projectileSpeed;
  int level = 1;
  int get baseUpgradeCost => (damage * 2) + (attackRange ~/ 10);
  int get upgradeCost => (baseUpgradeCost * math.pow(1.5, level - 1)).ceil();

  double _currentCooldown = 0.0;
  double _auraTimer = 0.0;
  double _speedBoost = 1.0;

  SpriteAnimationTicker? _animTicker;

  TowerComponent({
    required this.attackRange,
    required this.damage,
    required this.cooldown,
    required this.projectileSpeed,
    required Vector2 position,
  }) : super(position: position, size: Vector2(40, 40), anchor: Anchor.center);

  /// Each subclass provides the sprite sheet asset path.
  String get spritePath;

  @override
  void onTapDown(TapDownEvent event) {
    game.hudBridge.selectedTowerId.value = hashCode;
    game.hudBridge.selectedTowerPosition.value = position.clone();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final animation = await game.loadSpriteAnimation(
      spritePath,
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: 0.15,
        textureSize: Vector2(128, 128),
      ),
    );
    _animTicker = SpriteAnimationTicker(animation);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animTicker?.update(dt);
    if (!isMounted) return;

    // Booster aura check (throttled to 5 Hz)
    _auraTimer -= dt;
    if (_auraTimer <= 0) {
      _auraTimer = 0.2;
      _speedBoost = 1.0;
      try {
        for (final component in game.children) {
          if (component is BoosterTowerComponent &&
              component.position.distanceTo(position) <= component.attackRange) {
            _speedBoost = 1.25;
            break;
          }
        }
      } catch (_) {}
    }

    if (_currentCooldown > 0) {
      _currentCooldown -= dt * _speedBoost;
      return;
    }

    final target = _findTarget();
    if (target != null) {
      _fireProjectile(target);
      _currentCooldown = cooldown;
    }
  }

  EnemyComponent? _findTarget() {
    EnemyComponent? bestTarget;
    double bestScore = double.infinity;
    for (final component in game.children) {
      if (component is EnemyComponent &&
          position.distanceTo(component.position) <= attackRange) {
        final score = component.distanceToTargetOrExit();
        if (score < bestScore) {
          bestScore = score;
          bestTarget = component;
        }
      }
    }
    return bestTarget;
  }

  bool get canUpgrade => level < game.levelData.maxTowerLevel;

  void upgrade() {
    if (canUpgrade && game.hudBridge.gold.value >= upgradeCost) {
      game.hudBridge.gold.value -= upgradeCost;
      level++;
      damage += 2;
      attackRange += 10;
      cooldown = (cooldown * 0.9).clamp(0.2, double.infinity);
    }
  }

  void _fireProjectile(EnemyComponent target) {
    SoundService.instance.playShoot();
    game.add(ProjectileComponent(
      sourcePosition: position.clone(),
      target: target,
      damage: damage,
      speed: projectileSpeed,
      splashRadius: this is CannonTowerComponent ? 32.0 : 0.0,
      isFrost: this is FrostTowerComponent,
    ));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Range indicator when selected
    if (game.hudBridge.selectedTowerId.value == hashCode) {
      canvas.drawCircle(
        (size / 2).toOffset(),
        attackRange,
        Paint()
          ..color = const Color(0x40FFFFFF)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        (size / 2).toOffset(),
        attackRange,
        Paint()
          ..color = const Color(0x80FFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // Sprite fills the component bounds
    _animTicker?.currentFrame.sprite.render(canvas, size: size);
  }
}

// ── Subclasses ────────────────────────────────────────────────────

class DartTowerComponent extends TowerComponent {
  DartTowerComponent({required super.position})
      : super(attackRange: 110.0, damage: 7, cooldown: 0.6, projectileSpeed: 280.0);

  @override
  String get spritePath => 'sprites/tower_dart.png';
}

class CannonTowerComponent extends TowerComponent {
  CannonTowerComponent({required super.position})
      : super(attackRange: 125.0, damage: 14, cooldown: 1.4, projectileSpeed: 220.0);

  @override
  String get spritePath => 'sprites/tower_cannon.png';
}

class FrostTowerComponent extends TowerComponent {
  FrostTowerComponent({required super.position})
      : super(attackRange: 100.0, damage: 4, cooldown: 0.8, projectileSpeed: 260.0);

  @override
  String get spritePath => 'sprites/tower_frost.png';
}

class BoosterTowerComponent extends TowerComponent {
  BoosterTowerComponent({required super.position})
      : super(attackRange: 80.0, damage: 0, cooldown: 0, projectileSpeed: 0);

  @override
  String get spritePath => 'sprites/tower_booster.png';

  @override
  void update(double dt) {
    // No targeting or firing — just tick animation and aura timer
    _animTicker?.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Pulsing aura ring on top of sprite
    final pulse = 0.15 + 0.05 * math.sin(game.elapsedTime * 3);
    canvas.drawCircle(
      (size / 2).toOffset(),
      attackRange,
      Paint()
        ..color = const Color(0xFFFF9800).withValues(alpha: pulse)
        ..style = PaintingStyle.fill,
    );
  }
}
