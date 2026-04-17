import 'package:shared_preferences/shared_preferences.dart';

class SaveService {
  static const String _bestWaveKey = 'best_wave';

  static Future<int> getBestWave() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestWaveKey) ?? 0;
  }

  static Future<void> saveBestWave(int wave) async {
    final prefs = await SharedPreferences.getInstance();
    final currentBest = prefs.getInt(_bestWaveKey) ?? 0;
    if (wave > currentBest) {
      await prefs.setInt(_bestWaveKey, wave);
    }
  }
}
