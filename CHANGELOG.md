# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to Semantic Versioning scaled down for prototyping:
`MAJOR.MINOR.PATCH.FEATURE` (e.g. 0.0.1.0)

## [v1.1.0.0] - 2026-04-18
### Added
- **Kill particle burst**: enemies explode into 8 coloured sparks on death matching their type (red Scout, orange Tank, yellow Swarm) via new `DeathEffect` component.
- **Progressive pad unlock**: maps start with 8 build pads; 2 more unlock after wave 3 and another 2 after wave 6, reaching a max of 12 pads per map.
- **Difficulty scaling 1.25×/map**: `LevelData.difficultyMultiplier` — L1=1.0, L2=1.25, L3=1.56 — multiplies every enemy's HP and speed at spawn time.
- **Per-map upgrade tiers**: `LevelData.maxTowerLevel` — L1=2, L2=3, L3=4 — caps tower upgrade levels per battlefield. Upgrade button shows **MAX LEVEL** when cap is reached.
- **Level 1 pad layout rework**: removed the unreachable pad near (450,150); added a dedicated center-bottom Booster pad at (600,620); placed 4 wave-unlock positions for pads 9–12.
- **Sub-agent design review instruction** added to `CLAUDE.md` — future non-trivial features must pass a Plan-agent review before coding starts.

### Changed
- `LevelData` gains three optional fields: `initialPadCount`, `difficultyMultiplier`, `maxTowerLevel`.
- `WaveManager` now passes `levelData.difficultyMultiplier` as the base stat multiplier to all enemy spawns (was always 1.0).
- Level 3 pad positions adjusted: y=400 pads shifted to y=380 to sit further above the y=450 path.

## [v1.0.0.1] - 2026-04-17
### Fixed
- **EnemyComponent spawn crash**: Constructor accessed `game` (via `HasGameReference`) before mount. Moved `position = waypoints[0]` init to `onLoad()` so `game` is guaranteed available.
- **MiniTdGame load order**: `super.onLoad()` was called without `await`, risking camera/viewport not ready when components were added. Now properly awaited.
- **Win condition missing**: `WaveManager` never triggered `triggerGameOver(win: true)` — runs continued as endless after wave 10. Win now fires correctly when the last defined wave is cleared.
- **Level 3 broken waypoints**: Path looped through `(640,360)` twice causing enemy teleport. Replaced with the intended snake: `(640,0)→(640,150)→(200,150)→(200,450)→(1080,450)→(1080,720)`.

## [v1.0.0.0] - 2026-04-17
### Added
- **Level Selection Map**: 3 unique grids (Green Lanes, Desert Pass, Ice Gorge) with dynamic data-driven loading.
- **Booster Support Towers**: Non-attacking towers that project buff auras (+25% Attack Speed) on nearby allied structures.
- **Endless Mode Engine**: Refactor WaveManager to infinitely scale Enemy maxHP/speed on an exponential curve after Wave 10.
- **Per-Level Persistence**: Best wave reached is now saved and displayed individually per battlefield.

## [v0.0.1.0] - 2026-04-17
### Added
- Line of sight range circle visuals for tower placement.
- Added visual Frost impacts to slowing mechanics (blue tint).
- High performance GUI component red/green dynamic HP bars directly over enemies.
- Upgrades Leveling mechanics implementation mapping gold to component stats.
- Tower tap interactions displaying tooltips natively inside the Flutter UI overlay.
- Dynamic 1X/2X game speed multiplier scale functionality.
- Initialized versioning tracker payload.

## [v0.0.0.1] - MVP
### Added
- Flame Engine rendering with 1280x720 logic.
- HUD Notifier bridge sharing Gold, Lives, and score.
- Waves 1-10 Enemy Spawner.
- Shared_preferences high-score storage.
- Basic pathfinding waypoints for: Scout, Swarm, and Tank enemies.
- Basic projectile impacts for: Dart, Splash Cannon, and Slowing Frost.
