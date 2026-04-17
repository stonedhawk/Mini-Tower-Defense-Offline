import 'package:flame/components.dart';

class PathConfig {
  /// The fixed sequence of waypoints the enemies will follow.
  /// Defined in logical coordinates for the 1280x720 canvas.
  static final List<Vector2> waypoints = [
    Vector2(0, 150),    // Spawn left
    Vector2(300, 150),  // Move right
    Vector2(300, 500),  // Move down
    Vector2(900, 500),  // Move right
    Vector2(900, 200),  // Move up
    Vector2(1280, 200), // Exit right
  ];
}
