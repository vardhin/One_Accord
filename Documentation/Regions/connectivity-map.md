# Connectivity Map — Adjacency, Corridors, and the Route Spine

> The thing `world-structure.md` left as *concept only*: how the dense hubs and mini
> spokes actually connect, what gates each link, and the intended route through the
> game. This doc is **structure, not content** — it places the three concluded
> regions on the spine and reserves slots for the unbuilt ones, so future regions get
> designed into a **known position with a known gate and a known heat**, not into a
> vacuum. Companion to `world-structure.md` (tiers) and
> `../Mechanics/hive-concentration.md` (the heat that orders the route).

---

## The ordering principle: heat **is** the route

Region order ≈ **ascending concentration baseline** (`hive-concentration.md`). The
map is not free-roam-from-minute-one; it's a **Dark Souls lattice** — mostly linear
spine, with optional loops and shortcuts that open as the player gains traversal
tools and forge level. You *can* walk into a hotter region early; the baseline floor
punishes it, which is the soft gate (see "Gating," below).

So the connectivity graph and the difficulty layout are **the same graph**. We don't
maintain two maps.

---

> **The lore-demanded region set now drives this spine** — see `region-set.md` for why
> each place exists. The pinned points below are no longer just the three concluded
> regions; the sword's knowledge-quest threads starter → Vendur → **Rosetta ruins** →
> **underground sanctum** → … → **divine mountain** → endgame.

## The concluded + lore-demanded regions, placed

| # | Region | Tier | Baseline heat | Role on the spine |
|---|--------|------|---------------|-------------------|
| 1 | **Starter settlement** | mid | coolest (floor) | Tutorial crisis; forge L0→1; first sword bond. The spine's root. |
| 2 | **Vendur** | dense | low-but-volatile | The sword's home; full forge; Witness→Partner. "A little far" from starter — reached **through a corridor**, carried by the player who doesn't know it's her home. |
| 3 | **Arghanzza** | mini | **past threshold** (hot) | First possessed-matter region; a single-arc spoke hung **off** the spine, not on it — reached late or via a hard optional link. |

> These three do **not** form the whole spine — they are three fixed points on it.
> Vendur being "a little far" from the starter settlement means **at least one
> corridor (and possibly an unbuilt region) sits between them.** Arghanzza's hot
> baseline means it is **not** an early stop even though it's mini.

---

## Node types on the graph

- **Hub (dense)** — multi-exit. A dense region is a graph *node with several edges*:
  it's where the lattice branches, where shortcuts loop back, where the player
  re-supplies. Returnable.
- **Spoke (mid / mini)** — typically **one or two edges.** A mini spoke is often a
  **dead-end**: one corridor in, the same corridor out, one arc inside. Mid
  settlements may have two edges (on-spine) or one (off-spine).
- **Corridor** — the **edge** itself, and a playable space (see below). Every
  region-to-region link is a corridor; there are no instant/teleport adjacencies
  except unlocked **shortcuts** within an already-cleared stretch.

---

## Corridors are edges *and* rooms

From `world-structure.md`: corridors are the decompression spaces (roads, fields,
bridges, riverbanks, forest paths, dead suburbs). For the map, formalize them:

- **A corridor is a directed-feeling but bidirectional edge** between two region
  nodes. It carries its own **light, drifting concentration** (lower than either
  endpoint's baseline by default — corridors are where you breathe) but it is **not
  safe**: distant husks, patrols, escort beats, "feel watched."
- **Corridor length = pacing dial.** A long corridor (Vendur is "a little far")
  is a deliberate decompression + dread ramp before a heavy region. A short corridor
  is a quick stitch between two arcs.
- **Corridors can hold a single mini-arc** without being a region: one household, one
  husk patrol with a name, one escort. This is how the world stays "wide in
  implication" cheaply.

---

## Gating model — three gate types, soft-first

What blocks or opens each edge. Listed weakest→hardest:

1. **Heat gate (soft, default).** Nothing physically stops you walking into a hotter
   region — but its **baseline floor** (`hive-concentration.md`) means you meet
   smarter Actives / possessed matter you're under-equipped for. This is the primary
   ordering mechanism. It teaches route order through pressure, not walls. *Most*
   edges use only this.
2. **Tool gate (hard, traversal).** Some edges need a **traversal capability** to
   pass at all — Arghanzza's drafted traversal rules (`Arghanzza/traversal.md`) are
   the model: a region/corridor whose passage *is* a learned mechanic. These gate the
   off-spine spokes and the late loops. Acquiring the tool is itself progression.
3. **Story gate (hard, narrative).** A few edges open only on a beat: a bell-code
   alliance, a union threshold, a forge level, a Voice Link, the sword consenting to
   go somewhere. Reserved for the spine's major transitions (e.g. whatever opens the
   approach to the endgame region).

