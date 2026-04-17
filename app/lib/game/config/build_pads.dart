import 'package:flame/components.dart';

class BuildPadConfig {
  /// Defines exactly 8 predetermined locations for the build pads
  static final List<Vector2> padLocations = [
    Vector2(150, 250),
    Vector2(450, 150),
    Vector2(450, 400),
    Vector2(450, 600),
    Vector2(750, 400),
    Vector2(750, 600),
    Vector2(1050, 100),
    Vector2(1050, 300),
  ];

  static const double padSize = 64.0;
}
