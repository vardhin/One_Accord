# 04 — Open World & Streaming

> **Decision (committed 2026-06-03):** One Accord is a **true open world** — one
> continuous, seamless, streamed landmass with **no loading screens** between regions.
> Navigation is by **landmarks on the horizon, not a minimap.** This **revises** the
> "not a huge open world… Dark Souls structure" stance in
> `../Documentation/Regions/world-structure.md` (sync note added there). The regions,
> tiers, populations, and connectivity all survive — they become **dense
> points-of-interest on one map** rather than separately-loaded scenes.

## Why open world (the reasoning that won)

The choice is *design-driven*, not graphics-flex:

1. **Whole-world authoring view.** Building on one continuous landmass means the dev
   sees the entire world while placing things — no imagining how disconnected corridors
   stitch together. Architecture-by-sight.
2. **Landmark navigation, no minimap.** This is the load-bearing reason. Skyrim/BOTW
   navigate by **silhouette on the horizon** ("head toward the mountain with the
   tower"). That **requires** seeing distant cross-region geometry — which a
   loaded-zone graph fundamentally cannot do. The no-minimap pillar essentially
   *mandates* an open world. See "Landmark navigation" below.
3. **Legibility.** "Open world like Skyrim" is the genre frame most players understand
   instantly — zero explanation cost.

These outweigh the extra build/perf cost, *provided* the world is sized for a solo dev
on a Vega 8 (it is — see below) and the streaming is configured, not hand-built.

## World size — derived from the 2-minute rule

The committed constraint: **walking between two neighboring regions takes under
2 minutes.** Converting:

- Character move speed ≈ **2 m/s** (typical for a grounded action-RPG; tune later).
- 2 minutes = 120 s → **neighbor-to-neighbor ≈ 180–240 m.**
- ~15 catalogued regions, embedded as a **graph in 2D** (not a line — regions branch:
  Magizhee radiates N/E/S/W per `world-structure.md`), spaced ~200 m between neighbors.

This lands the whole landmass at roughly **~1.5–2 km across (~1.5–2 km²)** — the
**small-open-world** tier. For scale calibration: Skyrim is ~14 km² and took a studio;
this is ~1/8th of that and solo-viable. The water divide, mountain edges, and dense
regions all fit comfortably inside it without feeling cramped, because the world is
**designed sparse** ("wide in implication, focused in gameplay" —
`world-structure.md`): the emptiness between landmarks is short and atmospheric, not
vast and boring.

> **The sizing rule, generalized:** size the world by **inter-region walk time**, not
> by area ambition. 2 minutes between neighbors is the budget. If a stretch of empty
> terrain takes longer than ~2 minutes to cross with nothing in it, it's too big — add
> a landmark, an encounter, or shrink it. Emptiness is a *seasoning*, not a *distance*.

## How the documented regions map onto one landmass

Nothing in the region design is lost — the regions are **re-homed**, not re-decided:

| Was (zone-graph framing) | Now (open-world framing) |
| --- | --- |
| "Separate loaded regions connected by corridors/gates" | **Dense POIs on one continuous map**, connected by walkable open terrain |
| "Decompression corridors between regions" | **The open terrain itself** between POIs — same role (breathe, talk to sword, see distant husks), now seamless |
| "Hard gates (the ferry crossing)" | **Still hard gates** — a gate is now a *traversal lock* on open terrain (the river you can't swim, the ferry you must repair), not a loading boundary. The water divide is the cleanest example. |
| "The square map (`One_Accord_Map.png`)" | **The literal terrain heightmap layout** — the drawn map becomes the authored landmass. The visual source of truth gets *more* authoritative, not less. |

The **connectivity-map graph** (`../Documentation/Regions/connectivity-map.md`) still
holds — it's now the *intended pathing* across open terrain (which mountains wall off
which routes, where the ferry gates the water), enforced by **terrain and traversal
locks** instead of by separate scenes. Mountains being impassable (husks don't come
from the western/southern edges) is now **literal collision geometry** that bounds the
playable world for free.

## The streaming architecture (the new hard system)

This is the one genuinely new engine system the open-world choice adds. The honest
framing: **Skyrim ran this on a 512 MB Xbox 360 — it's a discipline problem, not a
horsepower problem.** Five techniques carry the entire thing; Godot 4 + Terrain3D
provide most of them as configuration, not from-scratch code.

### The five load-bearing techniques

| Technique | Job | Source |
| --- | --- | --- |
| **Terrain LOD (clipmap)** | Near terrain full-res, distant terrain progressively coarser. The core trick that makes a 2 km landmass renderable. | **Terrain3D** addon — native clipmap LOD |
| **Chunk/cell streaming** | Only world cells near the player are loaded in RAM/rendered; far cells unload. | Terrain3D streams terrain; **objects** need a cell system (grid of scenes loaded/unloaded around the player) |
| **Mesh LOD + impostors** | Trees/buildings drop to cheaper meshes, then to flat billboards (impostors) at distance. | Godot auto-LOD + billboard impostors for far landmarks |
| **Distance fog** | Hides the LOD/stream horizon **and** is the mood (`00-tech-thesis.md`). Double duty. | Godot volumetric/depth fog |
| **Occlusion + frustum culling** | Never render what's behind a hill or off-screen. | Godot occlusion culling + portals where useful |

### The cell-streaming model

The landmass is divided into a **grid of cells** (e.g. 64 m or 128 m squares). At any
time, only the cells in a radius around the player are *active*:

```text
        loaded as low-LOD / impostor (visible, cheap)
   ┌───┬───┬───┬───┬───┐
   │ . │ L │ L │ L │ . │      . = unloaded (beyond fog)
   ├───┼───┼───┼───┼───┤      L = streamed-in, low detail
   │ L │ A │ A │ A │ L │      A = active, full detail + collision + sim
   ├───┼───┼───┼───┤───┤
   │ L │ A │ P │ A │ L │      P = player's cell
   ├───┼───┼───┼───┼───┤
   │ L │ A │ A │ A │ L │
   ├───┼───┼───┼───┼───┤
   │ . │ L │ L │ L │ . │
   └───┴───┴───┴───┴───┘
```

- **Active ring (A/P):** full-detail meshes, collision, and **simulated entities**.
- **Loaded ring (L):** streamed in but low-LOD / impostor — visible across fog for
  landmark navigation, cheap to render, *no per-frame sim cost*.
- **Unloaded (.):** beyond the fog horizon; not in memory.
- Cells **stream in/out asynchronously on a background thread** as the player moves —
  Zen2's 16 threads (`00-tech-thesis.md`) make this free of frame hitches if done off
  the main thread. **The sim tick never blocks on streaming** (`01-architecture.md`).

### Crucial: streaming is a RENDER-side concern, not a SIM-side one

This is the architectural keystone, and it protects the whole project:

> The **sim core does not stream.** The sim is the *authoritative whole world* in
> memory at all times — it's cheap (data, not meshes; the world has ~200 ever-seen
> NPCs, not millions). **Only the renderer streams**: it loads/unloads the *visual
> representation* of cells around the camera. The hive scheduler, NPC logs, and economy
> simulate the whole world continuously regardless of where the player is standing.

