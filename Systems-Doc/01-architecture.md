# 01 — Architecture: The Sim-Core / Render-Frontend Split

> The single most important structural decision in the whole build. Everything else —
> engine choice, render risk, even which language each part is written in — falls out
> of getting this boundary right. The thesis (`README.md`): **the simulation is the
> game and it is engine-agnostic; the renderer is a swappable, de-riskable
> front-end.** This doc draws that line precisely.

## The boundary, in one picture

```text
            ┌─────────────────────────────────────────────────────────┐
            │                     SIM CORE  (Rust)                     │
            │            authoritative, deterministic, headless        │
            │                                                          │
            │  ┌───────────────┐  ┌────────────────┐  ┌─────────────┐  │
            │  │ Hive thread   │  │ Sword pipeline │  │ World state │  │
            │  │ scheduler     │  │ (consent,      │  │ (NPCs,      │  │
            │  │ (the spine)   │  │  metrics,      │  │  regions,   │  │
            │  │               │  │  hit-quality)  │  │  economy)   │  │
            │  └───────────────┘  └────────────────┘  └─────────────┘  │
            │  ┌───────────────┐  ┌────────────────┐  ┌─────────────┐  │
            │  │ Combat sim    │  │ Log & agent    │  │ Save / load │  │
            │  │ (Soulslike    │  │ memory         │  │ (serialize  │  │
            │  │  rules,       │  │ (perspective   │  │  the whole  │  │
            │  │  Stillpoint)  │  │  logs, packets)│  │  sim state) │  │
            │  └───────────────┘  └────────────────┘  └─────────────┘  │
            └───────▲───────────────────────┬──────────────────▲──────┘
                    │                        │                  │
        commands /  │          render-state  │  (read-only      │  async
        intents     │          snapshot      ▼   view of sim)   │  language
                    │     ┌──────────────────────────────┐      │  requests
            ┌───────┴─────┴──┐                 ┌──────────┴──────┴───────┐
            │  RENDER FRONTEND │◄────────────►│  LLM LANGUAGE SERVICE    │
            │  (Godot 4)       │              │  (llama.cpp, off-process)│
            │  meshes, anim,   │              │  LFM2-8B-A1B, async,     │
            │  shaders, camera,│              │  *only* turns a chosen   │
            │  input, UI, VFX  │              │  function+context into a │
            │  audio           │              │  line of prose           │
            └──────────────────┘              └──────────────────────────┘
```

Three components, three jobs, hard boundaries:

1. **Sim core** — the authoritative game. Headless, deterministic, no rendering, no
   knowledge of meshes or pixels. *This is the game.*
2. **Render frontend** — turns sim state into pictures/sound and turns input into sim
   commands. Knows nothing about *why* the hive does what it does; it just draws what
   the sim says is true. *This is swappable.*
3. **LLM language service** — an off-process HTTP service that, on request, phrases a
   line. It is downstream of the sim and never authoritative. *This is the existing
   `rhea`-shaped pattern.*

## Why this split is load-bearing (not just tidy)

- **It quarantines the one risk.** Rendering/animation is the dev's only greenfield
  (`README.md`). If the renderer is a thin frontend over an authoritative sim, then
  every rendering experiment, mistake, or even a *whole engine swap* is contained — it
  cannot corrupt or require rewriting the game. The hive scheduler doesn't care if it's
  drawn by Godot, by a Rust/wgpu renderer, or by `println!` in a test harness.
- **It matches the dev's strengths exactly.** The sim is Rust systems work (Recon2x
  territory). The frontend buys the plumbing the dev doesn't want to hand-build again
  (the from-scratch Y-sort/atlas/anim pain). Clean fit.
- **It makes the sim testable headlessly.** The entire game can be unit-/integration-
  tested with no GPU: feed commands, tick, assert on state and logs. For a
  systems-heavy game (scheduler, consent, Stillpoint, memory) this is enormous — most
  of the game's correctness is provable without ever opening a window.
