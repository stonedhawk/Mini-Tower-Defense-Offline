import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../mini_td_game.dart';
import '../components/enemy_component.dart';

class DebugOverlay extends Component with HasGameReference<MiniTdGame> {
  static bool isEnabled = false;

  @override
  void render(Canvas canvas) {
    if (!isEnabled) return;

    const fps = 60.0; // Placeholder for now
    final entities = game.children.length;
    final enemies = game.children.whereType<EnemyComponent>().length;
    final wave = game.hudBridge.wave.value;

    final text = 'DEBUG MODE\n'
                 'FPS: ${fps.toStringAsFixed(1)}\n'
                 'Entities: $entities\n'
                 'Enemies: $enemies\n'
                 'Wave: $wave\n'
                 'Time: ${game.elapsedTime.toStringAsFixed(1)}s';

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF00FF41), // Matrix Green
          fontSize: 12,
          fontFamily: 'Courier',
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    
    // Draw background box
    final rect = Rect.fromLTWH(15, 95, textPainter.width + 10, textPainter.height + 10);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), Paint()..color = Colors.black87);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), Paint()..color = const Color(0xFF00FF41)..style = PaintingStyle.stroke..strokeWidth = 1);

    textPainter.paint(canvas, const Offset(20, 100));
  }
}
