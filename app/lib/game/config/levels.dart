import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../models/level_data.dart';

class LevelRegistry {
  static final List<LevelData> allLevels = [
    level1,
    level2,
    level3,
  ];

  // ---------------------------------------------------------------------------
  // Level 1 — Green Lanes
  // Path: (0,150)→(300,150)→(300,500)→(900,500)→(900,200)→(1280,200)
  // ---------------------------------------------------------------------------
  static final LevelData level1 = LevelData(
    id: 1,
    name: 'Green Lanes',
    waypoints: [
      Vector2(0, 150),
      Vector2(300, 150),
      Vector2(300, 500),
      Vector2(900, 500),
      Vector2(900, 200),
      Vector2(1280, 200),
    ],
    // 12 pads total. First 8 start visible; 9–10 unlock after wave 3, 11–12 after wave 6.
    buildPads: [
      // --- Initial 8 ---
      Vector2(150, 250),   // 0  left — covers first horizontal segment
      Vector2(450, 400),   // 1  covers left vertical + start of bottom horizontal
      Vector2(450, 620),   // 2  bottom-left corner
      Vector2(600, 620),   // 3  center-bottom — ideal Booster spot
      Vector2(750, 400),   // 4  covers bottom horizontal
      Vector2(750, 620),   // 5  bottom-right corner
      Vector2(1050, 100),  // 6  top-right — covers final horizontal exit
      Vector2(1050, 330),  // 7  right side — covers right vertical segment
      // --- Wave-3 unlock (+2) ---
      Vector2(150, 420),   // 8  second left pad — reaches x=300 vertical
      Vector2(600, 380),   // 9  central — covers bottom horizontal from above
      // --- Wave-6 unlock (+2) ---
      Vector2(400, 260),   // 10 near first bend (300,150)
      Vector2(1150, 100),  // 11 far right on exit horizontal
    ],
    initialPadCount: 8,
    waves: _standardWaves,
    backgroundColor: const Color(0xFF2E7D32),
    difficultyMultiplier: 1.0,
    maxTowerLevel: 2,
  );

  // ---------------------------------------------------------------------------
  // Level 2 — Desert Pass
  // Path: (0,500)→(200,500)→(200,200)→(600,200)→(600,500)→(1000,500)→(1000,200)→(1280,200)
  // ---------------------------------------------------------------------------
  static final LevelData level2 = LevelData(
    id: 2,
    name: 'Desert Pass',
    waypoints: [
      Vector2(0, 500),
      Vector2(200, 500),
      Vector2(200, 200),
      Vector2(600, 200),
      Vector2(600, 500),
      Vector2(1000, 500),
      Vector2(1000, 200),
      Vector2(1280, 200),
    ],
    // 12 pads total. First 8 start visible; 9–10 unlock after wave 3, 11–12 after wave 6.
    buildPads: [
      // --- Initial 8 ---
      Vector2(100, 400),   // 0  near entry horizontal (y=500)
      Vector2(300, 300),   // 1  between x=200 and x=600 verticals
      Vector2(500, 100),   // 2  above first U-bend top
      Vector2(700, 300),   // 3  between x=600 and x=1000 verticals
      Vector2(900, 100),   // 4  above second U-bend top
      Vector2(1100, 400),  // 5  near exit horizontal
      Vector2(500, 600),   // 6  below bottom horizontal, left
      Vector2(700, 600),   // 7  below bottom horizontal, right
      // --- Wave-3 unlock (+2) ---
      Vector2(150, 300),   // 8  attacks x=200 left vertical
      Vector2(850, 300),   // 9  attacks x=1000 right vertical
      // --- Wave-6 unlock (+2) ---
      Vector2(400, 400),   // 10 covers multiple horizontal segments
      Vector2(1150, 100),  // 11 top-right near exit
    ],
    initialPadCount: 8,
    waves: _standardWaves,
    backgroundColor: const Color(0xFF8D6E63),
    difficultyMultiplier: 1.25,
    maxTowerLevel: 3,
  );

  // ---------------------------------------------------------------------------
  // Level 3 — Ice Gorge
  // Path: (640,0)→(640,150)→(200,150)→(200,450)→(1080,450)→(1080,720)
  // ---------------------------------------------------------------------------
  static final LevelData level3 = LevelData(
    id: 3,
    name: 'Ice Gorge',
    waypoints: [
      Vector2(640, 0),    // Spawn top middle
      Vector2(640, 150),  // Top bend
      Vector2(200, 150),  // Left horizontal
      Vector2(200, 450),  // Left vertical down
      Vector2(1080, 450), // Right horizontal
      Vector2(1080, 720), // Exit bottom right
    ],
    // 12 pads total. First 8 start visible; 9–10 unlock after wave 3, 11–12 after wave 6.
    buildPads: [
      // --- Initial 8 ---
      Vector2(400, 100),   // 0  left of spawn vertical
      Vector2(800, 100),   // 1  right of spawn vertical
      Vector2(100, 300),   // 2  left of x=200 vertical
      Vector2(1180, 300),  // 3  right of x=1080 vertical
      Vector2(400, 380),   // 4  above bottom horizontal (y=450)
      Vector2(800, 380),   // 5  above bottom horizontal (y=450)
      Vector2(640, 580),   // 6  below exit area
      Vector2(200, 580),   // 7  near x=200 vertical bottom
      // --- Wave-3 unlock (+2) ---
      Vector2(500, 270),   // 8  between the two horizontals, left-center
      Vector2(800, 560),   // 9  below bottom horizontal, right side
      // --- Wave-6 unlock (+2) ---
      Vector2(350, 560),   // 10 below bottom horizontal, left side
      Vector2(950, 320),   // 11 above x=1080 vertical approach
    ],
    initialPadCount: 8,
    waves: _standardWaves,
    backgroundColor: const Color(0xFF01579B),
    difficultyMultiplier: 1.56,
    maxTowerLevel: 4,
  );

  // ---------------------------------------------------------------------------
  // Shared 10-wave sequence (used by all 3 maps)
  // ---------------------------------------------------------------------------
  static final List<List<String>> _standardWaves = [
    ['Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout'],
    ['Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout'],
    ['Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Tank', 'Tank'],
    ['Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Swarm'],
    ['Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Tank', 'Tank', 'Tank', 'Tank'],
    ['Swarm', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Scout', 'Scout', 'Scout', 'Scout', 'Tank', 'Tank'],
    ['Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Tank', 'Tank', 'Tank', 'Tank'],
    ['Tank', 'Tank', 'Tank', 'Tank', 'Tank', 'Tank', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Swarm'],
    ['Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Tank', 'Tank', 'Tank', 'Tank', 'Tank', 'Tank'],
    ['Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Scout', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Swarm', 'Tank', 'Tank', 'Tank', 'Tank', 'Tank', 'Tank', 'Tank', 'Tank'],
  ];
}
