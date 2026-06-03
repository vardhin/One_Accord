# 03 — Assets & Animation: Where the 3D Content Comes From

> The honest answer to the real fear: *"I'm a systems dev. I can't model or animate.
> Where do walk/sprint/attack animations, character meshes, mountains, trees, and grass
> actually come from?"* This doc separates the two cost centers people conflate, and
> assigns every asset class to a **source** so no part of the world depends on the dev
> becoming a 3D artist.

## The one distinction that dissolves the fear

There are **two completely separate costs** in 3D, and the panic comes from confusing
them:

| | Cost A: the *tech to play/render* content | Cost B: the *content itself* |
| --- | --- | --- |
| Examples | skeletal animation playback, blend trees, glTF import, mesh rendering, terrain, instanced grass, culling | the actual hero mesh, the actual walk/run/attack clips, the actual tree model |
| Who pays it | **Godot pays it. Free.** (`02-engine-evaluation.md` — this is the whole reason to use an engine.) | **You source it.** This is where solo 3D projects actually die — on *asset labor*, never on the shader math. |

The dev's instinct was right but mis-aimed: the danger was never "can the engine
sprint-animate a character" (yes, trivially — you hand it an animated model and call
`play("sprint")`). The danger is **"where does a sprint animation come from."** This
doc answers Cost B for every asset class, because Cost A is already solved by choosing
Godot.

> **The strategy in one line:** *characters are bought + retargeted (you never animate
> a humanoid by hand); the world is procedural + instanced (the math/shader lane you
> love); only a handful of hero props are hand-made.* You stay almost entirely out of
> modeling/animation craft and almost entirely in systems/shader craft.

## Characters — bought realistic-ish + Mixamo retargeting

**Decision (committed):** **realistic-ish bought character meshes, animated by
retargeting free Mixamo clips in Godot.** This serves the DS1 register
(`00-tech-thesis.md`) — grounded, grim, not stylized-cartoon — and it means **zero
hand-animation of humanoids** and **near-zero character modeling.**

### Where the meshes come from

- **Asset stores for game-ready, realistic-ish humanoids** — marketplaces sell rigged,
  game-ready characters in the grounded/realistic register (survivors, soldiers,
  ragged figures) that suit One Accord's post-collapse cast. You buy a base set of
  body types and re-skin/re-texture variants from them.
- **Reuse aggressively.** The world has **~40 named NPCs (a hard cap)** and most former
  human places are *empty* (`../Documentation/OVERVIEW.md`). That cap is a gift: you
  need a *small* number of distinct character meshes, dressed and palette-shifted into
  variety, not hundreds. Husks especially can share a few base meshes with shader-driven
  decay/possession variation (`05-rendering-and-shaders.md`).

### Where the animations come from — the Mixamo pipeline

This is the load-bearing answer to "walking, sprinting, attacks":

1. **Mixamo** (free, Adobe account) provides a large library of humanoid clips: idle,
   walk, run, sprint, strafe, turn, jump, dodge/roll, multiple sword/melee attacks,
   hit-reactions, blocks, parries, staggers, deaths. You **pick** them; you don't make
   them.
2. **Godot 4 retargets** between skeletons. Mixamo rigs and most bought characters use
   humanoid skeletons; Godot's animation retargeting maps a Mixamo clip onto your
   bought character's skeleton. So one animation library drives *all* your humanoids.
3. **Godot's `AnimationTree` + state machine** blends them at runtime: idle↔walk↔run↔
   sprint by speed, attack states, hit-react interrupts, dodge. **This blend graph —
   not the clips — is the part you author**, and it's logic/graph work, not artistry.
4. **Root motion vs. in-place** is a knob Godot exposes; for a Soulslike you'll mostly
   want **in-place locomotion driven by sim velocity** (the sim owns movement —
   `01-architecture.md`) and **root-motion or curve-driven lunges for attacks** so
   attack animations move the body the way the combat sim expects (`06-combat-feel.md`).

**Net:** your entire locomotion set + basic combat moveset can be free Mixamo clips on
bought meshes, with your effort going into the *blend graph* and *how animation events
feed the combat sim* — both squarely systems work, not animation craft.

### The honest cost of choosing "realistic-ish" (the tension to manage)

