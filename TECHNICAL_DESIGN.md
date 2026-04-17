# Technical Design: Mini Tower Defense

Checked against official setup docs on 2026-04-16.

## 1. Technical summary
Mini Tower Defense should use **Flutter + Flame**.

Reason:
- real-time loop
- moving entities
- projectiles
- timed wave spawning
- reusable game components

Keep the shell simple:
- Flutter for menus and overlays
- Flame for gameplay scene

## 2. Stack
- Flutter
- Dart
- Flame
- Android only
- `shared_preferences` for small local save data
- No backend
- No network
- No audio for MVP

## 3. Project layout
The generated Flutter app lives in `/app`.

Recommended structure inside `/app/lib`:
```text
lib/
  main.dart
  app/
    app.dart
    theme.dart
  features/
    home/
      home_screen.dart
    results/
      result_screen.dart
    storage/
      save_service.dart
  game/
    mini_td_game.dart
    config/
      game_constants.dart
      path_points.dart
      build_pads.dart
      waves.dart
    components/
      build_pad_component.dart
      enemy_component.dart
      tower_component.dart
      projectile_component.dart
      hud_bridge.dart
    systems/
      wave_manager.dart
      targeting.dart
      economy.dart
      collision_math.dart
```

## 4. Architecture
### Recommended split
- Flutter screens for:
  - home
  - results
  - overlays
- Flame `GameWidget` for the battlefield
- Pure Dart config files for:
  - waves
  - path
  - stats
  - targeting helpers

### Core classes
- `MiniTdGame extends FlameGame`
- `WaveManager`
- `EnemyComponent`
- `TowerComponent` base class
- `DartTowerComponent`
- `CannonTowerComponent`
- `FrostTowerComponent`
- `ProjectileComponent`
- `HudBridge` or `ValueNotifier` layer to expose gold/lives/wave to Flutter widgets

## 5. Coordinate system and viewport
- Landscape only
- Fixed logical battlefield resolution: `1280 x 720`
- Use a viewport strategy that preserves aspect ratio
- Keep all pads and path coordinates in logical pixels

## 6. Path and map implementation
Use a fixed list of waypoints in `path_points.dart`.
Do not implement dynamic pathfinding.

Enemy movement rules:
- move from waypoint to waypoint
- when final waypoint is reached, count as leak
- remove enemy from scene after leak

## 7. Combat implementation
### Tower targeting
Every tower:
- checks enemies in range
- chooses target closest to exit
- fires on cooldown

### Projectile handling
Keep it simple:
- projectile stores source, target reference, damage, speed
- projectile moves toward target
- if target dies before impact, projectile can still travel to last known position and expire
- no physics engine

### Splash handling
Cannon hit:
- damage main target
- damage other enemies within splash radius

### Slow handling
Frost hit:
- deal damage
- apply temporary movement speed multiplier of 0.65 for 1.2 seconds
- refresh duration on repeat hits

## 8. Persistence
Use `shared_preferences` for:
- `best_wave`
- `tutorial_seen` if needed later

Recommended keys:
```text
best_wave
tutorial_seen
```

Do not implement cloud save or mid-run save.

## 9. HUD and menus
Use Flutter overlays above the `GameWidget` for:
- gold
- lives
- wave
- restart
- optional pause

This is easier than forcing all UI into Flame.

## 10. Approved dependencies
Required:
```bash
flutter pub add shared_preferences
flutter pub add flame
```

Not approved for MVP:
- Flame Forge2D
- Firebase
- audio packages
- state-management packages
- pathfinding packages

## 11. Installation and environment setup

## Tooling and stack setup for this project

### Mandatory stack
- **Target platform:** Android only
- **App framework:** Flutter
- **Language:** Dart
- **IDE:** Android Studio
- **AI agents:** Claude Code and Codex CLI
- **Persistence:** `shared_preferences`
- **Backend:** none
- **Networking:** none

### 1. Install Android Studio
1. Download and install Android Studio.
2. Open it once and let the setup wizard install the Android SDK.
3. In Android Studio, install the Flutter plugin:
   - macOS menu bar -> Android Studio -> Settings
   - Plugins -> Marketplace
   - search for `flutter`
   - install it
   - accept Dart plugin installation
   - restart Android Studio

### 2. Install Xcode command-line tools on the Mac
Run:
```bash
xcode-select --install
```