Consequences, all good:

- **No "the world freezes when you leave" problem.** Because the sim holds everything,
  the rotating food caravan, hive thread allocation, and offscreen NPC routines keep
  running — which One Accord's design *requires* (deep agents remember/act in the
  world, `../Documentation/Mechanics/log-and-agent-memory.md`). A streamed *render*
  over a fully-resident *sim* is exactly the right shape for this game.
- **Streaming bugs can't corrupt game state.** A cell that fails to load is a visual
  glitch, not a lost NPC. The sim is the truth (`01-architecture.md`).
- **The whole-world sim is affordable** precisely because the world is small in
  *entity count* (the post-famine thinness is a perf gift, not just a theme).

The sim→render snapshot (`01-architecture.md`) simply learns to say *"entity X is in
cell C at transform T"*; the renderer decides whether C is active/loaded/unloaded and
draws (or impostors, or skips) accordingly.

## Landmark navigation (the no-minimap system)

The feature that justified open world, and — conveniently — one of the cheapest to
render:

- **Landmarks are authored silhouettes visible across the whole map through fog:** the
  Sanctum mountain (Vaelp, on the SW peak), Vendur's two-tier hillfort, the Old Dock,
  Digzarr's ruin skyline across the water, the Naerchu camp. Each is placed so it
  *reads from distance* and tells the player where they are and where to go.
- **They cost almost nothing** because at distance they're **low-LOD or flat
  impostors** — a billboarded silhouette of the Sanctum mountain is a few triangles.
  The thing the player navigates by is the thing that's cheapest to draw. Perfect
  alignment of design pillar and Vega-8 budget.
