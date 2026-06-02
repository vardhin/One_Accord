# Ideation TODO — What's Left to Finalize Before Building

> Reframed 2026-06-02. The earlier framing ("~70% done, only a production bridge
> left") was misleading: what's settled is the **framework** — the caps, tiers,
> grammars, archetypes, and core mechanics. The **content** those frameworks are
> meant to hold is still largely unideated: most regions, buildings, NPCs, quests,
> progression, spells/weapons, and the endgame. That content design is real
> ideation, not production.
>
> The old Sections A & B (settled framework questions + the consistency pass) are
> **deleted** from this tracker — every conclusion in them now lives in its own doc
> and is indexed in `GLOSSARY.md` (the single source of truth for locked terms).
> This file now tracks the **content-ideation worklist** in build-dependency order,
> followed by the **production bridge** (which correctly comes *after* content).
>
> Legend: `[ ]` open · `[~]` partially decided / drafted · `[x]` concluded.
> Each item points at the doc it lives in. Resolve items **in the doc**, then tick here.

---

## The approach: build-dependency order

We ideate content in the order each stage feeds the next:

> **Regions → Buildings & Mechanics → NPCs → Quests → Progression → Spells & Weapons → Endgame**

Regions define *where*; buildings & mechanics define *what operates there*; NPCs
*staff and inhabit* it; quests *give it motion*; progression *gates the motion*;
spells & weapons *are the reward currency of progression*; the endgame *is where it
all converges*. We don't have to finish one stage 100% before touching the next, but
this is the priority spine.

Locked frameworks each stage builds on (see `GLOSSARY.md` for definitions):
region tiers, the 40-NPC cap & NPC tiers, the four-tool kill economy, the glyph
grammar (5×5) & classes, forge levels, the Clarity/Trust/Resonance metrics, the
hivemind thread scheduler, and the seal / soft-infected model.

---

## 1. Regions & open-world structure

- [~] **The region set.** Framework locked: **~7–8 dense + 3–4 mini**, tiered. The
  **lore-demanded set is now catalogued** (`Regions/region-set.md`): starter (mid),
  Vendur (dense), the **Rosetta ruins** (scavengers on hive ground-zero, dense/hot), the
  **deities' underground sanctum** (mini dungeon, first Light glyph), the **divine
  mountain** (true-sword maiden, endgame-tier), Arghanzza **demoted to a pass-through**.
  ~3–4 dense + 1–2 mini remain as reasoned slots. — `Regions/region-set.md`, `Regions/world-structure.md`
- [x] **Open-world / connectivity map.** CONCLUDED as **structure** (the spine, not
  filled with content): heat-ordered Dark Souls lattice; the 3 known regions placed
  (starter root → corridor(s) → Vendur mid-spine hub → … → story-gated endgame
  terminus; Arghanzza an off-spine hot mini-spoke); node types (hub/spoke/corridor);
  three gate types (heat-soft, tool-hard, story-hard) + shortcuts; **reserved slots**
  so future regions claim a position+gate+heat-band instead of being designed blind.
  — `Regions/connectivity-map.md`
- [ ] **Per-region concept pass** for each new region: theme, the one mechanic it
  teaches/owns, its crisis, its tie to the hive's concentration map, and its tier.
- [ ] **Concentration / difficulty layout** across the map — where the hive's
  authored baseline attention is high vs. low, and how that shapes route order.
  — `Mechanics/hive-concentration.md`

## 2. Buildings & mechanics (per region)

- [~] **Building/facility vocabulary.** Starter settlement has a concrete layout
  (gatehouse, well, storehouse, healer shed, forge lean-to, training yard, common
  room, corpse pit); system NPC roles imply facilities. Needs to become a **reusable
  set of building types** with what each *does* mechanically. — `Regions/starter-settlement.md`, `Npcs/system-npc-roles.md`
- [ ] **Which mechanics live in which building** — forge (levels 0–4), healer/Checkup,
  quartermaster/allocation, training, bell-code comms, etc. Map each game system to
  the physical place(s) the player uses it. — `Mechanics/forge-and-upgrades.md`, `Mechanics/village-and-union-system.md`
- [ ] **Region-specific mechanics** — the one new system each region introduces
  (e.g. Arghanzza traversal already drafted; others not). — `Regions/Arghanzza/traversal.md`
- [ ] **The village/union system, concretely** — what "organizing a settlement"
  *is* in buildings + actions, not just as a concept. — `Mechanics/village-and-union-system.md`

## 3. NPCs (fill the 40-named cap)

- [~] **The named roster.** Cap locked at **40**; tiers locked. Authored so far:
  the **Core Five** + ~10–12 Tier-1 **role-slots** (unnamed). The bulk of the 40 —
  names, per-NPC depth, region, what they teach/offer/want — is **unwritten.**
  — `Npcs/core-named-roster.md`, `Npcs/npc-tiers.md`
- [ ] **Per-NPC authoring** as regions come online: name (Chinese-fitting), tier,
  home region/building, role, relationship hooks, literacy domain, log seeds.
- [ ] **Tier-2 secondary cast (~15–25)** — invented under the cap as regions are
  authored (not abstractly).
- [ ] **The Hivemind as inhabitant** — how its threads/Named Nodes populate regions
  as a live presence, region by region. — `Npcs/hivemind-agent.md`, `Enemies/hive-enemy-design.md`

## 4. Quests

- [ ] **Quest structure & taxonomy** — what a "quest" *is* here (this is a
  log/agent-memory world, not quest-flag-driven). Main-arc beats vs. regional vs.
  emergent/relationship-driven. **No quest docs exist yet** — this is greenfield.
  — relates to `Mechanics/log-and-agent-memory.md`
- [ ] **The main spine** — the through-line from the starter crisis to the endgame
  war, region by region.
- [ ] **Per-region quest set** — the crises/arcs each region carries (starter
  settlement's "accused of turning" crisis is the only one drafted).
- [ ] **Sword-relationship arcs as quests** — Voice Link unlocks, soul-duel gates,
  the bond paths. — `Sword/upgrades-and-identity.md`, `Sword/voice-and-brow-touch.md`

## 5. Progression

- [ ] **The progression spine** — what the player actually advances along. Likely
  axes: forge level (0–4), Voice Links (I–VI), glyph/Light-line unlocks, sword
  bond depth, settlement/union cohesion, literacy. How they interlock and gate each
  other. **No unified progression doc exists** — pull the scattered ladders together.
  — `Mechanics/forge-and-upgrades.md`, `Sword/voice-and-brow-touch.md`, `Glyphs/glyph-system.md`
- [ ] **Gating & pacing** — what unlocks what, in what order, tied to the region map
  (Section 1) and quests (Section 4).
- [ ] **"The relationship IS the build"** — concretize the bond paths
  (Dominating/Devotional/Romantic/Professional/Exploitative/Mutual-healing) as an
  actual progression system, not just a lens. — `Sword/upgrades-and-identity.md`

## 6. Spells & weapons

- [~] **Spell tables (386 builds).** Framework + scaffold done; **tier-0 authored**,
  **tiers 1–4 mostly scaffold** (every effect to be hand-authored, no auto-fill).
  Long-tail; track authored vs. scaffold. — `Glyphs/spells/`, `Glyphs/glyph-system.md`
- [ ] **Weapon forms & the mass-gated slots** — dagger(1) → … → greatsword(4):
  feel, trade-offs, how forms are acquired/changed. — `Glyphs/glyph-system.md`
- [ ] **Companion weapons** — the salt-pike / bell-knife / cold-needle / ash-axe
  set for teammates: what each does, who gets them. — `Npcs/system-npc-roles.md`
- [ ] **The Light kill line, concretely** — Silverlight / Pierce-of-Day: where
  they're earned, energy cost, the soft-infected detection use. — `Glyphs/glyph-system.md`

## 7. Endgame

- [~] **Shape recorded, content deferred.** Threads converge to **one** total
  Hivemind in a **Mahabharata-scale final war**. The *design* of that war — its
  structure, the final soul-duel(s), how the map/union/progression feed it — is
  **unideated** (deliberately deferred to the end of ideation).
  — `Mechanics/hivemind-threads.md`, `OVERVIEW.md`
- [ ] **The convergence ramp** — how the merge (quantity→quality) is *played* across
  the late game, not just stated. — `Mechanics/hivemind-threads.md`
- [ ] **Final-region design** + the climactic confrontation.

---

## 8. The ideation→production bridge

> This is the *last* stage, after content ideation. Some early de-risking work is
> already done (the vertical-slice spec, the local-model choice) because they
> unblock prototyping — but the bulk waits until content above is far enough along.

Every design doc is *fiction + systems + content*. This section answers "how do we
build it." Ideation isn't finished until these are decided.

### Scope & slice

> Concluded — written as `Production/vertical-slice-spec.md`.

- [x] **Define the vertical slice** — CONCLUDED: *Three Nights Outside the Gate +
  starter settlement + first sword bond*. One settlement, the Core Five, one local
  crisis, one sword acquisition; no second region, no cross-settlement union, no
  endgame. In/out list written in the spec. — `Production/vertical-slice-spec.md`
- [x] **MVP feature cut** — CONCLUDED. **In:** deterministic dialogue pipeline
  (real), Clarity/Trust/Resonance, small log/agent-memory (sword only as live deep
  agent), Soulslike combat + consent gate, Stillpoint, forge L0→1, Seek Accord.
  **Deferred:** glyphs/386 spells, soul duels/phase-2, cross-settlement union,
  literacy lexicon UI, the hive as a *live* second LLM agent (offscreen pressure in
  v0), full four-tool kill economy. — `Production/vertical-slice-spec.md`
- [~] **Production scope reality-check** — the honest target (full game vs.
  proof-of-concept-first) is **explicitly deferred** (decision 2026-06-02). The
  slice is built first and the target decided after; architecture is NOT to be sized
  for the full 7-region game on the strength of the slice spec.
  — `Production/vertical-slice-spec.md`

### Tech decisions

- [~] **Engine / framework** (2D, Stardew-scale presentation). Godot vs. Unity vs.
  bespoke — **explicitly deferred** (decision 2026-06-02); the slice spec is
  engine-agnostic on purpose. — `Production/vertical-slice-spec.md`
- [~] **LLM integration architecture** — partially concluded. **Model: LiquidAI
  LFM2-8B-A1B** (`Q4_K_M` GGUF), served via **llama.cpp `llama-server` on port 8080**
  (OpenAI-compatible `/v1`). **Zaya is forsaken.** Role locked: the LLM is a **pure
  language interface** (function + few-shot tone + context + canonical payload in →
  one in-voice line out); it never picks functions, manages state, or decides canon.
  Still open: context-builder & log-store *implementation* (data-format pass below).
  — `Production/vertical-slice-spec.md`, `Mechanics/log-and-agent-memory.md`, `Sword/dialogue-system.md`
- [ ] **Data formats** for the canonical payloads the docs already imply: object
  reveal tiers, hint tiers, dialogue-function eligibility, combat logs,
  relationship stats, lexicon/literacy state. Pick a schema (JSON/DB/etc.).
- [ ] **Save system** model (logs, agent memory, world mutation, literacy lexicon).
- [ ] **Chinese-text rendering & input** plan (literacy lexicon UI), plus the
  separate glyph + Telugu rendering.

### Content production pipeline

- [ ] **Art direction & asset plan** — pixel style, sprite scale, tileset needs,
  the sword-girl soul-duel sprite, Arghanzza body-horror look.
- [ ] **Audio** — bell codes (diegetic + mechanical), sword voice presentation
  (text-only? VO?), ambience.
- [ ] **Authoring tooling** — how NPC logs, dialogue functions, region rules,
  glyph tables, and the literacy lexicon get authored/edited at scale.

### Process

- [ ] **Milestone roadmap** — slice → playable demo → region-by-region.
- [x] **Repo/project setup** — now a git repo (design docs under `Documentation/`).
  Code-vs-docs structure to be decided alongside the engine choice.
- [ ] **Risk list** — the LLM-NPC depth, combat feel (Soulslike-first with a
  consent gate), and Arghanzza traversal rules are the highest-risk-to-prove
  systems; plan to prototype them early.

---

## Definition of "ideation done"

Ideation is finished — and we start building in earnest — when:

1. **Content stages 1–7** are ideated to a buildable level: the region map exists,
   each region has a concept + buildings + mechanics, the 40 NPCs are authored, the
   quest spine and per-region quests are designed, the progression spine is unified,
   spells/weapons are filled enough to play, and the endgame is designed (not just
   shape-recorded).
2. **The production bridge (Section 8)** is decided: vertical-slice spec (done),
   engine, LLM architecture, data formats, save system, art/audio/tooling, and a
   milestone roadmap.

Everything past that is production, not ideation. Note: stages don't need to be 100%
*produced* (the 386 spells, all 40 NPC logs, etc. are long-tail) — they need to be
*decided* and demonstrated as authorable.