- **It honors the existing canon.** The vision already insists the LLM is "*only* a
  language interface … the deterministic shell is what makes a small model safe"
  (`../Documentation/Production/vertical-slice-spec.md`,
  `../Documentation/Sword/dialogue-system.md`). The sim core *is* that deterministic
  shell. This architecture is the canon, drawn as boxes.
- **It honors the budget.** "The sim tick is sacred and decoupled from FPS"
  (`00-tech-thesis.md`) is only possible if the sim is a separate, authoritative
  module the renderer merely *observes*.

## The sim-core / render boundary, precisely

### What crosses the boundary

**Renderer → Sim (commands / intents):** discrete, validated *intents*, never direct
state edits.

- "player pressed attack with current weapon, facing θ, at sim-time T"
- "player chose dialogue option 2" / "player performed Seek Accord (brow-touch)"
- "player moved with input vector v this tick"

The sim *validates and resolves* these (stamina check, range check, consent gate,
cooperation roll → hit-quality — exactly the pipeline in
`../Documentation/Mechanics/combat-system.md`). The renderer never decides outcomes;
it *requests* and then *displays* what the sim decided.

**Sim → Renderer (a read-only render-state snapshot):** each render frame samples (and
interpolates between) the latest sim ticks. The snapshot is a flat, dumb description:

- entity transforms (position, facing, current animation-state enum + phase)
- combat events to visualize ("hit-quality = guided", "Stillpoint triggered",
  "glyph X fired from carrier with motion vector m")
- HUD-relevant scalars (sword Trust/Clarity/Resonance bars, stamina/energy)
- world cues (fog density, time-of-day, possession/blackout flags for shader state)

The renderer interpolates transforms between sim ticks for smoothness; the sim stays
authoritative on a fixed tick.

### What does NOT cross the boundary

- The sim never holds a mesh, texture, shader, node handle, or pixel.
- The renderer never holds authoritative game truth — it caches a *view*, discardable
  at any time, rebuildable from the sim.
- **Rule of thumb:** if a feature would behave identically with the screen turned off,
  it belongs in the sim. If it only exists to be seen/heard, it belongs in the
  frontend.

## Where each documented system lives

| Vision system | Home | Note |
| --- | --- | --- |
| Hive thread scheduler (`Mechanics/hivemind-threads.md`) | **Sim core** | The spine. Pure simulation; thread budget, attention allocation, thread-merge on kills. |
| Sword agency / consent / cooperation roll (`Sword/`, `Mechanics/combat-system.md`) | **Sim core** | Deterministic. The roll → hit-quality happens in the tick. |
| Clarity / Trust / Resonance metrics | **Sim core** | Driven by typed events; renderer only shows the bars. |
| Stillpoint contest (`Mechanics/stillpoint.md`) | **Sim core** | A sim state/mode; renderer presents it. |
| Log & agent-memory (`Mechanics/log-and-agent-memory.md`) | **Sim core** | Perspective-split logs, world-centric context packets. Pure data. |
| Combat (Soulslike rules, stamina, hitboxes-as-rules) | **Sim core (rules) + Frontend (animation/visual hitwork)** | Split carefully — see `05-combat-feel.md`. The *authority* is the sim; the *feel* needs the renderer's animation timing fed back. This is the one boundary that needs real care. |
| Glyph effects (`Glyphs/glyph-system.md`) | **Sim core (what fires, cost, class, kill-resolution) + Frontend (the VFX)** | Sim says "Ember Edge fired, kill-class, carrier motion m"; frontend renders the fire. |
| Soul duels (`Sword/soul-duels.md`) | **Sim core (rules, who-wins, relationship→moveset) + Frontend (the set-piece)** | The signature 3D moment; tech in `06-soul-duel-tech.md`. |
| Dialogue *selection* (which function: WARN/GUIDE/…) | **Sim core** | Deterministic, per canon. |
| Dialogue *phrasing* (the actual words) | **LLM service** | Async, downstream, non-authoritative. |
| Save / load | **Sim core** | Serialize the sim; the renderer rebuilds its view from a loaded sim. Save = sim state only, never render state. |
| Regions / world structure / economy / village-union | **Sim core** | Data + simulation. Renderer draws a region from sim data + scene assets. |
| Rendering, animation, camera, input mapping, UI layout, audio, VFX | **Frontend** | The whole greenfield, bought from the engine. |

