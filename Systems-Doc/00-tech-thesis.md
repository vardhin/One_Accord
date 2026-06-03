# 00 — Tech Thesis: DS1-Tier on a Vega 8

> What "looks like a banger, runs on a potato" means *concretely*, as numbers and
> rules rather than a vibe. This doc fixes the **target look**, the **performance
> budget**, and the **optimization-native stance** so every later rendering decision
> has something to be measured against.

## The target look, named: "DS1-tier"

The committed visual target is **Dark Souls 1**, not photorealism. This is a
deliberately *humble and achievable* bar, and naming it kills a whole class of scope
creep. What DS1 actually is, technically:

- **Low-to-mid polygon counts.** DS1 ran on 2005-era console GPUs (Xbox 360 / PS3).
  Characters are a few thousand triangles, not hundreds of thousands.
- **The look is carried by *art direction and atmosphere*, not raw fidelity** —
  fog, volumetric haze, restrained palettes, strong silhouettes, baked-feeling
  lighting, and careful contrast. The famous DS1 mood is **cheap to render and
  expensive to *design*** — which is the correct cost to pay as a solo systems dev,
  because design cost is paid in taste and iteration, not in GPU cycles or art labor.
- **No heavy modern rendering.** No ray tracing, no dense screen-space global
  illumination, no high-res PBR everywhere. Stylized, grounded, atmospheric.

> **The thesis in one line:** *we buy mood with fog and art direction, not with
> teraflops* — which is exactly why DS1-tier is the right target for a Vega 8.

This also reconciles cleanly with the existing tonal range in
`../Documentation/genre-and-themes.md` ("dark and brutal like Dark Souls in places,
colorful and fairy-tale in others"). DS1-tier rendering serves the dark register
natively; the fairy-tale register is a palette/lighting shift on the same renderer,
not a second art pipeline.

## The hardware target (the "everyone's PC" baseline)

Dev machine = **the minimum spec, on purpose.**

| Component | Dev machine | What it means |
| --- | --- | --- |
| CPU | Ryzen 7 5700U — 8 core / 16 thread, Zen2 mobile | Genuinely strong for **simulation**. The sim core has CPU headroom to spare. |
| GPU | **Vega 8 iGPU** (AMD Lucienne), shares system RAM | Real, shader-capable, modern-API GPU. Modest fill rate / bandwidth. The actual constraint. |
| RAM | 30 GB | Plenty — comfortably holds the game *and* the local LLM. |

**Why this is an asset, restated precisely.** The Vega 8 is roughly a 2020 *low-end
laptop* GPU. It is below the Steam hardware-survey median but **above the survey
floor** — meaning a game that targets it cleanly runs on essentially the entire active
PC population. "Optimization-native" is literally true: there is no separate
optimization phase because the dev *cannot* ship something that only runs on better
hardware — the dev would see the stutter first.

**The asymmetry to exploit (this is the whole strategy):**

- **CPU: abundant.** 16 threads of Zen2. The sim — thread scheduler, sword pipeline,
  log/memory, AI — has room. *Spend here freely.*
- **GPU: scarce.** Vega 8 fill rate and memory bandwidth are the bottleneck.
  *Every rendering decision is a GPU-budget decision.*
- **The local LLM is neither** — it's a *latency* problem, not a frame-budget problem,
  because it runs off the hot path (one line at a time, async, never per-frame). See
  `01-architecture.md`.

## The performance budget (concrete numbers to design against)

These are **targets to architect toward**, not measurements yet. They exist so that
"is this too expensive?" has an answer before code is written.

### Frame budget

- **Target: 60 FPS → 16.6 ms/frame** at the *intended* presentation scale (one dense
  region, Stardew/New-Vegas-Goodsprings settlement density, not an open world).
- **Acceptable floor: 30 FPS → 33 ms/frame** during peak combat VFX (glyph storms,
  soul-duel set-pieces). A locked, stable 30 beats a stuttering 45.
- **The sim core must hold a fixed tick (e.g. 30–60 Hz) independent of render FPS.**
  Sim and render are decoupled (`01-architecture.md`), so a GPU hiccup never corrupts
  hive-scheduler timing or combat windows. This is non-negotiable for a Soulslike —
  parry/dodge windows live in the sim tick, not the frame.

### GPU budget (Vega 8, the scarce resource)

Design rules that follow directly from a bandwidth-limited iGPU:

- **Resolution is the cheapest knob.** Target internal **1080p**, but build for
  **render-scale / resolution scaling** from day one (render the 3D world at 0.7–0.85x
  and upscale). On an iGPU this is the single highest-leverage perf lever.
- **Overdraw is the enemy.** Transparent/additive particles (glyph VFX!) are the most
  likely thing to tank a Vega 8 — they re-shade the same pixels many times. Glyph and
  soul-duel VFX must be budgeted *as overdraw*, not as particle count. See
  `05-rendering-and-shaders.md`.
- **Fog is free mood AND a perf tool.** DS1 fog both *makes the look* and **justifies
  aggressive distance culling / short draw distance** — you cannot see the thing you
  didn't draw. The aesthetic and the optimization are the same decision.
- **Lighting: lean.** Prefer a small number of real-time lights + baked/ambient mood
  over many dynamic lights. Forward (or Godot's "Compatibility"/Forward+ at low
  settings) over a heavy deferred pipeline on this GPU class — pinned in
  `02` / `03`.

### CPU / sim budget (the abundant resource)

- The sim core gets a **dedicated tick on its own thread(s).** With 16 threads, the
  hive scheduler, sword pipeline, and memory/log writes never compete with the render
  thread for the frame.
- **The LLM call is fully async and off-frame.** A dialogue line may take hundreds of
  ms to a few seconds to generate; it must *never* block a tick or a frame. The sim
  picks the dialogue function deterministically and the rendered line arrives whenever
  it's ready. (Matches the vision: the LLM is *only* a language interface —
  `../Documentation/Production/vertical-slice-spec.md`.)