> **Shortcuts** are the inverse of gates: edges that *exist* but are revealed/opened
> from the far side after you've done the long way once (Dark Souls ladders/elevators).
> They turn the spine into a lattice and make backtracking to hubs cheap.

---

## The route spine (current, with reserved slots)

A linear backbone with the three known regions pinned and unbuilt slots marked
`[slot]`. Heat ascends left→right. `══` = on-spine corridor, `┄┄` = off-spine /
gated edge.

```
[Starter settlement]══[corridor]══[Vendur]══ … ══[Rosetta ruins]══ … ══[Divine Mountain]══[endgame]
        (mid, floor)                (dense)          (dense, hot)         (true sword / story)  (story)
              ┊                        ┊                  ┊
              ┄┄[Arghanzza]            ┄┄[slot]           ┄┄[Underground sanctum]
               (mini pass-through)                         (mini dungeon — first Light glyph)
```

> Lore-demanded nodes (`region-set.md`) now fill what were anonymous slots: **Rosetta
> ruins** (scavengers on hive ground-zero) sit hot, mid-to-late; the **underground
> sanctum** hangs off them as a Light-glyph dungeon-spoke; the **divine mountain** is the
> story-gated, endgame-tier One Accord region. Remaining `[slot]`s are the union-system
> second hub and any region a future reason demands.

- The **root** is fixed: starter settlement, lowest heat, where the player gets the
  sword. Non-negotiable first node.
- The **endgame region** is the spine's far terminus, **story-gated**, designed last
  (`../Mechanics/hivemind-threads.md`, Stage 7). One total Hivemind converges there.
- Everything between root and terminus is **reserved slots** filled by the ~7–8 dense
  / 3–4 mini targets, **in ascending-heat order**, each authored when there's a reason
  (per `world-structure.md`). When a new region is designed, it claims a slot — which
  hands the designer its **neighbors, its corridor type, its gate type, and its
  heat band** for free.
- Vendur sits **mid-spine** (dense hub, branch point), not at the end: it's a
  power spike (full forge, silver) and an emotional pivot, reached after at least one
  corridor from the starter settlement.
- Arghanzza hangs **off** the spine as a hot mini-spoke: you detour to it, you don't
  pass *through* it to progress.

---

## How this feeds later stages

- **Stage 4 (Quests).** The **main spine = the route spine.** Each on-spine node is a
  main-arc beat; each spoke/corridor is regional or emergent. The through-line from
  starter crisis → endgame war literally walks this graph.
- **Stage 5 (Progression).** **Gating & pacing** maps onto the gate types here: forge
  levels / Voice Links / traversal tools are *what open the next edge.* Progression
  and the map are the same gate list.
- **Region authoring.** A new region is never designed blind: the slot fixes its
  position, neighbors, gate, and heat band before any content is invented.

## Open

- How many slots actually sit **between** starter and Vendur (1 corridor only, or
  a region too?) — resolve when the first new region is authored.
- Whether the off-spine spokes (Arghanzza, future minis) cluster off **hubs** or off
  **corridors** — lean toward off-hubs so hubs stay the branch points.
- The endgame region's story gate — deferred to Stage 7 with the rest of the endgame.
- Exact corridor count and which carry mini-arcs vs. pure decompression.
```
