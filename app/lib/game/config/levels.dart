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
  // Pad offsets: 65px from nearest path segment so all tower types cover path.
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
    buildPads: [
      // --- Initial 8 ---
      Vector2(150, 215),   // 0  below top-left horizontal (y=150)
      Vector2(365, 325),   // 1  right of left vertical (x=300)
      Vector2(450, 435),   // 2  above bottom horizontal (y=500), left
      Vector2(600, 435),   // 3  above bottom horizontal, center — Booster ideal
      Vector2(750, 435),   // 4  above bottom horizontal, right
      Vector2(835, 350),   // 5  left of right vertical (x=900)
      Vector2(1050, 265),  // 6  below exit horizontal (y=200)
      Vector2(965, 350),   // 7  right of right vertical (x=900)
      // --- Wave-3 unlock (+2) ---
      Vector2(235, 325),   // 8  left of left vertical (x=300)
      Vector2(600, 565),   // 9  below bottom horizontal, center
      // --- Wave-6 unlock (+2) ---
      Vector2(150, 85),    // 10 above top-left horizontal (y=150)
      Vector2(1150, 265),  // 11 below exit horizontal, far right
    ],
    initialPadCount: 8,
    waves: _standardWaves,
    backgroundColor: const Color(0xFF2E7D32),
    difficultyMultiplier: 1.0,
    maxTowerLevel: 10,
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
    buildPads: [
      // --- Initial 8 ---
      Vector2(100, 435),   // 0  above entry horizontal (y=500)
      Vector2(265, 350),   // 1  right of left vertical (x=200)
      Vector2(400, 265),   // 2  below left top horizontal (y=200)
      Vector2(535, 350),   // 3  left of center vertical (x=600)
      Vector2(800, 435),   // 4  above middle horizontal (y=500)
      Vector2(1065, 350),  // 5  right of right vertical (x=1000)
      Vector2(400, 135),   // 6  above left top horizontal (y=200)
      Vector2(1150, 265),  // 7  below exit horizontal (y=200)
      // --- Wave-3 unlock (+2) ---
      Vector2(135, 350),   // 8  left of left vertical (x=200)
      Vector2(935, 350),   // 9  left of right vertical (x=1000)
      // --- Wave-6 unlock (+2) ---
      Vector2(665, 350),   // 10 right of center vertical (x=600)
      Vector2(1150, 135),  // 11 above exit horizontal (y=200)
    ],
    initialPadCount: 8,
    waves: _standardWaves,
    backgroundColor: const Color(0xFF8D6E63),
    difficultyMultiplier: 1.25,
    maxTowerLevel: 10,
  );

  // ---------------------------------------------------------------------------
  // Level 3 — Ice Gorge
  // Path: (640,0)→(640,150)→(200,150)→(200,450)→(1080,450)→(1080,720)
  // ---------------------------------------------------------------------------
  static final LevelData level3 = LevelData(
    id: 3,
    name: 'Ice Gorge',
    waypoints: [
      Vector2(640, 0),
      Vector2(640, 150),
      Vector2(200, 150),
      Vector2(200, 450),
      Vector2(1080, 450),
      Vector2(1080, 720),
    ],
    buildPads: [
      // --- Initial 8 ---
      Vector2(575, 75),    // 0  left of spawn vertical (x=640)
      Vector2(705, 75),    // 1  right of spawn vertical (x=640)
      Vector2(135, 300),   // 2  left of left vertical (x=200)
      Vector2(1015, 580),  // 3  left of exit vertical (x=1080)
      Vector2(400, 385),   // 4  above bottom horizontal (y=450)
      Vector2(750, 385),   // 5  above bottom horizontal (y=450)
      Vector2(640, 515),   // 6  below bottom horizontal (y=450)
      Vector2(265, 300),   // 7  right of left vertical (x=200)
      // --- Wave-3 unlock (+2) ---
      Vector2(420, 215),   // 8  below top horizontal (y=150)
      Vector2(900, 515),   // 9  below bottom horizontal, right section
      // --- Wave-6 unlock (+2) ---
      Vector2(265, 215),   // 10 inside corner: right of x=200 + below y=150
      Vector2(950, 385),   // 11 above bottom horizontal, near exit vertical
    ],
    initialPadCount: 8,
    waves: _standardWaves,
    backgroundColor: const Color(0xFF01579B),
    difficultyMultiplier: 1.56,
    maxTowerLevel: 10,
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