Realistic-ish characters are **heavier on the Vega 8** than stylized low-poly — more
triangles, bigger textures, more material cost. This pulls against `00-tech-thesis.md`'s
budget, so choosing this look **commits you to discipline elsewhere**, not to spending
the GPU you don't have:

- **LODs are mandatory, not optional.** Godot auto-generates mesh LODs; distant NPCs
  drop to cheap versions. With a thin, mostly-empty world this is very effective.
- **Texture atlasing + shared materials.** Fewer, shared materials → fewer draw calls
  → the iGPU's friend. Batch the cast onto shared atlases.
- **Few on screen at once.** The world is *designed* sparse (~200 ever seen, thin
  settlements). You rarely render a crowd, so realistic-ish meshes stay affordable.
- **Keep texture *resolution* sane.** "Realistic-ish" means grounded silhouettes and
  good normal/roughness — **not** 4K textures. DS1 itself used modest textures; fog and
  lighting did the work. Mid-res textures + good lighting reads as DS1; 4K everywhere
  reads as a stutter.
- **Fog hides LOD pops and draw distance** (`00`/`04`) — the same fog that makes the
  mood also makes the realistic-ish cast cheap to render at distance.

> **Rule:** realistic-ish is a *silhouette and material* target, not a *polygon and
> texture-resolution* target. Buy the grounded look; spend the budget on lighting and
> fog, not on triangle counts. This is exactly how DS1 looked expensive while being
> cheap.

## The world — procedural + instanced (your lane)

Mountains, terrain, grass, trees scale **terribly by hand** and **beautifully by
math/shader** — which is precisely the dev's strength. The world is where you get to be
yourself.

### Terrain & mountains — heightfields, not sculpting

- You **do not model a mountain.** You drive a **heightmap-based terrain** (a Godot
  terrain plugin, or — very much in the dev's wheelhouse — a custom heightfield mesh
  generated in the Rust sim/tools layer). A mountain is a region of a height function;
  shading + fog make it read as a peak.
- DS1's environments were largely **authored hand-placed geometry** rather than vast
  procedural terrain — and One Accord is **a handful of dense authored regions, not an
  open world** (`../Documentation/Regions/world-structure.md`). So terrain is **bounded
  per region**, not a planet. You can hand-author region *layout* (greyboxing in Godot)
  and use heightfields + scatter for the natural parts.

### Grass — GPU instancing / multimesh + shader (pure math/shader)

- Grass is **never individual placed meshes.** It's GPU-instanced blades
  (`MultiMesh`) or a grass *shader* spawning geometry on the terrain, often animated by
  a wind function in the vertex shader. This is **exactly the hand-written shader/math
  work the dev wants to do.**
- **It is also the #1 Vega-8 overdraw risk** (`00-tech-thesis.md`): dense alpha-blended
  grass re-shades pixels brutally. So grass is budgeted as overdraw, kept to a short
  radius around the camera (fade into fog), and uses alpha-*scissor*/dither rather than
  full alpha-blend where possible. This is a designed spike in `08-render-derisk-plan.md`.

### Trees, rocks, props — scatter pre-made meshes

- **One tree mesh, instanced hundreds of times** (scattered on the terrain) is how
  forests are made — not hundreds of unique trees. A small kit of tree/rock/prop meshes
  (bought, or generated) scattered with variation in rotation/scale gives a full world.
- **Tree/plant generators** (parametric tools that output a mesh from sliders) cover the
  case where you want bespoke flora without sculpting — you tune parameters, the tool
  builds the mesh.
