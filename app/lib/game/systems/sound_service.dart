import 'package:audioplayers/audioplayers.dart';

/// Singleton that plays all game SFX.
///
/// Drop real .wav/.mp3 files into app/assets/sounds/ to replace the silent
/// placeholders. The service silently no-ops if a file fails to load or play,
/// so the game never crashes due to missing audio.
///
/// Call [SoundService.instance.init()] once in main() before runApp.
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  bool _ready = false;

  // One dedicated player per sound type keeps them independent.
  // Shoot uses a tiny round-robin pool so rapid fire doesn't cut itself off.
  final List<AudioPlayer> _shootPool = List.generate(4, (_) => AudioPlayer());
  int _shootIndex = 0;
  final AudioPlayer _hitPlayer = AudioPlayer();
  final AudioPlayer _leakPlayer = AudioPlayer();
  final AudioPlayer _waveClearPlayer = AudioPlayer();
  final AudioPlayer _winPlayer = AudioPlayer();
  final AudioPlayer _losePlayer = AudioPlayer();

  Future<void> init() async {
    try {
      // Pre-warm the shoot pool so the first shot has no latency.
      for (final p in _shootPool) {
        await p.setSource(AssetSource('sounds/shoot.wav'));
        await p.setReleaseMode(ReleaseMode.release);
      }
      await _hitPlayer.setReleaseMode(ReleaseMode.release);
      await _leakPlayer.setReleaseMode(ReleaseMode.release);
      await _waveClearPlayer.setReleaseMode(ReleaseMode.release);
      await _winPlayer.setReleaseMode(ReleaseMode.release);
      await _losePlayer.setReleaseMode(ReleaseMode.release);
      _ready = true;
    } catch (_) {
      // Audio not available on this platform/build — silently disabled.
    }
  }

  void playShoot() {
    if (!_ready) return;
    try {
      _shootPool[_shootIndex].play(AssetSource('sounds/shoot.wav'));
      _shootIndex = (_shootIndex + 1) % _shootPool.length;
    } catch (_) {}
  }

  void playHit() => _play(_hitPlayer, 'sounds/hit.wav');
  void playLeak() => _play(_leakPlayer, 'sounds/leak.wav');
  void playWaveClear() => _play(_waveClearPlayer, 'sounds/wave_clear.wav');
  void playWin() => _play(_winPlayer, 'sounds/win.wav');
  void playLose() => _play(_losePlayer, 'sounds/lose.wav');

  void _play(AudioPlayer player, String asset) {
    if (!_ready) return;
    try {
      player.play(AssetSource(asset));
    } catch (_) {}
  }
}
