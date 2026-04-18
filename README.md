# Mini Tower Defense

A polished, offline tower defense game built with Flutter + Flame. Designed for Play Store / App Store release.

---

## Folder structure

```
Mini Tower Defense/          ← repo root
├── app/                     ← Flutter project (all source code lives here)
│   ├── android/             ← Android platform files
│   ├── macos/               ← macOS platform files (local testing only)
│   ├── web/                 ← Web platform files (Chrome dev testing only)
│   ├── assets/
│   │   ├── images/sprites/  ← 7 sprite sheets (1024×128 PNG, 8 frames each)
│   │   └── sounds/          ← SFX files
│   ├── lib/
│   │   ├── game/            ← All Flame game logic
│   │   │   ├── components/  ← Enemy, Tower, Projectile, BuildPad, HUD bridge
│   │   │   ├── config/      ← Level definitions, game constants
│   │   │   ├── models/      ← LevelData
│   │   │   └── systems/     ← WaveManager, SoundService, DebugOverlay
│   │   └── features/
│   │       ├── home/        ← HomeScreen + GameScreen (Flutter HUD overlays)
│   │       ├── results/     ← ResultScreen (game-over / victory)
│   │       └── storage/     ← SaveService (best wave via shared_preferences)
│   ├── test/                ← Unit and widget tests
│   └── pubspec.yaml
├── render_sprites.py        ← Blender headless script — regenerates sprite sheets
├── KayKit_Skeletons_1.1_FREE/   ← 3D enemy GLB assets (not committed to LFS)
├── KayKit_Adventurers_2.0_FREE/ ← 3D tower GLB assets (not committed to LFS)
├── PRD.md                   ← Product requirements
├── TECHNICAL_DESIGN.md      ← Architecture decisions
├── IMPLEMENTATION_PLAN.md   ← Phase breakdown
├── QA_CHECKLIST.md          ← Quality gates per milestone
└── AGENTS.md                ← Instructions for AI coding agents
```

> **Why `app/`?** The repo root holds design docs and the 3D-to-sprite pipeline alongside the Flutter project. Keeping Flutter under `app/` keeps them separate. All Flutter commands must be run from inside `app/`.

---

## Prerequisites

| Tool | Version | Notes |
|---|---|---|
| Flutter SDK | 3.x stable | `flutter --version` to verify |
| Dart SDK | bundled with Flutter | |
| Android Studio | latest | For Android SDK, emulator, and signing |
| Android SDK | API 33+ (target), API 21+ (min) | Install via Android Studio SDK Manager |
| Java / JDK | 17 | Required by Gradle |
| Blender | 5.1+ | Only needed to regenerate sprite sheets |

---

## Running locally

All commands run from the `app/` directory.

```bash
cd app
```

### Chrome (fastest iteration)
```bash
flutter run -d chrome
```

### Android device / emulator
```bash
# List available devices
flutter devices

# Run on a connected device or emulator
flutter run -d <device-id>
```

### macOS (desktop, for quick local testing)
```bash
flutter run -d macos
```

---

## Building for Android

### Debug APK (no signing needed)
```bash
cd app
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK (requires signing)

**1. Create a keystore** (one-time setup):
```bash
keytool -genkey -v \
  -keystore ~/my-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias my-key-alias
```

**2. Create `app/android/key.properties`** (never commit this file):
```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=my-key-alias
storeFile=<absolute-path-to>/my-release-key.jks
```

**3. Build:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Or build an App Bundle for Play Store submission:
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

**4. Install directly on a connected device:**
```bash
flutter install
```

---

## Running tests

```bash
cd app
flutter analyze   # static analysis — must be clean before any commit
flutter test      # unit + widget tests
```

---

## Sprite pipeline (Blender)

Sprite sheets are pre-rendered and committed. Only re-run this if you change a 3D model or animation.

**Requirements:** Blender 5.1+ installed, KayKit GLB assets present at repo root.

```bash
# From repo root (not app/)
blender --background --python render_sprites.py
```

Output PNGs land in `sprites_out/`. Copy them to `app/assets/images/sprites/` to update the game.

Each sheet is 1024×128 px — 8 frames of 128×128 for a single walk/idle cycle.

---

## Game overview

| | |
|---|---|
| Engine | Flutter 3 + Flame 1.x |
| Viewport | 1280 × 720 logical pixels (fixed resolution camera) |
| Levels | 3 handcrafted maps with unique paths and difficulty multipliers |
| Towers | Dart · Cannon (AoE) · Frost (slow) · Booster (attack-speed aura) |
| Enemies | Scout · Swarm · Tank |
| Waves | 10 scripted waves per level → endless mode after wave 10 |
| Upgrades | Up to level 10 per tower; cost scales 1.8× per level |
| Persistence | Best wave per level stored locally via `shared_preferences` |
| Audio | SFX via `audioplayers`; no music |
| Ads / IAP / Login | None — fully offline |

### Tower costs and base stats

| Tower | Cost | Damage | Range | Cooldown | Special |
|---|---|---|---|---|---|
| Dart | 40g | 7 | 110 | 0.6s | — |
| Cannon | 70g | 16 | 125 | 1.4s | AoE splash r=32 |
| Frost | 60g | 6 | 100 | 0.8s | Slows 35% for 1.2s |
| Booster | 70g | — | 80 | — | +25% attack speed aura; range ×1.45 per upgrade |

### Build pad unlock schedule

| After wave | New pads |
|---|---|
| Wave 3 | +2 |
| Wave 6 | +2 |
| Wave 12, 20, 28 … 84 (every 8 waves) | +1 each (10 total) |

---

## Key source files

| File | Purpose |
|---|---|
| `app/lib/game/mini_td_game.dart` | `FlameGame` root — load, update, build/unlock towers |
| `app/lib/game/systems/wave_manager.dart` | Spawn loop, win/loss conditions, pad unlocks |
| `app/lib/game/components/enemy_component.dart` | Enemy base class + Scout / Tank / Swarm |
| `app/lib/game/components/tower_component.dart` | Tower base class + all four tower types |
| `app/lib/game/components/hud_bridge.dart` | `ValueNotifier` state shared between Flame and Flutter |
| `app/lib/game/config/levels.dart` | All 3 level definitions (waypoints, pads, waves) |
| `app/lib/features/home/home_screen.dart` | Flutter UI — HUD, overlays, tower-selection menu |
| `app/lib/features/results/result_screen.dart` | Victory / game-over screen with best-score display |
