import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DamageNumberComponent extends PositionComponent {
  final int amount;
  double _timer = 0;
  static const double _duration = 0.75;

  DamageNumberComponent({required Vector2 position, required this.amount})
      : super(position: position.clone(), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    position.y -= 35 * dt;
    if (_timer >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final alpha = (1.0 - (_timer / _duration)).clamp(0.0, 1.0);
    final tp = TextPainter(
      text: TextSpan(
        text: '-$amount',
        style: TextStyle(
          color: Color.fromRGBO(255, 235, 59, alpha),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
  }
}