### 3. Install Flutter SDK
1. Download the current stable Flutter SDK.
2. Extract it somewhere simple, for example:
```bash
$HOME/develop/flutter
```
3. Add Flutter to your `PATH` in `~/.zprofile`:
```bash
echo 'export PATH="$HOME/develop/flutter/bin:$PATH"' >> ~/.zprofile
```
4. Open a new terminal window and verify:
```bash
flutter --version
dart --version
```

### 4. Finish Android SDK setup for Flutter
Open Android Studio -> SDK Manager and verify:
- API Level 36 platform is installed
- Android SDK Build-Tools
- Android SDK Command-line Tools
- Android Emulator
- Android SDK Platform-Tools
- CMake
- NDK (Side by side)

Then accept licenses and validate setup:
```bash
flutter doctor --android-licenses
flutter doctor
flutter emulators
flutter devices
```

### 5. Prefer a physical Android device if your Mac struggles
If the emulator feels heavy, use a physical Android phone with USB debugging enabled. That is a valid Flutter workflow and often much smoother on a laptop with limited RAM.

### 6. Install Claude Code
Anthropic currently recommends the native install path:
```bash
curl -fsSL https://claude.ai/install.sh | bash
claude
```

Alternative if you already use Homebrew:
```bash
brew install --cask claude-code
claude
```

### 7. Install Codex CLI
Codex CLI needs `npm`, so install Node.js first if you do not already have it.

Then install Codex:
```bash
npm i -g @openai/codex
codex
```

### 8. Connect Flutter tools to Claude Code and Codex with MCP
The Dart and Flutter MCP server is optional but strongly recommended.

For Claude Code, from the project folder:
```bash
claude mcp add --transport stdio dart -- dart mcp-server
```

For Codex, from the project folder:
```bash
codex mcp add dart -- dart mcp-server --force-roots-fallback
```

### 9. Create the Flutter project inside `/app`
From this game folder:
```bash
flutter create app --platforms=android --org com.example.offlinegames
cd app
flutter pub add shared_preferences
```

If this game uses Flame, add Flame after project creation:
```bash
flutter pub add flame
```

### 10. Basic validation commands
Always run these after each milestone:
```bash
cd app
flutter analyze
flutter test
flutter run
```


For this project, after app creation:
```bash
cd app
flutter pub add shared_preferences
flutter pub add flame
```

## 12. Build and run commands
From the game folder:
```bash
flutter create app --platforms=android --org com.example.offlinegames
cd app
flutter pub add shared_preferences
flutter pub add flame
flutter analyze
flutter test
flutter run
```

## 13. Testing strategy
### Unit tests
Required:
- wave parsing / wave sequence
- tower targeting rule
- economy updates on kill and wave clear
- slow effect duration behavior
- leak handling

### Widget / integration smoke checks
- home screen renders
- `GameWidget` boots without crash
- result screen renders correct win/loss text

Flame-heavy behavior should still move as much math as possible into pure Dart helper functions.

## 14. Milestone implementation order
1. App shell and static battlefield
2. Enemy path movement and leak handling
3. Tower placement and targeting
4. Projectiles and damage
5. Full waves and win/loss flow
6. Persistence and polish

## 15. Refusal list for the agent
Do not add:
- multiple maps
- upgrade trees
- sell systems
- endless mode
- boss AI
- tower synergies
- procedural content

### Flame reference
- Flame install command: `flutter pub add flame`
- Flame uses `GameWidget` to host the game inside the Flutter widget tree


## Official references used for setup sections
- Flutter install overview: https://docs.flutter.dev/install
- Flutter Android setup: https://docs.flutter.dev/platform-integration/android/setup
- Flutter Android Studio plugin setup: https://docs.flutter.dev/tools/android-studio
- Flutter add to PATH: https://docs.flutter.dev/install/add-to-path
- Flutter manual install: https://docs.flutter.dev/install/manual
- Flutter Dart and Flutter MCP server: https://docs.flutter.dev/ai/mcp-server
- Android Studio install: https://developer.android.com/studio/install
- Claude Code quickstart: https://code.claude.com/docs/en/quickstart
- Claude Code advanced setup: https://code.claude.com/docs/en/setup
- Codex CLI: https://developers.openai.com/codex/cli
- Codex MCP: https://developers.openai.com/codex/mcp
- Flutter persistence cookbook: https://docs.flutter.dev/cookbook/persistence/key-value

- Flame documentation: https://docs.flame-engine.org/latest/