- Scattering can be **hand-painted** in Godot (scatter/foliage plugins) or
  **procedural** (your own Poisson-disk/noise placement in the tools layer — again, the
  dev's lane).

### Buildings & settlements — modular kit + greyboxing

- Settlements (the Goodsprings-scale starter, `../Documentation/Production/vertical-slice-spec.md`)
  are built from a **modular kit**: walls, doors, roofs, fences, posts — a small set of
  bought/made pieces snapped together. This is how grounded environments are built at
  solo scale, and it suits the documented building-vocabulary approach.
- You **greybox** the layout first (primitive boxes in Godot) so the *space* and the
  *sim* are right before any art exists — and because the sim is authoritative, the
  greybox is fully playable (`01-architecture.md`).

## Hero assets — the only things you hand-make (or commission)

A short list of assets that are *uniquely One Accord* and can't be bought generic:

- **The rusty Soul Sword** — the player's only true weapon, an identity-loaded object
  that reforms across its mass-gated forms (dagger→…→greatsword,
  `../Documentation/Glyphs/glyph-system.md`). Hero prop; hand-made or commissioned.
- **The sword-girl's soul-body** — the playable body in soul duels, which *reshapes by
  relationship state* (`../Documentation/Sword/soul-duels.md`,
  `07-soul-duel-tech.md`). Hero character; the one place bespoke modeling really earns
  it (and where shader-driven variation does a lot of the "reshaping" work cheaply).
- **A signature husk/active silhouette or two**, and **key bosses** (the endgame
  Hivemind). These define enemy identity and deserve bespoke work.

Everything else is bought + retargeted + instanced. The hand-made list is **small and
hero-only** — a weekend of Blender-learning for a few objects, or a small commission
budget, not a modeling career.

## Source-of-truth table (every asset class → where it comes from)

| Asset class | Source | Dev effort | Notes |
| --- | --- | --- | --- |
| Player / NPC / husk meshes | **Bought** (realistic-ish, game-ready) | re-skin/variant only | ~40-NPC cap + empty world = small set, heavily reused |
| Humanoid animations (walk/run/sprint/dodge/attack/hit/death) | **Mixamo (free)** → Godot retarget | author the **blend graph**, not the clips | one library drives all humanoids |
| Animation blend / state machine | **You, in Godot** | logic/graph work | feeds combat sim — `06-combat-feel.md` |
| Terrain / mountains | **Heightfield** (plugin or custom tools-layer gen) | math/shader (your lane) | bounded per authored region, not open world |
| Grass | **MultiMesh / grass shader** | hand-written shader (your lane) | top overdraw risk — `07` spike |
| Trees / rocks / props | **Bought/generated kit, instanced & scattered** | scatter setup | one mesh × many instances |
| Buildings / settlements | **Modular kit, greyboxed first** | layout/greybox | sim-playable before art exists |
| The rusty sword | **Hand-made / commissioned** | hero asset | reforms across forms |
| Sword-girl soul-body | **Hand-made / commissioned** | hero asset | reshaped by relationship + shaders |
| Key bosses / signature husks | **Hand-made / commissioned** | hero asset | enemy identity |
| Glyph / possession / soul VFX | **Hand-written shaders + particles** | your lane | `05-rendering-and-shaders.md` |

## What this means for the build order

- **You can greybox and play the whole vertical slice with placeholder/bought assets
  before any hero art exists** — because the sim is authoritative and locomotion is
  bought Mixamo. Art is a *skin* applied to a working game, not a prerequisite for it.
- **The first content spike** (`08-render-derisk-plan.md`) is exactly:
  *a bought character + Mixamo locomotion + a hand-written toon/atmosphere shader + an
  instanced-grass overdraw test, all on the Vega 8.* That single spike validates the
  entire character+world+shader pipeline of this doc against the budget of `00`.

## Open / to-decide

- Which specific asset store(s) for the realistic-ish cast (license terms must allow
  commercial shipping — verify before buying).
- Mixamo licensing for a shipped commercial game vs. baking the clips into the project
  (check current Adobe terms; have a fallback animation source noted in case).
- Whether terrain is a Godot plugin vs. a custom heightfield generated in the Rust
  tools layer (leaning custom for the natural-terrain regions, plugin/greybox for
  authored ones — decide after the spike).
- Texture budget per character (resolution cap) to hold the realistic-ish look inside
  the Vega 8 budget — set a hard number after the first character renders on-device.

## Related

- `00-tech-thesis.md` — the Vega 8 budget that "realistic-ish" must be disciplined to.
- `02-engine-evaluation.md` — why Godot pays Cost A (the playback/render tech) for free.
- `05-rendering-and-shaders.md` — the shaders that make bought meshes read as DS1 and
  do the husk/possession/soul variation cheaply.
- `06-combat-feel.md` — how Mixamo attack clips feed the authoritative combat sim.
- `07-soul-duel-tech.md` — the sword-girl hero body and its relationship-driven reshape.
- `08-render-derisk-plan.md` — the spike that validates this whole pipeline on-device.
