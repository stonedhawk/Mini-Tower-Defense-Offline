# PRD: Mini Tower Defense

## 1. Product summary
Mini Tower Defense is a compact offline tower defense game for Android built to teach real-time game-loop concepts without exploding scope.

This project should be the first real-time game in the sequence. It is intentionally constrained to:
- one map
- one path
- three tower types
- ten waves
- no upgrades
- no branching path logic

## 2. Product goals
- Learn the basics of a game loop using Flame
- Learn entity/component thinking
- Learn wave spawning, targeting, projectile logic, and HUD overlays
- Ship a small but complete offline tower defense game

## 3. Target player
- Casual mobile player
- Session length: 5 to 8 minutes
- Wants easy-to-read lane defense, not deep strategy

## 4. Design pillars
- **One map, done well**
- **Readable battlefield**
- **Real-time but simple**
- **No system bloat**

## 5. MVP scope
### Included
- Android only
- Offline only
- One fixed map
- One fixed enemy path
- Three tower types
- Three enemy types
- Ten waves
- Gold economy
- Life total
- Win screen
- Lose screen
- Best wave reached saved locally

### Excluded
- Tower upgrades
- Selling towers
- Multiple maps
- Endless mode
- Procedural generation
- Bosses
- Multiple paths
- Meta progression
- Ads
- Analytics
- Audio system
- Backend
- Multiplayer

## 6. Core gameplay loop
1. Player starts a run.
2. Player sees the map, path, build pads, starting gold, and lives.
3. Player places towers on predefined pads.
4. Wave starts automatically or with a Start Wave button.
5. Enemies move along the path toward the exit.
6. Towers target enemies in range and fire automatically.
7. Killed enemies award gold.
8. Leaked enemies reduce lives.
9. Player survives until wave 10 clears to win.
10. If lives reach 0, game over.

## 7. Exact rule set for MVP
### Starting resources
- Gold: 120
- Lives: 10
- Current wave: 1

### Towers
#### Dart Tower
- Cost: 40
- Range: 110
- Damage: 7
- Cooldown: 0.6 seconds
- Projectile speed: 280
- Role: cheap single-target DPS

#### Cannon Tower
- Cost: 70
- Range: 125
- Damage: 14
- Splash radius: 32
- Cooldown: 1.4 seconds
- Projectile speed: 220
- Role: slow splash damage

#### Frost Tower
- Cost: 60
- Range: 100
- Damage: 4
- Cooldown: 0.8 seconds
- Slow: 35%
- Slow duration: 1.2 seconds
- Projectile speed: 260
- Role: crowd control

### Enemy types
#### Scout
- HP: 18
- Speed: 42
- Gold reward: 8
- Leak damage: 1

#### Tank
- HP: 48
- Speed: 24
- Gold reward: 16
- Leak damage: 1

#### Swarm
- HP: 10
- Speed: 55
- Gold reward: 5
- Leak damage: 1

### Targeting rule
All towers target the in-range enemy closest to the exit.

### Economy rule
- Gain listed gold reward on kill
- Gain wave clear bonus of 20 gold after each fully cleared wave

### Wave list
1. 8 Scouts
2. 10 Scouts
3. 8 Scouts + 2 Tanks
4. 6 Scouts + 6 Swarms
5. 10 Scouts + 4 Tanks
6. 12 Swarms + 4 Scouts + 2 Tanks
7. 8 Scouts + 8 Swarms + 4 Tanks
8. 6 Tanks + 10 Swarms
9. 14 Scouts + 6 Tanks
10. 10 Scouts + 10 Swarms + 8 Tanks

### Spawn pacing
- Default spawn interval: 0.7 seconds
- It is acceptable to vary interval slightly by wave later, but not required for MVP

## 8. Map design
### Rules
- One fixed path
- One screen only
- Use predefined build pads
- No drag-to-place freeform towers in MVP

### Build pads
Use exactly 8 tower pads for the first version.

### Visual style
- Landscape orientation
- Simple geometric visuals
- Path should be obvious at first glance
- No custom sprite pipeline required

## 9. UI and UX
### On-screen HUD
- current gold
- current lives
- current wave
- pause or restart button

### Interaction
- Tap a build pad
- Show simple tower choice panel or bottom sheet
- Build one tower if enough gold
- Occupied pads cannot be reused

### End states
- Lose screen when lives reach 0
- Victory screen when wave 10 fully clears

## 10. Success criteria
The MVP is successful if:
- a player understands how to place towers without external help
- the game runs on a phone without obvious stutter
- a full run can be played start to finish offline
- there is meaningful difference between the three tower types
- the game stays inside one-map scope

## 11. Risks and anti-goals
### Main risk
Accidentally building a content-heavy strategy game instead of a tiny learning project.

### Anti-goals
Do not add:
- upgrade trees
- sell/refund systems
- boss mechanics
- status effect stacks beyond Frost slow
- map editor
- pathfinding around tower placement
- procedural waves
