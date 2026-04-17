import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'enemy_component.dart';
import '../mini_td_game.dart';

class ProjectileComponent extends PositionComponent with HasGameReference<MiniTdGame> {
  final EnemyComponent target;
  final int damage;
  final double speed;
  final double splashRadius;
  final bool isFrost;
  Vector2 _lastKnownTargetPosition;

  ProjectileComponent({
    required Vector2 sourcePosition,
    required this.target,
    required this.damage,
    required this.speed,
    this.splashRadius = 0.0,
    this.isFrost = false,
  })  : _lastKnownTargetPosition = target.position.clone(),
        super(position: sourcePosition, size: Vector2(8, 8), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);

    // If target is still alive and mounted, update its last known position
    if (target.isMounted) {
      _lastKnownTargetPosition = target.position.clone();
    }

    final dir = (_lastKnownTargetPosition - position)..normalize();
    final step = speed * dt;

    if (position.distanceTo(_lastKnownTargetPosition) <= step) {
      position = _lastKnownTargetPosition.clone();
      _impact();
    } else {
      position.add(dir * step);
    }
  }

  void _impact() {
    if (splashRadius > 0) {
      // Area of Effect Support
      for (final component in game.children) {
        if (component is EnemyComponent) {
          if (component.position.distanceTo(position) <= splashRadius) {
            component.takeDamage(damage);
            // Splashes don't slow enemies based on the MVP PRD, but we can hook it here if needed
          }
        }
      }
    } else {
      // Single Target
      if (target.isMounted) {
        target.takeDamage(damage);
        if (isFrost) {
          target.applySlow(0.65, 1.2);
        }
      }
    }
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    Color color = const Color(0xFFFFFFFF); // White default
    if (isFrost) color = const Color(0xFF81D4FA); // Light Blue
    if (splashRadius > 0) color = const Color(0xFF212121); // Black cannonball

    final paint = Paint()..color = color;
    canvas.drawCircle((size / 2).toOffset(), size.x / 2, paint);
  }
}
