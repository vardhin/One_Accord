# Sword combat — animation clips to author

The combat **rig** (weapon attachment, draw/sheath, light combo, heavy, movement
locks, input wiring) is fully wired in [`scripts/player.gd`](../scripts/player.gd).
There is **no procedural motion** — the rig plays animation clips by name. Until a
clip exists, its state resolves instantly (sword toggles drawn/sheathed, attacks
flip straight back to ready) with no visible swing. Drop in the clips and they
just work.

## Workflow

1. Put your downloaded animations (e.g. Mixamo / Animux) in
   `assets/player/animations/combat/`.
2. Import each, then add its clip to the AnimationLibrary on
   `Player/Body/X_Bot/AnimationPlayer` (saved into
   `assets/player/player_anims.res`) under the **exact name** in the table below.
3. That's it — the code calls `_anim.has_animation(name)`; if the clip is present
   it plays and drives the state on `animation_finished`. No code changes.

## Required clip names

| Clip name | When it plays |
| --- | --- |
| `sword_unsheath` | Drawing the sword (R, or attacking from sheath) |
| `sword_sheath` | Putting the sword away (R) |
| `sword_light_1` | First light hit (LMB) |
| `sword_light_2` | Second light hit (LMB during a swing -> combo) |
| `sword_light_3` | Third / finisher light hit |
| `sword_heavy` | Heavy attack (RMB) |

### Locomotion variants (optional but recommended)

While the sword is **drawn** (state `READY`), the controller first looks for a
`sword_`-prefixed version of each locomotion clip and falls back to the unarmed
one if it's missing. Author these to get a proper combat stance/stride:

| Clip name | Falls back to |
| --- | --- |
| `sword_idle` | `idle` |
| `sword_walk` | `walk` |
| `sword_run` | `run` |

> Jump while armed currently uses the unarmed `jump` / `run_jump`. Add
> `sword_jump` / `sword_run_jump` and extend `_armed()` in `player.gd` if you
> want armed jump variants too.

## Authoring notes

- **Non-looping** for the action clips (`sword_unsheath/sheath/light_*/heavy`):
  the state advances on `animation_finished`, so a looping clip would never end.
  Set the track's loop mode to **None** (clamp).
- **Looping** for the locomotion variants (`sword_idle/walk/run`).
- The light combo chains `1 -> 2 -> 3` when you press LMB again *during* a swing
  (input is buffered). Pressing nothing returns to `READY`.

## Tuning (exported on the Player node, "Combat" group)

- `sword_grip_offset` / `sword_grip_rotation_deg` — fit the sword into the fist.
  The placeholder sword's blade points along **+Y**; default rotation lays it
  along the forearm. Adjust these first if the sword sticks out wrong.
- `attack_move_damp` — 0 roots you while an attack/draw clip plays; higher allows
  an ER-style step.

## Swapping the placeholder sword for a real model

The placeholder is [`scenes/sword.tscn`](../scenes/sword.tscn) (built in code by
[`scripts/sword.gd`](../scripts/sword.gd)). Point the Player's `sword_scene`
export at any scene whose root is a `Node3D` — the rig attaches it to the hand
bone regardless of its contents.
