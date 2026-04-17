# QA Checklist: Mini Tower Defense

## Manual functional checks
- App launches to home screen
- Start Run opens battlefield
- Path and build pads are visible
- Landscape orientation is enforced
- Player can place a tower only if enough gold exists
- Gold decreases correctly on build
- Occupied pad cannot be reused
- Towers fire automatically when enemies are in range
- Enemies follow the path correctly
- Leaked enemies reduce lives
- Killed enemies award gold
- Wave counter increases correctly
- Victory screen appears after clearing wave 10
- Lose screen appears when lives reach 0
- Best wave saves across restarts

## Edge cases
- Building with exact remaining gold
- Projectile impact after target already died
- Splash damage when enemies overlap
- Frost slow reapplies before previous slow expires
- Final enemy of final wave dies and victory triggers correctly
- Restart from win/loss resets all run state

## Automated checks
Run:
```bash
cd app
flutter analyze
flutter test
```

## Performance sanity
- Battlefield runs smoothly on a physical device
- No runaway projectile or enemy accumulation
- No obvious memory leak from removed components

## Release blockers for MVP
Any of these block completion:
- towers stop firing randomly
- enemies get stuck on path
- lives or gold desync from gameplay
- win/loss flow breaks
