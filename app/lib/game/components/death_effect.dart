import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Short-lived particle burst played when an enemy is killed.
/// Eight small circles fly outward and fade over [_lifespan] seconds.
class DeathEffect extends PositionComponent {
  static const int _particleCount = 8;
  static const double _lifespan = 0.45;
  static final Random _rng = Random();

  final Color color;
  final List<_Spark> _sparks;

  DeathEffect({required Vector2 position, required this.color})
      : _sparks = List.generate(_particleCount, (i) {
          final angle = (i / _particleCount) * 2 * pi +
              (_rng.nextDouble() * 0.4 - 0.2); // slight random jitter
          final speed = 55.0 + _rng.nextDouble() * 70.0;
          return _Spark(
            velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
          );
        }),
        super(position: position, anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    bool anyAlive = false;
    for (final spark in _sparks) {
      spark.advance(dt);
      if (!spark.isDead) anyAlive = true;
    }
    if (!anyAlive) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    for (final spark in _sparks) {
      if (spark.isDead) continue;
      final alpha = (1.0 - spark.progress).clamp(0.0, 1.0);
      final radius = (4.0 * (1.0 - spark.progress * 0.4)).clamp(1.0, 6.0);
      final paint = Paint()..color = color.withValues(alpha: alpha);
      canvas.drawCircle(spark.position.toOffset(), radius, paint);
    }
  }
}

class _Spark {
  final Vector2 velocity;
  final Vector2 position = Vector2.zero();
  double _elapsed = 0;

  _Spark({required this.velocity});

  void advance(double dt) {
    _elapsed += dt;
    position.add(velocity * dt);
  }

  double get progress => (_elapsed / DeathEffect._lifespan).clamp(0.0, 1.0);
  bool get isDead => _elapsed >= DeathEffect._lifespan;
}
