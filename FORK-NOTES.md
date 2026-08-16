# Fork Notes

A running tally of what's changed in this fork relative to [tcfraser/arto-pico8](https://github.com/tcfraser/arto-pico8) (upstream), organized by feature rather than by commit. See [TODO.md](TODO.md) for what's still in progress or planned.

## Cosmetic

- Gave Arto a moustache.
- Fixed a regression from that same edit that had accidentally erased part of the "R" in the splash screen's ARTO logo.
- The level-complete smile overlay now includes the moustache instead of erasing it (it's drawn on the same rows).
- Added an architecture diagram of the game's Turing-machine mechanics to `docs/`.

## Null Instruction

Added a "black"/no-op instruction value usable in each of the 3 brain matrices (paint, feel, move), so Arto can be programmed to skip an action:

- The corner swatch on each matrix, which used to fill the whole matrix with the current paint color, now selects the null instruction instead.
- Paint and move: a null instruction is simply skipped — no paint, no move.
- Feel: a null instruction permanently kills the robot instead of being skipped, since `mem` no longer indexes valid brain data afterward. This required guarding `get_brain` so the resulting out-of-range reads degrade gracefully instead of crashing.
- Death is visible and audible: Arto's eyes wipe to solid white (portrait and the two largest map sprite sizes), the idle bounce/beep animation freezes, and a one-shot "flatline" tone plays.

## Tutorial Rework (in progress, on this branch)

Reworking the first few levels to unlock mechanics incrementally instead of exposing everything at once:

- Brain matrices reordered to move / paint / feel (left to right), so the first-unlocked mechanic (move) reads leftmost.
- A `level_brain_locks` table (level index → list of locked brain numbers) drives both click-disabling and a lock-icon overlay per brain. The active-cell selector still shows through a locked brain, just drawn 1px smaller.
  - Level 1: paint and feel locked, only move usable.
  - Level 2: feel still locked, paint unlocked.
  - Level 3: feel and move locked.
- The next-level control greys out and is unclickable until the current level's flag is reached, and re-locks on every fresh visit to a level.
- New mechanic: unlockable paint switches. Floor cells get a switch sprite overlaid on top (recolored per-switch via a palette swap), and all of a level's switches must be painted their target color before the flag counts as reached.
  - Level 2: one switch, red.
  - Level 3: five switches — orange, green, blue, dark red, orange.
- Levels 1–3 got hand-tuned starting brain states (mostly null/black, with one or two deliberately colored cells) to fit the new locked/puzzle design, replacing their original free-form values.
- Added per-brain corner icons: a paintbrush for paint, a heart for feel (move already had one).

## Dev tooling

- Installed [picotool](https://github.com/dansanderson/picotool) locally for potential build workflows — not currently wired into anything.
- `clear_cart_data()` is enabled on boot so every relaunch starts fresh at level 1 during testing. Must be disabled before shipping — tracked in `TODO.md`.