## The LLM service boundary

Reusing the **`rhea` pattern** (the dev's existing llama.cpp tool-calling assistant):

- The LLM runs as a **separate process** — `llama.cpp` `llama-server` on
  `localhost:8080`, OpenAI-compatible `/v1/...` (already the documented stance,
  `../Documentation/Production/vertical-slice-spec.md`). Not embedded in the game
  process. This means a crash, a hang, or a model swap can't take the game down, and
  the model can be developed/swapped independently.
- The sim emits a **language request** when (and only when) it has deterministically
  decided to: a chosen dialogue function + the few-shot tone exemplars + the context
  packet + the canon-gated payload. The request is **async and off the tick** — fired
  and forgotten; the response arrives later and is attached to the speaking entity.
- The model returns **one in-voice line**. The sim/frontend validate it (length
  budget per Resonance, no truth leak above Clarity) and either display it or fall
  back to a deterministic line. **The model never picks functions, edits state, or
  decides canon** — it is a phrasing step. (This is verbatim the vision's stance.)
- **Latency, not frame-budget.** Generation can take a while; design dialogue pacing
  to tolerate it (the sword can "consider" for a beat). It never touches the 16 ms
  frame.

## Process / threading model (mapping to the hardware)

Given 16 CPU threads (`00-tech-thesis.md`):

- **Render + main thread** — the engine's main loop (Godot). Owns the window, input,
  the render-state snapshot, interpolation. Must hit the frame budget.
- **Sim thread(s)** — the Rust sim core ticks at a fixed rate on its own thread(s),
  independent of FPS. Communicates with the frontend over a lock-light command queue
  (renderer→sim) + double-buffered snapshot (sim→renderer). With Zen2's thread count,
  the sim never starves the renderer.
- **LLM: separate process.** No game thread blocks on it; the game talks HTTP to it
  async.

This is a very `Recon2x`-shaped concurrency picture (authoritative async core, typed
messages across a boundary, a thin presentation layer) — deliberately, because it
plays to the dev's proven strengths.

## How this constrains the engine choice

For this architecture, the engine needs to: (a) be a strong **3D render/scene/anim
frontend** on a Vega 8, and (b) let an **authoritative Rust sim core** drive it across
a clean boundary, ideally in-process for low-latency state transfer. That is precisely
the **Godot 4 + Rust GDExtension** shape — Godot is the frontend, the Rust sim is a
GDExtension the scene observes. Full reasoning, alternatives, and the escape hatch in
`02-engine-evaluation.md`.

## Open

- Exact snapshot format and update cadence (per-tick full snapshot vs. event-delta +
  transform stream). Decide once the first combat spike exists.
- The combat sim↔animation feedback loop (sim authority vs. animation-driven timing)
  is the one genuinely tricky boundary — designed in `05-combat-feel.md`.
- Whether save serialization uses the same Rust types directly (serde) — almost
  certainly yes, given the sim is Rust.

## Related

- `00-tech-thesis.md` — why the sim tick is sacred and the renderer is the scarce-GPU
  consumer.
- `02-engine-evaluation.md` — the engine that fits this boundary.
- `05-combat-feel.md` — the one boundary (combat feel) that needs special care.
- `../Documentation/Sword/dialogue-system.md`,
  `../Documentation/Mechanics/log-and-agent-memory.md` — the canon this architecture
  serves.
