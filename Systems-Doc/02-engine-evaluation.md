# 02 — Engine Evaluation

> The vertical-slice spec deferred this ("Godot vs Unity vs bespoke — deferred to a
> later bridge pass"). This is that pass. The decision is weighed against the dev's
> *actual* situation — a strong Rust systems engineer with zero graphics experience,
> a Vega 8 target, the sim/render split of `01-architecture.md`, and a hard-won lesson
> about from-scratch gamedev.

## Recommendation (up front)

> **Godot 4 for the render/scene/animation frontend, with the authoritative game in a
> Rust sim core exposed as a GDExtension.**
>
> Godot owns the greenfield (3D rendering, skeletal animation, scene graph, shaders,
> camera, input, UI, audio). The Rust sim core (`01-architecture.md`) owns the game
> (hive scheduler, sword pipeline, logs, combat rules, save). The boundary between
> them is the GDExtension API. The LLM stays a separate llama.cpp process.

The rest of this doc is *why*, the alternatives weighed honestly, and the escape hatch
that the architecture deliberately preserves.

## The decision criteria (from the dev's reality)

1. **Buy the greenfield, build the wheelhouse.** The engine exists to provide the 3D
   rendering/animation/scene plumbing the dev has never built and doesn't want to
   hand-roll. Everything the dev *is* good at (systems, Rust, concurrency, local LLM)
   should stay hand-written. The from-scratch 2D Zelda lesson is decisive: hand-writing
   Y-sort, atlas loading, frame splitting, anim loops was a tar pit in *2D*; in 3D
   (skeletal animation, glTF import, scene culling, gizmos, editor tooling) it is a
   career's worth of yak-shaving. **Do not rebuild the engine.**
2. **Strong 3D on a Vega 8.** The engine must render DS1-tier 3D well on an integrated
   GPU, with a forward/light renderer path, good fog/atmosphere tools, resolution
   scaling, and a real shader language (the glyph VFX and soul-duel look are
   hand-written shaders — `00-tech-thesis.md`, `05-rendering-and-shaders.md`).
3. **Let Rust be authoritative.** Per `01-architecture.md`, the game lives in a Rust
   sim core. The engine must allow native Rust to drive it cleanly and in-process, not
   force the game logic into a scripting language.
4. **Linux-native, ships everywhere.** Dev is on Arch. The engine must be
   first-class on Linux and export to Windows/Linux/Mac without drama.
5. **Solo-dev sustainable.** Free of per-seat/royalty friction, open enough to debug
   into, large enough community for the inevitable 3D-newbie questions.

## The options

### A. Godot 4 + Rust GDExtension — **recommended**

**Shape.** Godot 4 is the frontend and editor. The game is a Rust crate compiled to a
GDExtension (via the **`godot-rust` / `gdext`** bindings), loaded by Godot as native
code. Godot's scene observes the Rust sim's render-state snapshot each frame and feeds
it input intents (`01-architecture.md`).

**Why it fits, point by point:**

- **It buys exactly the greenfield.** Godot 4 gives skeletal animation
  (`AnimationTree`, blend trees, state machines), glTF import, a 3D scene graph with
  culling, a camera rig, an input map, UI (`Control` nodes), audio, and a real shader
  language — *all the from-scratch pain, solved.* This is precisely the plumbing the
  dev felt the absence of in the 2D experiment.
- **Strong on low-end GPUs.** Godot 4 ships a **Forward+** renderer and a lighter
  **Mobile**/**Compatibility** path explicitly aimed at integrated/older GPUs.
  Resolution scaling, distance fog, and a tight light count are all built in — the
  exact `00-tech-thesis.md` levers. Godot 4 on a Vega 8 at DS1-tier scope is a well-
  trodden path, not a gamble.
- **Rust stays authoritative.** `gdext` is mature enough that the sim core can be a
  real Rust crate (with its own tests, its own `serde` save, its own concurrency) and
  Godot just loads it. The dev writes the game in Rust — the engine is the
  *presentation runtime*, not where the game logic is forced to live. This is the
  single biggest reason to prefer it over Godot-with-GDScript or Unity.
- **The shaders are hand-written and that's the point.** Godot's shading language is
  GLSL-like and pleasant; the glyph/possession/soul-duel looks are authored by hand
  here — keeping the dev in the math/shader lane they *want* to be in while the engine
  handles the boring 3D scaffolding.
- **Linux-native, MIT-licensed, no royalties, large community.** Checks 4 and 5
  outright. Debuggable to the source if needed.

**Costs / risks (named honestly):**

- **A GUI editor to learn** — the "bitter pill" the dev already identified. Real, but
  it's a one-time learning curve that pays for itself the first time animation "just
  works" instead of being hand-built. And much of the *game* lives in Rust, so the
  editor is mostly for scenes/anim/materials, not logic.
- **`gdext` boundary friction.** The Rust↔Godot marshalling at the boundary is extra
  surface area. Mitigated by the architecture: the boundary is *small and typed by
  design* (commands in, snapshot out — `01-architecture.md`), not a chatty per-object
  API.
- **3D is still new to the dev** regardless of engine — but Godot minimizes the
  *amount* of new, which is the whole point.

### B. Full Rust — Bevy or raw wgpu

**Shape.** Stay 100% in Rust. Either **Bevy** (Rust ECS game engine) or a **bespoke
renderer on wgpu**. Maximally the dev's language; maximally the "self-contained binary"
instinct (Recon2x ships as one binary — this would too).

**Honest appeal:** it's the most *you*-shaped option. One language, full control, no
GUI editor, no marshalling boundary, ships as a single binary. For the *sim*, this is
genuinely ideal — and in fact **the sim core is written this way regardless**
(`01-architecture.md` makes it a standalone Rust crate). The question is only whether
to *also* build the renderer in Rust.

**Why it's not the recommendation:**

- **It re-greenfields the exact thing the dev should buy.** Bevy's 3D, animation, and
  especially its *editor/tooling* and *asset pipeline* are far less mature than
  Godot's; raw wgpu means hand-building the entire scene graph, animation system,
  glTF pipeline, culling, and gizmos — i.e. reliving the 2D-from-scratch tar pit in 3D,
  at 50× the surface area. This directly contradicts decision criterion #1.
- **3D + zero graphics experience + hand-built renderer is the highest-risk cell on
  the board.** It concentrates *all* the project's novelty (3D, rendering, animation,
  the dev's one weak area) into a from-scratch build. That's the combination most
  likely to stall a solo project.
- **Animation especially.** Skeletal animation, blend trees, IK, retargeting — Bevy is
  improving fast but is still behind, and wgpu gives you none of it. This is the part
  of 3D the dev has *least* feel for and most needs handed to them.

**When B becomes right:** if, after the de-risk spikes (`08-render-derisk-plan.md`),
Godot proves to fight the architecture or the boundary friction is intolerable — the
sim core is *already* a clean Rust crate, so swapping the frontend to Bevy/wgpu is a
contained move, not a rewrite. **This is the escape hatch, and the architecture is
built to preserve it.** Recommend B as a *fallback*, not a *start*.

### C. Godot 4, pure GDScript (no Rust)

**Shape.** Write everything — sim included — in GDScript inside Godot.

**Why not:** throws away the dev's single biggest advantage. The hive scheduler, sword
pipeline, and log/memory are *exactly* the kind of systems code that is a joy in Rust
and a slog in a dynamically-typed engine script. It also couples the authoritative
game to the engine, destroying the swappability/testability of `01-architecture.md`.
GDScript is fine for *frontend glue* (wiring scenes, animation triggers, UI) — and will
be used for that in option A — but the *game* should not live there. Rejected as the
primary, retained as glue.

### D. Unity

**Shape.** Unity engine, C# game logic (optionally Rust via FFI).

**Why not, for this dev specifically:** Unity is a capable 3D engine, but (1) it pushes
logic into C#, sidelining the Rust strength; (2) Linux *editor* support is second-class
(dev is on Arch); (3) licensing/business-model volatility is a real solo-dev risk; (4)
it's heavier on a low-end dev machine than Godot. None of these are fatal, but against a
Rust-systems dev on Arch targeting an iGPU, Godot wins every relevant axis. Not
recommended.

## Comparison at a glance

| Criterion | A. Godot+Rust | B. Full Rust (Bevy/wgpu) | C. Godot+GDScript | D. Unity |
| --- | --- | --- | --- | --- |
| Buys the 3D/anim greenfield | ✅ fully | ❌ rebuilds it | ✅ fully | ✅ fully |
| Rust stays authoritative | ✅ | ✅✅ | ❌ | ⚠️ via FFI |
| 3D on Vega 8 | ✅ strong | ⚠️ DIY perf | ✅ strong | ⚠️ heavier |
| Hand-written shaders | ✅ | ✅✅ | ✅ | ✅ |
| Linux-native (Arch) | ✅ | ✅✅ | ✅ | ⚠️ second-class |
| Animation handed to dev | ✅✅ | ❌ weakest spot | ✅✅ | ✅✅ |
| Solo-sustainable / licensing | ✅ MIT | ✅ | ✅ MIT | ⚠️ volatile |
| Overall risk for *this* dev | **lowest** | highest | medium | medium-high |

## The decision and its guardrails

**Start with A (Godot 4 + Rust GDExtension).** It is the lowest-risk path that still
keeps the dev writing the game in Rust and hand-authoring the shaders they care about,
while handing off the one true greenfield (3D rendering + animation) to a mature,
low-end-friendly, Linux-native engine.

**Guardrails that keep the escape hatch open** (so choosing A is not a trap):

1. **The sim core is a standalone Rust crate with zero Godot dependency.** It compiles,
   runs, and is fully tested headless. Godot is *one consumer* of it. (Enforced by
   `01-architecture.md`.)
2. **The Godot↔sim boundary stays small and typed** — commands in, snapshot out. No
   sprawling per-object API that would weld the game to Godot.
3. **Frontend logic in GDScript stays glue-thin** — scene wiring, animation triggers,
   shader parameter feeds, UI. No game rules leak into it.

Hold those three and the renderer is genuinely swappable: if Godot disappoints after
the spikes, the sim is already portable to a Bevy/wgpu frontend (option B as fallback)
without touching the game.

## First validation

Before committing real content to Godot, run the render de-risk spikes
(`08-render-derisk-plan.md`) — most importantly the **additive-particle overdraw test
on the Vega 8** and a **skeletal-animation + hand-written toon shader** smoke test.
These confirm A delivers `00-tech-thesis.md`'s budget *before* the architecture is
poured in concrete.

## Open

- Exact `gdext` boundary ergonomics (snapshot transfer cost across the FFI each frame).
  Measured in the first spike; the snapshot is small by design, so expected fine.
- Whether the sim ticks on a Rust-owned thread or is driven from Godot's `_physics_process`
  — leaning Rust-owned thread for tick-sovereignty (`00-tech-thesis.md`), confirmed in
  the spike.

## Related

- `01-architecture.md` — the sim/render split this engine choice serves.
- `00-tech-thesis.md` — the Vega 8 budget the engine must hit.
- `05-rendering-and-shaders.md` — the hand-written shader work Godot enables.
- `08-render-derisk-plan.md` — the spikes that validate this choice before commitment.
