import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/hud_bridge.dart';
import 'config/game_constants.dart';
import 'config/path_points.dart';
import 'config/build_pads.dart';
import 'components/enemy_component.dart';
import 'package:flame/components.dart';

class MiniTdGame extends FlameGame {
  final HudBridge hudBridge;

  MiniTdGame({required this.hudBridge}) 
      : super(
          camera: CameraComponent.withFixedResolution(
            width: GameConstants.logicalWidth,
            height: GameConstants.logicalHeight,
          ),
        ) {
    // Other initialization if needed
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add background (Placeholder simple green field)
    add(RectangleComponent(
      position: Vector2.zero(),
      size: Vector2(GameConstants.logicalWidth, GameConstants.logicalHeight),
      paint: Paint()..color = const Color(0xFF2E7D32), // Dark Green
    ));

    // Render path using a series of line segments
    for (int i = 0; i < PathConfig.waypoints.length - 1; i++) {
      final start = PathConfig.waypoints[i];
      final end = PathConfig.waypoints[i + 1];
      add(PathSegmentComponent(start: start, end: end));
    }

    // Render build pads
    for (final pos in BuildPadConfig.padLocations) {
      add(RectangleComponent(
        position: pos,
        size: Vector2.all(BuildPadConfig.padSize),
        anchor: Anchor.center,
        paint: Paint()..color = const Color(0xFF795548), // Brown pad
      ));
    }

    // Temporary Test: Spawn a Scout Enemy every 3 seconds to verify path movement
    add(TimerComponent(
      period: 3.0,
      repeat: true,
      onTick: () {
        add(ScoutEnemy());
      },
    ));
  }
}

// Helper to draw a visible line segment for the path
class PathSegmentComponent extends PositionComponent {
  final Vector2 start;
  final Vector2 end;

  PathSegmentComponent({required this.start, required this.end});

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = const Color(0xFFD7CCC8) // Light path color
      ..strokeWidth = 40.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start.toOffset(), end.toOffset(), paint);
  }
}
