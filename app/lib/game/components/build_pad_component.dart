import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../mini_td_game.dart';

class BuildPadComponent extends PositionComponent with HasGameReference<MiniTdGame>, TapCallbacks {
  final int padIndex;
  bool isOccupied = false;

  BuildPadComponent({
    required this.padIndex,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = const Color(0xFF795548); // Brown pad
    canvas.drawRect(size.toRect(), paint);
    // Draw range indicator if this pad is currently selected
    if (game.hudBridge.selectedPadIndex.value == padIndex) {
      final rangePaint = Paint()
        ..color = const Color(0x80FFFFFF) // white with 50% opacity
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      // Use a generic radius (e.g., 120) – could be refined later based on tower type
      canvas.drawCircle((size / 2).toOffset(), 120, rangePaint);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isOccupied) {
      game.onPadTapped(padIndex);
    }
  }
}
