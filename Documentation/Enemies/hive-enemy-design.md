# Hive Enemy Design — Husks, Actives, Nodes

> The enemy taxonomy. All of it is one mind (the Hivemind, `../Npcs/hivemind-
> agent.md`) distributed across bodies. Scaling logic lives in
> `../Mechanics/hive-concentration.md`.

## The three forms

### Husks

Infected bodies running on **low instinct or routine.** They repeat old habits:

- Farming dead fields.
- Guarding empty gates.
- Stamping papers.
- Walking festival routes.
- Sitting at banquet tables.
- Ringing broken bells.

Dumb, numerous, mostly harmless individually — but tragic and eerie.

### Actives

Bodies **currently occupied** by the hive — i.e. a husk the scheduler is spending
a **thread** on (`../Mechanics/hivemind-threads.md`). Smarter, more dangerous,
strategic, and can **speak as the same entity.**

### Named Nodes

Emerge when a body has held hive attention **long enough** — when **merged
threads** consolidate on it (`../Mechanics/hivemind-threads.md`) — to develop a
**pseudo-personality.** These are the **husk-commanders**: they coordinate many
husks, can **levitate** matter/weapons, and spawn body-horror.

- Mini-bosses.
- Generals.
- Infiltrators.
- Negotiators.
- Assassins.

> **Named Nodes are hive-grown, not infected humans.** The living cannot be
> infected (the seal holds — `../Mechanics/plague-and-infection.md`), so there are
> **no "infected NPC" nodes.** The human channel the hive *can* reach is the
> **soft-infected** (temporary blackout takeover, not a permanent node).

## The concentration dynamic (recap)

Finite bodies, finite attention. Reducing husks means fewer bodies to spread
attention over → remaining bodies more likely to become **active / smarter /
personal.** Full detail: `../Mechanics/hive-concentration.md`.

> Early: too many. Mid: that one knew my name. Late: every one is looking.
> Endgame: no distance between hive and body.

## Behavior archetypes (reusable templates)

> **Numbers are decided at implementation.** HP, damage, stamina, hitbox/recovery
> timings, and aggro radii are *tuning values* that need the engine and combat
> feel before they mean anything (see `IDEATION-TODO.md` → Tech decisions). What
> ideation owns is the **behavior vocabulary**: a small set of reusable archetypes
> that regions draw from and reskin. A region's bestiary = these templates +
> region theming (Arghanzza already demonstrates this — its enemies are these
> archetypes wearing forest body-horror).

Each archetype names a **role + AI pattern + tell**, and how **concentration**
(`../Mechanics/hive-concentration.md`) upgrades it. As a region heats up, the same
body climbs the ladder: Husk → Active → (merge) → Node.

### Husk archetypes (dumb, routine-bound)

- **Drone** — wanders a fixed routine (the doc's "farming dead fields / stamping
  papers"). Aggros late, attacks slowly, telegraphs hard. The baseline filler.
- **Sentinel** — anchored to a spot/object (gate, door, hearth, banquet seat).
  Doesn't chase far; punishes approach. Area-denial, not pursuit.
- **Swarmer** — weak alone, only dangerous in numbers (the "~200 dumb threads"
  swarm pressure). Encourages crowd control and *not* over-killing.
- **Mimic-lure** — stays hidden and bait-calls using overheard NPC/sword lines
  (Arghanzza's Whisper Mimics are this template). Information hazard, not a brawler.

### Active archetypes (a thread is being spent here — smart, can speak as the hive)

- **Skirmisher** — repositions, baits, punishes greed; uses cover and timing. The
  Active that *reads the player*. Will taunt with personal/contextual lines.
- **Caster** — uses glyph/hive effects at range (region-flavored: roots, possessed
  masonry, silt, stopped clockwork). Forces approach under pressure.
- **Brute** — slow, heavy, stagger-resistant; a wall the player must respect. Often
  a Sentinel husk that the scheduler "woke up."
- **Coordinator** — buffs/directs nearby husks (calls Swarmers in, repositions
  Sentinels). Kill-priority target; removing it slumps the local group's IQ.

### Node archetypes (merged threads → pseudo-personality; mini-bosses/generals)

The five role-words already in this doc map to fight behaviors:

- **General/Commander** — battlefield control: spawns/levitates, commands husk
  groups, body-horror set-pieces (Arghanzza's Hearthmother sits here).
- **Infiltrator / Mimic-Node** — the Mimic-lure escalated to a thinking deceiver.
- **Negotiator** — fights with *words* as much as force; may offer the player
  things (a soul-duel social layer, ties to `../Sword/soul-duels.md`).
- **Assassin** — burst, stealth, route-anticipation (Arghanzza's Mud-Remembered
  Husks are a husk-tier preview of this).

### Concentration upgrade ladder (how a body moves up the templates)

| Concentration | What the same body becomes |
| --- | --- |
| Low (spread thin) | mostly **Drones/Sentinels**, occasional **Swarmer** packs |
| Rising (drift/over-kill) | **Actives** appear — Skirmishers, Casters, a Coordinator |
| High (baseline or driven) | dense Actives + **Nodes**; **environmental occupation** turns on |
| Endgame | almost every body is an Active/Node; little distance to the hive |

This ladder is the *behavior* expression of the thread scheduler
(`../Mechanics/hivemind-threads.md`); the numeric expression is production tuning.

### Per-region authoring recipe

A region bestiary is authored as: **pick archetypes + set the concentration
baseline + apply region material theming.** Example (Arghanzza → these templates):

- Mud-Remembered Husks = **Assassin-flavored Husk** (route anticipation).
- Pine-Bound Bodies / Root Hands = **Sentinel** (anchored, area-denial).
- Whisper Mimics = **Mimic-lure**; Thorn Choir = **Swarmer** + **Coordinator** link.
- Breathing Pine Sentinel = **Brute/Sentinel** miniboss; Hearthmother = **General Node**.

## Severance (true death)

Some enemies — especially actives/nodes — **cannot be truly killed** by beating
the body alone. They require a **soul duel** where the player becomes the
sword-girl and wins 1v1. Winning **severs** the body from the hive. (See
`../Sword/soul-duels.md`.)

## Environmental occupation (midgame reveal)

The hive can occupy **environments, not just bodies** — trees, mud, rocks, paths.
This is introduced in **Arghanzza** (see `Arghanzza-bestiary.md` and
`../Regions/Arghanzza/`). Recall from lore: early plague could possess rocks,
dirt, sludge, armor, weapons (`../Lore/ancient-history.md`).

## Open

- ~~Which named NPCs can become Named Nodes~~ — **resolved: none.** The living
  can't be infected (`../Mechanics/plague-and-infection.md`); Named Nodes are
  hive-grown merged threads, not people. The only human channel is the
  **soft-infected** temporary takeover.
- ~~Generic husk/active stat blocks and behaviors per region~~ — **behaviors
  resolved** as the reusable **archetypes** above (Husk/Active/Node templates +
  concentration ladder + per-region recipe). **Stat blocks (numbers) are decided
  at implementation** — production tuning gated on the engine, not ideation.
