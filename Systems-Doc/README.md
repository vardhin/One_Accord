# Systems-Doc — Bringing the Vision to Reality

> Status: **opening pass.** `../Documentation/` is the *vision* (what the game is).
> `Systems-Doc/` is the *realization* (how it gets built as software). Where
> `../Documentation/Production/vertical-slice-spec.md` deliberately **defers** engine
> and rendering, this directory is where those deferred decisions get made — now that
> the 2D→3D reconsideration is on the table.

## Why this directory exists

The vision docs are deep and mostly *settled at the framework level*. But they are
written engine-agnostic and presentation-agnostic on purpose. Two things changed that
forced a systems pass:

1. **The 2D→3D reconsideration.** The vision was specced as "top-down 2D action-RPG at
   Stardew presentation scale." We are reconsidering 3D — for shader-driven combat
   VFX, for the soul-duel set-piece, and because the dev believes the vision lands
   harder in 3D.
2. **A hardware-as-constraint stance.** Development happens on an AMD Ryzen 7 5700U +
   **Vega 8 integrated GPU**, 30 GB RAM, no discrete GPU. The stance is not "this is a
   limitation" but **"if it runs smoothly here, it runs smoothly almost everywhere"** —
   optimization-native by construction. See `00-tech-thesis.md`.

## The load-bearing thesis (read this first)

**The simulation is the game, and the simulation is engine-agnostic.**

Every one of the five pillars (`../Documentation/OVERVIEW.md`) is a *simulation /
language* problem, not a *rendering* problem:

| Pillar | Nature |
| --- | --- |
| Dyadic weapon embodiment (consent, metrics, dialogue) | simulation + language |
| Concentrated/distributed hive (thread scheduler) | simulation |
| Post-plague village mobilization / union | simulation |
| Context/log-based agent memory | simulation + data |
| Possession vs. partnership (the whole thematic axis) | simulation |

None of these care whether a husk is a sprite or a mesh. **2D-vs-3D does not touch the
soul of the game** — it is a *presentation* decision layered on top of a sim that is
identical either way.

The consequence, which organizes this whole directory:

> Architect for a **hard sim-core / render-frontend split.** The sim core is where the
> game lives and where the dev's existing strengths (Rust, systems, local-LLM
> tooling) apply directly. The renderer is a **swappable front-end** and the **only
> genuine greenfield risk.** Concentrate de-risking there; keep it quarantined from
> the sim.

See `01-architecture.md` for the boundary, `02-engine-evaluation.md` for the engine
call this thesis leads to.

## Document map

| Doc | Pins down |
| --- | --- |
| `00-tech-thesis.md` | The DS1-tier-on-a-Vega-8 target; the performance budget; "optimization-native" made concrete |
| `01-architecture.md` | The sim-core ↔ render-frontend boundary; where the LLM service, thread scheduler, logs, and save live; data flow |
| `02-engine-evaluation.md` | Godot 4 + Rust GDExtension vs full-Rust vs alternatives — weighed against the dev's actual portfolio. **Recommendation: Godot 4 (render/scene/anim) + Rust GDExtension (sim).** |
| `03-assets-and-animation.md` | **Where every mesh/animation/terrain/grass asset comes from.** The "I can't model or animate" answer: bought realistic-ish characters + Mixamo retarget for people; procedural/instanced for the world; hand-made only for hero props. Per-class Vega-8 cost. |
| `04-rendering-and-shaders.md` | *(next batch)* The DS1 look on an iGPU; fog/atmosphere as the cheap win; the shader catalogue (toon, glyph VFX, possession, soul-dimension); camera |
| `05-combat-feel.md` | *(next batch)* Translating the Soulslike sim (stamina, consent, hit-quality, Stillpoint) into 3D animation + hitboxes |
| `06-soul-duel-tech.md` | *(next batch)* The signature 3D set-piece: dimension shift, the relationship-reshaped playable body |
| `07-render-derisk-plan.md` | *(next batch)* The cheap spikes to run *first* to kill the 3D risk before committing |

## Relationship to the vision docs

- This directory **does not re-decide design.** Where a system is specced in
  `../Documentation/`, that spec is canon; Systems-Doc only describes how to *build*
  it. If a build constraint forces a design change, that change goes back into
  `../Documentation/` and is noted here as a cross-link, not silently diverged.
- The **GLOSSARY** (`../Documentation/GLOSSARY.md`) remains the single source of truth
  for named systems. Systems-Doc uses those names.
- The **vertical slice** (`../Documentation/Production/vertical-slice-spec.md`) remains
  the first build target. Systems-Doc's job is to make that slice *buildable* — engine
  chosen, architecture drawn, render risk retired.

## Who's building this (and why that shapes the docs)

Solo dev, **systems/backend/full-stack**, strong Rust (see Recon2x: production-grade
P2P networking — tokio/axum, X25519/ChaCha20, NAT traversal — and rhea: a llama.cpp
tool-calling assistant). The implication runs through every doc here:

- **The sim core is squarely in-wheelhouse.** Thread scheduler, deterministic sword
  pipeline, log/agent-memory, local-LLM language interface — these are backend
  simulation problems the dev already ships.
- **Rendering/animation is the one greenfield.** No graphics work in the portfolio.
  So the engine choice exists primarily to **buy the rendering/scene/animation
  plumbing the dev would otherwise hand-build** (and has felt the pain of: a prior
  from-scratch 2D Zelda-like meant hand-writing Y-sort, atlas loading, frame
  splitting, anim loops — all free in an engine). In 3D that trade is overwhelming.
- **Shaders/math stay hand-written even inside an engine** — which is exactly where
  the dev *wants* to be, and where the glyph VFX and soul-duel look live.
