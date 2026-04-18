import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ImpactEffect extends CircleComponent with HasGameReference {
  final double duration;
  double _timer = 0;

  ImpactEffect({
    required super.position,
    required super.radius,
    required Color color,
    this.duration = 0.2,
  }) : super(
          anchor: Anchor.center,
          paint: Paint()
            ..color = color
            ..style = PaintingStyle.fill,
        );

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    
    // Fade out and expand
    final progress = (_timer / duration).clamp(0.0, 1.0);
    paint.color = paint.color.withValues(alpha: 1.0 - progress);
    scale = Vector2.all(1.0 + progress * 0.5);

    if (_timer >= duration) {
      removeFromParent();
    }
  }
}