- **Fog *frames* landmarks rather than hiding them** — DS1/Skyrim atmospheric
  perspective: distant landmarks fade to a fog-tinted silhouette, which *reads as
  distance* and pulls the player forward. Fog is simultaneously the mood, the streaming
  horizon, and the navigation aid.
- **Design obligation:** because there's no minimap, **every region must be
  silhouette-identifiable from its neighbors.** This becomes a region-design rule (each
  dense region needs a distinct skyline/landmark) — a small addition to the "what each
  dense region needs" list in `world-structure.md` (noted in the sync).

## The Vega-8 streaming budget

Open world makes `00-tech-thesis.md`'s rules *more* binding, not less:

- **Resolution scaling + fog are now non-negotiable** — they were "first-class"; they
  are now the load-bearing walls. Fog radius ≈ streaming radius: you only fully render
  what's inside the fog, and the fog *is* the reason that's okay.
- **Impostor everything distant.** Trees, buildings, landmarks beyond the active ring
  are billboards. The active ring is small (a few cells); everything past it is cheap.
- **The active-ring radius is the master perf knob.** Smaller ring = less to render =
  higher FPS, hidden by tighter fog. Tune ring radius + fog distance together until the
  Vega 8 holds frame (`08-render-derisk-plan.md` spike).
- **Grass/foliage only in the active ring**, fading into fog at the ring edge — caps
  the #1 overdraw risk (`03-assets-and-animation.md`) to a small radius regardless of
  world size.
- **Budget the *active ring*, not the world.** World size barely affects frame cost if
  streaming is right — a 2 km world and a 20 km world render the same active ring. The
  cost of "bigger world" is *RAM, disk, and authoring time*, not frame rate. (Another
  reason the small 2 km size is the sweet spot: it's authorable solo, and frame cost
  was never the constraint anyway.)

## What this adds to the build plan

- **A new system to build/configure:** the cell streamer (Terrain3D for terrain +
  an object-cell loader for props/buildings/NPC visuals). This is the open-world
  tax — real, but mostly *configuration + a manager script*, not a from-scratch engine.
- **A new de-risk spike** (folded into `08-render-derisk-plan.md`): *Terrain3D + a
  streaming object grid + impostor landmarks + fog, walked on the Vega 8*, confirming
  the active-ring approach holds frame and the landmark-through-fog read works.
- **A region-design rule:** every dense region needs a **distinct, distance-readable
  landmark/silhouette** (the no-minimap obligation). Goes back into the region docs.
- **The drawn map becomes the terrain layout** — `One_Accord_Map.png` graduates from
  "adjacency reference" to "the heightmap/layout authoring target."

## Open / to-decide

- **Cell size** (64 m vs 128 m) and **active-ring radius** — set empirically in the
  spike against the Vega 8.
- **Terrain3D vs. a custom heightfield streamer.** Terrain3D is the pragmatic start
  (clipmap LOD + streaming handed to you); a custom Rust-tools heightfield generator
  (`03-assets-and-animation.md`) stays the option for procedurally-shaped natural
  regions. Likely: Terrain3D for the playable surface, custom noise for *generating*
  heightmaps fed into it.
- **Object-cell streaming**: Godot's `ResourceLoader.load_threaded` + a manager, or an
  existing open-world streaming addon — evaluate in the spike.
- **Save/streaming interaction:** save is sim-only (`01-architecture.md`), so streaming
  doesn't complicate saves — confirm this holds once the streamer exists.
- **`world-structure.md` deeper revision:** this doc supersedes its "not open world"
  framing; a fuller rewrite of that doc's "shape" section is queued (sync note placed,
  full edit deferred so design-canon changes are deliberate, not silent).

## Related

- `00-tech-thesis.md` — the budget that streaming makes load-bearing (fog, res-scale,
  overdraw).
- `01-architecture.md` — the sim/render split: **sim holds the whole world, renderer
  streams it.** The keystone that makes open world safe.
- `03-assets-and-animation.md` — heightfields, instanced foliage, impostor-able props
  the streamer consumes.
- `05-rendering-and-shaders.md` — fog/atmosphere that does the streaming-horizon +
  landmark + mood triple duty.
- `08-render-derisk-plan.md` — the streaming spike on the Vega 8.
- `../Documentation/Regions/world-structure.md` — **revised** by this doc (sync note);
  the region catalogue/tiers/connectivity still hold as POIs on the landmass.
- `../Documentation/Regions/connectivity-map.md` — now the intended pathing across open
  terrain, enforced by terrain + traversal locks.
