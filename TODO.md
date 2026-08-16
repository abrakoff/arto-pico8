# Arto TODO

## Null Instruction

Support a "black" do-nothing instruction value in each of the 3 brain matrices (paint, feel, move), so Arto can be programmed to skip an action.

- [x] Add `null_idx` (black) as a valid instruction value (`color.lua`)
- [x] Recolor the matrix corner box to black; repurpose it from "fill all cells" into a "select null instruction" swatch (`brains.lua`)
- [x] Skip paint/feel/move when the null instruction is selected, instead of painting black / clearing memory / crashing on an out-of-range move (`bot.lua`)
- [x] Playtest all three matrices (paint, feel, move) with the null instruction selected
- [x] Visualize the null/dead feel state on Arto himself: eyes wipe to solid white, drawn dynamically over the sprite rather than baked into sprite memory (`draw_dead_eyes` in `bot.lua`, wired into the portrait, the scale-8 map sprite, and the scale-4 map sprite; the scale-2 map sprite is only 2x2 pixels total, too small for a face)
- [x] Stop the step/turn bouncing animation and swap in a "flatline" sound effect when Arto is feeling null (`update_level` in `levels.lua` stops re-triggering `standing_robot_phaser` once dead; `bot.lua` fires a new one-shot `sfx9` "flatline" tone on the death transition)

## Tutorial Rework

Rebuild the first levels to unlock instruction types incrementally for a smoother onboarding experience.

- [x] Reorder the brain matrices to move, paint, feel left to right, so move (unlocked first) reads leftmost (`brains.lua`)
- [x] Lock paint and feel initially; only move is unlocked in level 1 — lock sprite overlay, clicks disabled, selector square hidden (`brains.lua`, `mouse.lua`)
- [x] Grey out and disable the next-level control until the current level's flag is reached; unlocks via `level.completed_now`, resets locked on every fresh visit to a level (`draw_next_level_button`/`next_level_locked` in `controls.lua`)
- [ ] Require the player to beat level 1 before unlocking the next instruction type (paint/feel) more generally — currently level 1's lock is hardcoded, not yet a general progressive-unlock system
- [ ] Design the unlock progression for the rest of the early levels

## Cosmetic

- [x] Give Arto a moustache (sprite edit, commit `d55d12b`)
- [x] Fix the level-complete smile animation, which was missing the moustache — redrew the two overlapping rows of the smile overlay sprite (112,8) to include it
