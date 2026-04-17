import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../mini_td_game.dart';
import 'enemy_component.dart';
import 'projectile_component.dart';

abstract class TowerComponent extends PositionComponent with HasGameReference<MiniTdGame> {
  final double attackRange;
  final int damage;
  final double cooldown;
  final double projectileSpeed;
  
  double _currentCooldown = 0.0;

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
    
    if (_currentCooldown > 0) {
      _currentCooldown -= dt;
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
    final paint = Paint()..color = const Color(0xFF81D4FA); // Light Blue
    canvas.drawRect(size.toRect(), paint);
  }
}
