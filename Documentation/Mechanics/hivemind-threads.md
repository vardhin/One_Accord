# The Hivemind Thread Scheduler — The Core Mechanic

> The engine under everything the hive does. The Hivemind is an **AI algorithm
> with a finite thread budget**; it **dynamically decides where to spend threads.**
> "Concentration" (`hive-concentration.md`) is just the *visible local effect* of
> that allocation. This is the spine of the game.

## The model: a mind with finite bandwidth

The Hivemind is **one agent** (`../Npcs/hivemind-agent.md`) running on a **finite
pool of threads** — like CPU cores. Each active thread drives **one node**: a husk,
a possessed piece of matter, or a soft-infected person (below). It cannot be
everywhere; it must **choose where its mind goes.**

- The hive **dynamically allocates threads** toward whatever it currently cares
  about — a threatening village, a route, a healer, the player once they matter,
  or simply a region the player is fighting in.
- **Where it spends more threads = where the world is "more concentrated."**
  Allocation is the cause; [concentration](hive-concentration.md) is the effect.
  Per-region baselines and player-driven drift are both just *the scheduler's
  allocation expressed locally.*

> The hive is not a difficulty curve. It is a resource-allocating opponent making
> real decisions about where its limited attention goes. You can bait it, read it,
> and exhaust it.

## The arc: quantity inverts into quality

Thread **count and competence trade off over the game**, and **player progress
drives the inversion.**

- **Early game — many dumb threads (~200, illustrative).** Cheap, disposable, low
  cognition. A thread does little more than make one husk act like a competent
  warrior. It can **call more threads** to a fight (escalation by recruitment).
  Feels like *Vampire Survivors*-style swarm pressure — many bodies, little mind.
- **Mid/late game — threads merge.** As the player clears threads and pushes
  inward, the hive is **squeezed** and **consolidates**: fewer threads, each far
  smarter. A merged thread becomes a **husk-commander** that can coordinate
  *hundreds* of husks, **levitate** rocks/weapons/items (telekinesis), and spawn
  **grotesque body-horror** — darker, denser, deliberate. The swarm grows a brain.
- **Endgame — one.** All threads converge into a **single total Hivemind entity**:
  a **Mahabharata-scale war** where it coordinates thousands of husks, mini-
  commanders, levitated weapons and horrors under one unified mind. (Endgame
  specifics deferred — see `../OVERVIEW.md`; this is its expected shape.)

## Player progress is what sharpens it (the tragic loop)

The merge is **player-driven.** Every thread you clear, every push toward the
core, **squeezes the hive's bandwidth** — so it merges to stay effective.

> Your success is what makes it smarter. You cannot win by grinding it down,
> because grinding it down is exactly what sharpens it. The dumb 200-thread swarm
> is the hive *comfortable*; the merged commanders are the hive *cornered* — and a
> cornered hivemind is the real monster. By the time you reach the end, you have
> personally forged the intelligence you face.

This is the same truth `hive-concentration.md` states ("the enemy scales because
you are removing places for its mind to hide") — now with an actual engine: you
are not removing hiding places in the abstract, you are **forcing the scheduler to
pack the same mind into fewer, denser allocations.**

## What a driven node does

A spent thread expresses differently by body type:

- **Driven husks** act with eerie competence and, when merged, **coordinate** —
  the moment dumb husks suddenly flank you is the tell that the hive just spent
  threads here. Merged commanders add telekinesis and spawned horrors.
- **Driven soft-infected people** (below) act **covertly** — they blend in, then
  do something while puppeted and **wake with no memory of it.**

Reading *where the hive has spent its threads* becomes a real player skill.

## Soft-infected people — the human backdoor

The old hero **sealed** the Hivemind, so **the living can no longer be infected.**
This inverts zombie-survival grammar: **infection is not a transmission risk.**
(See `plague-and-infection.md`.) But the seal left a residue: **soft-infected**
people.

- Day to day, a soft-infected person **is themselves** — fully a person.
- But they are a **backdoor**: the sealed hive can **spend a thread to take them
  over.** While taken over they act for the hive; **afterward they have no memory
  of what they did.** A blackout puppet.
- **Only late-game Light glyphs can identify a soft-infected person**
  (`../Glyphs/glyph-system.md`). Before that you genuinely cannot tell — you live
  among them blind. The tools to know arrive too late to feel safe.
- This is the unsettling ontological note of the setting: *"No — I'm not a
  human"* / are you sure the person across the table is? Are you sure of yourself?

The soft-infected are simply **another kind of node the scheduler can target** —
a human channel alongside husks and possessed matter.

## How this folds the existing docs together

- **`hive-concentration.md`** — concentration *is* local thread density. Baseline =
  how many threads the hive tends to keep in a region; drift = the player drawing
  the scheduler's attention by fighting there. That doc is the *local face*; this
  doc is the *engine*.
- **`../Enemies/hive-enemy-design.md`** — Husks = unthreaded/low-thread bodies;
  Actives = threaded bodies; merged threads = the husk-commanders / Named Nodes.
- **`kill-resolution.md`** — why clearing bodies concentrates the will: freed
  threads get re-allocated denser. Severance (soul duel) is how you truly remove a
  *threaded* body.
- **`../Sword/soul-duels.md`** — finishing a merged thread's physical presence
  drops you into **1v1 soul combat** — a **phase-2 boss fight.**

## Open / deferred

- **Thread count** (constant vs. dynamic; the ~200 figure is illustrative) — tune
  later; it may scale with the merge arc.
- **Exact takeover triggers** — the scheduler weighs attention-grabbing player
  actions, proximity, and some randomness; precise weighting is a later AI-design
  pass.
- **Endgame final-war specifics** — deferred to end of ideation.

## Related

- Concentration (local face) → `hive-concentration.md`
- The Hivemind as a bounded agent → `../Npcs/hivemind-agent.md`
- Kill resolution / four-tool economy → `kill-resolution.md`
- Enemy taxonomy → `../Enemies/hive-enemy-design.md`
- Soul duels (phase-2 boss) → `../Sword/soul-duels.md`
- Plague / soft-infected / checkup → `plague-and-infection.md`
