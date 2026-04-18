import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LevelData {
  final int id;
  final String name;
  final List<Vector2> waypoints;
  final List<Vector2> buildPads;
  final List<List<String>> waves;
  final Color backgroundColor;

  /// How many pads are visible when the level starts.
  /// The remaining pads (up to buildPads.length) unlock as waves progress.
  final int initialPadCount;

  /// Flat multiplier applied to every enemy's hp and speed on this map.
  /// Level 1 = 1.0, Level 2 = 1.25, Level 3 = 1.56 (1.25²).
  final double difficultyMultiplier;

  /// How many upgrade levels a tower can reach on this map.
  /// Level 1 = 2, Level 2 = 3, Level 3 = 4.
  final int maxTowerLevel;

  LevelData({
    required this.id,
    required this.name,
    required this.waypoints,
    required this.buildPads,
    required this.waves,
    this.backgroundColor = const Color(0xFF2E7D32),
    this.initialPadCount = 8,
    this.difficultyMultiplier = 1.0,
    this.maxTowerLevel = 2,
  });
}
