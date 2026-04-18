# Claude instructions for this project

Read these files in order before coding:
1. `PRD.md`
2. `TECHNICAL_DESIGN.md`
3. `IMPLEMENTATION_PLAN.md`
4. `QA_CHECKLIST.md`

## Non-negotiables
- Keep the actual Flutter code in `/app`
- Use Android only
- Stay inside MVP scope
- Keep code beginner-friendly and heavily named, not overly abstract
- Use placeholder visuals only
- Do not introduce backend, analytics, ads, multiplayer, login, or IAP
- Run `flutter analyze` and `flutter test` after each milestone
- Stop and report after the requested milestone instead of expanding scope

## Working style
- Prefer small files and feature-based folders
- Prefer pure Dart logic for rules and tests
- Keep UI simple first, polish second
- When a design choice is ambiguous, choose the simpler option that preserves the PRD
- If you want to add a dependency not already approved, justify it first in one sentence and wait for approval

## Output style
When you finish a milestone:
- list files added or changed
- list commands run
- list tests added or updated
- list known gaps against the current milestone

## Design and plan validation
Before writing any code for a non-trivial feature:
1. Draft the design in text (data model changes, affected files, data flow).
2. Spawn a sub-agent using `subagent_type: "Plan"` and pass it the full design draft.
   - Brief it as a senior Flutter/Flame developer doing a code review.
   - Ask it to flag architecture issues, missing edge cases, and simpler alternatives.
3. Incorporate its feedback before touching any source file.

This applies whenever:
- a new component or system is introduced
- existing data models are changed
- more than two files need to change in concert
- a feature involves async, game-loop timing, or Flame lifecycle
