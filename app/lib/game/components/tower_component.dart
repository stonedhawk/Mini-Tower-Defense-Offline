import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../mini_td_game.dart';
import 'enemy_component.dart';
import 'projectile_component.dart';

abstract class TowerComponent extends PositionComponent with HasGameReference<MiniTdGame>, TapCallbacks {
  double attackRange;
  int damage;
  double cooldown;
  double projectileSpeed;
  int level = 1;
  int get baseUpgradeCost => (damage * 2) + (attackRange ~/ 10);
  int get upgradeCost => (baseUpgradeCost * math.pow(1.5, level - 1)).ceil();
  
  // Tap handling for tooltip/upgrade selection
  @override
  void onTapDown(TapDownEvent event) {
    game.hudBridge.selectedTowerId.value = hashCode;
    game.hudBridge.selectedTowerPosition.value = position.clone();
  }
  
  double _currentCooldown = 0.0;
  double _auraTimer = 0.0;
  double _speedBoost = 1.0;

  TowerComponent({
    required this.attackRange,
    required this.damage,
    required this.cooldown,
    required this.projectileSpeed,
    required Vector2 position,
  }) : super(position: position, size: Vector2(40, 40), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    if (!isMounted) return;
    
    // Check for nearby boosters (Throttled to 5Hz)
    _auraTimer -= dt;
    if (_auraTimer <= 0) {
      _auraTimer = 0.2;
      _speedBoost = 1.0;
      try {
        for (final component in game.children) {
          if (component is BoosterTowerComponent) {
            if (component.position.distanceTo(position) <= component.attackRange) {
              _speedBoost = 1.25; // 25% buff
              break;
            }
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
    double closestDistanceToExitSquared = double.infinity;

    for (final component in game.children) {
      if (component is EnemyComponent) {
        if (position.distanceTo(component.position) <= attackRange) {
          // Simplistic "closest to exit" heuristic for now: higher waypoint index
          // But since we just want closest to exit geometrically, we can use 
          // the distance from final waypoint. 
          // Actually, MVP targeting rule: "All towers target the in-range enemy closest to the exit."
          final proxyScore = component.distanceToTargetOrExit(); 
          if (proxyScore < closestDistanceToExitSquared) {
            closestDistanceToExitSquared = proxyScore;
            bestTarget = component;
          }
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
    bool isFrost = this is FrostTowerComponent;
    double splashRadius = this is CannonTowerComponent ? 32.0 : 0.0;

    game.add(ProjectileComponent(
      sourcePosition: position.clone(),
      target: target,
      damage: damage,
      speed: projectileSpeed,
      splashRadius: splashRadius,
      isFrost: isFrost,
    ));
  }

}

class DartTowerComponent extends TowerComponent {
  DartTowerComponent({required super.position})
      : super(
          attackRange: 110.0,
          damage: 7,
          cooldown: 0.6,
          projectileSpeed: 280.0,
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Draw range indicator if selected
    if (game.hudBridge.selectedTowerId.value == hashCode) {
      final rangePaint = Paint()
        ..color = const Color(0x40FFFFFF) // very faint white
        ..style = PaintingStyle.fill;
      canvas.drawCircle((size / 2).toOffset(), attackRange, rangePaint);
      
      final borderPaint = Paint()
        ..color = const Color(0x80FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle((size / 2).toOffset(), attackRange, borderPaint);
    }

    final paint = Paint()..color = const Color(0xFF9E9E9E); // Grey tower
    canvas.drawRect(size.toRect(), paint);
  }
}

class CannonTowerComponent extends TowerComponent {
  CannonTowerComponent({required super.position})
      : super(
          attackRange: 125.0,
          damage: 14,
          cooldown: 1.4,
          projectileSpeed: 220.0,
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Draw range indicator if selected
    if (game.hudBridge.selectedTowerId.value == hashCode) {
      final rangePaint = Paint()
        ..color = const Color(0x40FFFFFF) // very faint white
        ..style = PaintingStyle.fill;
      canvas.drawCircle((size / 2).toOffset(), attackRange, rangePaint);
      
      final borderPaint = Paint()
        ..color = const Color(0x80FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle((size / 2).toOffset(), attackRange, borderPaint);
    }

    final paint = Paint()..color = const Color(0xFF424242); // Darker Grey / Black
    canvas.drawCircle((size / 2).toOffset(), size.x / 2, paint);
  }
}

class FrostTowerComponent extends TowerComponent {
  FrostTowerComponent({required super.position})
      : super(
          attackRange: 100.0,
          damage: 4,
          cooldown: 0.8,
          projectileSpeed: 260.0,
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Draw range indicator if selected
    if (game.hudBridge.selectedTowerId.value == hashCode) {
      final rangePaint = Paint()
        ..color = const Color(0x40FFFFFF) // very faint white
        ..style = PaintingStyle.fill;
      canvas.drawCircle((size / 2).toOffset(), attackRange, rangePaint);
      
      final borderPaint = Paint()
        ..color = const Color(0x80FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle((size / 2).toOffset(), attackRange, borderPaint);
    }

    final paint = Paint()..color = const Color(0xFF81D4FA); // Light Blue
    canvas.drawRect(size.toRect(), paint);
  }
}
class BoosterTowerComponent extends TowerComponent {
  BoosterTowerComponent({required super.position})
      : super(
          attackRange: 80.0,
          damage: 0,
          cooldown: 0,
          projectileSpeed: 0,
        );

  @override
  void update(double dt) {
    // No targeting or firing
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas); // Handles selected range

    // Pulsing Aura Effect (Fill)
    final auraPaint = Paint()
      ..color = const Color(0x30FF9800).withValues(alpha: 0.15 + (0.05 * math.sin(game.elapsedTime * 3)))
      ..style = PaintingStyle.fill;
    canvas.drawCircle((size / 2).toOffset(), attackRange, auraPaint);

    final paint = Paint()..color = const Color(0xFFFF9800); // Orange
    // Draw a star or diamond shape
    final path = Path();
    path.moveTo(size.x / 2, 0);
    path.lineTo(size.x, size.y / 2);
    path.lineTo(size.x / 2, size.y);
    path.lineTo(0, size.y / 2);
    path.close();
    canvas.drawPath(path, paint);
  }
}