## Rules that fall out of the thesis

These become the standing constraints the rest of Systems-Doc obeys:

1. **GPU-scarce, CPU-abundant.** When in doubt, move work from the GPU to the CPU/sim,
   or to a baked/precomputed step. Never the reverse.
2. **Budget VFX as overdraw, not as count.** The glyph system's "particles/fields
   emitted from a carrier" is the marquee feature *and* the top perf risk; it is
   designed against an overdraw budget from the start.
3. **Resolution scaling and fog are first-class, not polish.** Both are in the
   architecture from day one because both are how a Vega 8 hits frame.
4. **The sim tick is sacred and decoupled from FPS.** Combat windows and scheduler
   timing live in the tick. Rendering can drop frames; the sim cannot drop ticks.
5. **DS1-tier is a ceiling, not a floor.** No feature is allowed to push past
   "DS1 would have done this" without an explicit, written justification — that's the
   anti-scope-creep tripwire.

## Open / to-measure

- Actual Vega 8 headroom for additive particle overdraw — **the first spike to run**
  (`08-render-derisk-plan.md`).
- Whether 60 FPS is realistic at intended density or whether 30-locked is the honest
  default for combat-heavy scenes.
- LLM inference latency on this CPU (LFM2-8B-A1B, Q4_K_M, llama.cpp) under a realistic
  context packet — affects how dialogue pacing *feels*, not frame rate.

## Related

- `01-architecture.md` — the sim/render split that makes "sim tick is sacred" real.
- `02-engine-evaluation.md` — the engine that delivers this budget on a Vega 8.
- `05-rendering-and-shaders.md` — fog, resolution scaling, overdraw, the shader
  catalogue.
- `../Documentation/Glyphs/glyph-system.md` — the VFX-heavy system this budget must
  survive.
