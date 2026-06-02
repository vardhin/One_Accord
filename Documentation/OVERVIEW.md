# One Accord — Design Overview

> Status: ~30–40% ideated. The basic spine is in place; many specifics are open.
> This file is the entry point. Each subsystem lives in its own folder.

## One-line shape

A dense-region 2D action-social RPG set in a post-human world where most people
are husks of a single distributed hive mind. Surviving settlements are few,
hardened, and politically/logistically difficult to unite. The player's only
true weapon is a sentient rusty sword with its own memory, standards, goals, and
inner body. The sword and the hive are the two deep agents; neither treats the
player as chosen — only as a high-log-density entity among many.

## Design intent

- Not a D&D wrapper. Not "Soulslike with different lore."
- Aim for a new systemic identity — an eventual "x-like" based on deep mechanics,
  not surface aesthetics.
- 2D RPG at roughly Stardew Valley presentation scale, but not necessarily cozy.
- Structure is Dark Souls–like: a handful of dense authored regions (target ~7,
  not committed) with quieter traversal corridors between them. Not a huge open
  world. **Three regions are concluded so far: the starter settlement,
  Arghanzza, and Silvergate (the sword-girl's birthplace, now a trade hub).**
- Scale inspiration for settlements and tutorial: Fallout: New Vegas / Fallout 3
  (first settlement is Goodsprings-scale).

## The world in brief

- Most of humanity is already huskified by a plague-like hive condition.
- Survivors are post-collapse, cockroach-resilient: suspicious, procedure-bound,
  culturally adapted. They are not naive villagers.
- ~40 named NPCs total; only some deeply simulated. The world feels large
  because most former human places are now empty, ruined, or husk-occupied.

## The five core pillars

1. **Dyadic weapon embodiment** — the only true weapon is a sentient NPC, and in
   certain fights you *become* her inner body.
2. **Concentrated/distributed hive enemy** — one mind across finite bodies;
   reducing husks reduces coverage but increases attention density and active
   intelligence.
3. **Post-plague survival culture / village mobilization** — progress depends on
   convincing, organizing, defending, linking settlements, and developing
   prevention/severance systems.
4. **Context/log-based agent memory** — major agents act from bounded logs and
   world-centric memory, not omniscient quest flags.
5. **Possession vs. partnership** — the central thematic axis (see
   `genre-and-themes.md`).

## Folder map

- `Lore/` — world history, divinities, plague origin, the hero, the true Soul
  Sword, sword-girl backstory, setting/tech level, literacy lore.
- `Player/` — player premise, opening/tutorial (Three Nights Outside the Gate).
- `Sword/` — the sword as NPC: agency, metrics, Brow-Touch, Voice Links,
  dialogue pipeline, upgrades, soul duels, glow/detection.
- `Mechanics/` — combat, kill resolution (mutation/fire/severance), Stillpoint,
  hive concentration, plague model, literacy system, log/agent-memory system,
  village/union system, forge & upgrades, relationship stats.
- `Regions/` — world structure, starter settlement, `Arghanzza/` and `Silvergate/`
  (deep subfolders). Only these three regions are concluded.
- `Npcs/` — NPC tiers, the Hivemind agent, starter NPCs, core named roster.
- `Enemies/` — husks/actives/nodes, hive enemy design, Arghanzza bestiary.
- `Glyphs/` — glyph system, glyph master progression, companion magic weapons.
- `genre-and-themes.md` — genre identity candidates and thematic axes.
- `vibe-lines.md` — the canonical principle/vibe lines.

## Open questions (not yet decided)

- Final genre name.
- Exact roster of the ~40 named NPCs beyond the starter five.
- Only three regions are concluded (starter settlement, Arghanzza, Silvergate);
  no others are named or designed.
- Endgame specifics beyond "humanity stops being available as bodies."
