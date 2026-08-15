# Arto TODO

## Null Instruction

Support a "black" do-nothing instruction value in each of the 3 brain matrices (paint, feel, move), so Arto can be programmed to skip an action.

- [x] Add `null_idx` (black) as a valid instruction value (`color.lua`)
- [x] Recolor the matrix corner box to black; repurpose it from "fill all cells" into a "select null instruction" swatch (`brains.lua`)
- [x] Skip paint/feel/move when the null instruction is selected, instead of painting black / clearing memory / crashing on an out-of-range move (`bot.lua`)
- [ ] Playtest all three matrices (paint, feel, move) with the null instruction selected
- [ ] Decide whether the null instruction needs any UI treatment in the tutorial screen (`brain[4]`, the tutorial-only brain)

## Tutorial Rework

Rebuild the first levels to unlock instruction types incrementally for a smoother onboarding experience.

- [ ] Lock paint and feel initially; only move is unlocked in tutorial level 1
- [ ] Require the player to beat level 1 before unlocking the next instruction type
- [ ] Design the unlock progression for the rest of the early levels
- [ ] Update `levels.lua` / `tutorial.lua` to gate matrix editing by unlock state

## Cosmetic

- [x] Give Arto a moustache (sprite edit, commit `d55d12b`)
- [ ] Fix the level-complete smile animation, which is missing the moustache — see `draw_arto` in `bot.lua`, the `sspr(112,8,7,4,...)` overlay drawn when `level.completed_now`
