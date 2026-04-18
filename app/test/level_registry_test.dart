import 'package:flutter_test/flutter_test.dart';
import 'package:app/game/config/levels.dart';

void main() {
  group('Level Registry Validation', () {
    test('All levels must have valid essential data', () {
      for (final level in LevelRegistry.allLevels) {
        expect(level.id, isNotNull, reason: 'Level ${level.name} missing ID');
        expect(level.waypoints, isNotEmpty, reason: 'Level ${level.name} has no waypoints');
        expect(level.waypoints.length, greaterThanOrEqualTo(2), reason: 'Level ${level.name} needs at least 2 waypoints');
        expect(level.buildPads, isNotEmpty, reason: 'Level ${level.name} has no build pads');
        expect(level.waves, isNotEmpty, reason: 'Level ${level.name} has no waves');
        expect(level.waves.length, equals(10), reason: 'Level ${level.name} should have exactly 10 handcrafted waves');
      }
    });

    test('Unique Level IDs', () {
      final ids = LevelRegistry.allLevels.map((l) => l.id).toList();
      final uniqueIds = ids.toSet();
      expect(ids.length, equals(uniqueIds.length), reason: 'Duplicate Level IDs found in registry');
    });
  });
}
