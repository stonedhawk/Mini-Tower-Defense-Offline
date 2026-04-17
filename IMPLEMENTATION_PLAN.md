# Implementation Plan: Mini Tower Defense

## Milestone 1: Shell and static battlefield
### Goal
Set up the Flutter app, Flame game, fixed viewport, path, and build pads.

### Deliverables
- app shell in `/app`
- home screen
- `MiniTdGame`
- static map background
- visible path
- 8 build pads
- HUD overlay shell
- unit tests for config loading or targeting helpers if created this early

### Done when
- the battlefield loads with no enemies and no crash
- landscape orientation works

## Milestone 2: Enemy movement
### Goal
Spawn enemies and move them along the path.

### Deliverables
- waypoint path following
- enemy component base
- scout enemy
- leak handling
- lives counter update

### Done when
- enemies can traverse the path and reduce lives on leak

## Milestone 3: Tower placement and damage
### Goal
Let the player place towers and kill enemies.

### Deliverables
- build pad interaction
- tower selection UI
- dart tower
- projectile logic
- kill rewards
- basic gold spending rules

### Done when
- player can place a Dart Tower and kill Scouts

## Milestone 4: Full content set
### Goal
Finish MVP gameplay content.

### Deliverables
- cannon tower
- frost tower
- tank and swarm enemies
- wave list 1 to 10
- win/loss screens
- restart flow

### Done when
- a complete run is playable offline

## Milestone 5: Persistence and cleanup
### Goal
Finish polish without growing scope.

### Deliverables
- save best wave
- improve HUD readability
- tests for wave/economy logic
- remove dead code

## Scope guardrails
Reject any task that adds:
- tower upgrades
- freeform placement
- more maps
- endless mode
- meta progression
