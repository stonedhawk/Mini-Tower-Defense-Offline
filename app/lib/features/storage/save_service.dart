import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveService {
  static String _bestWaveKey(int levelId) => 'best_wave_level_$levelId';

  static Future<int> getBestWave(int levelId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_bestWaveKey(levelId)) ?? 0;
    } catch (e) {
      debugPrint('Error loading best wave for level $levelId: $e');
      return 0;
    }
  }

  static Future<void> saveBestWave(int levelId, int wave) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentBest = prefs.getInt(_bestWaveKey(levelId)) ?? 0;
      if (wave > currentBest) {
        await prefs.setInt(_bestWaveKey(levelId), wave);
      }
    } catch (e) {
      debugPrint('Error saving best wave for level $levelId: $e');
    }
  }
}
