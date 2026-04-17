import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'enemy_component.dart';
import '../mini_td_game.dart';

class ProjectileComponent extends PositionComponent with HasGameReference<MiniTdGame> {
  final EnemyComponent target;
  final int damage;
  final double speed;
  Vector2 _lastKnownTargetPosition;

  ProjectileComponent({
    required Vector2 sourcePosition,
    required this.target,
    required this.damage,
    required this.speed,
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
    if (target.isMounted) {
      target.takeDamage(damage);
    }
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = const Color(0xFFFFFFFF); // White projectile
    canvas.drawCircle((size / 2).toOffset(), size.x / 2, paint);
  }
}
