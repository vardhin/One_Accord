# One Accord — Design Overview

> Status: the **framework** is largely settled (the spine, the subsystem designs,
> the caps/tiers/grammars/archetypes — all indexed in `GLOSSARY.md`). The **content**
> those frameworks hold is still largely unideated: most regions, buildings, NPCs,
> quests, progression, spells/weapons, and the endgame. That content design is the
> bulk of remaining ideation, tracked in build-dependency order in `IDEATION-TODO.md`
> (Regions → Buildings & Mechanics → NPCs → Quests → Progression → Spells & Weapons →
> Endgame), followed by the **ideation→production bridge** (engine, data formats,
> tooling, roadmap — mostly deferred until content is far enough along). This file is
> the entry point. Each subsystem lives in its own folder.

## One-line shape

A dense-region 2D action-social RPG set in a post-human world where most people
are husks of a single distributed hive mind. Surviving settlements are few,
hardened, and politically/logistically difficult to unite. The player's only
true weapon is a sentient rusty sword with its own memory, standards, goals, and
inner body. The sword and the hive are the two deep agents; neither treats the
player as chosen — only as a high-log-density entity among many.

The defining inversion of the setting: an old hero **sealed** the hive, so **the
living can no longer be infected** — there is no bite-risk, no incubation, no
"don't get infected." The dread is moved elsewhere: scarcity, a thin settled
population, and the **soft-infected** (people the sealed hive can still puppet for
a blackout, undetectable until late-game Light). See
`Mechanics/plague-and-infection.md`.

The premise is **stalemate, not salvation.** The world works but **cannot grow** —
no more food, no expansion past the husk, no pushing the hive back. The player is
not a savior; they are the **breaking point**, special only as the **first to trust
the sword.** And the title is a choice: there are **two** soul-sword accords (the
player's rusty one, and the true maiden who guards herself at the mountain Sword Sanctum),
and you may keep **One Accord** — the other pursues its own path. The deeper
metaphysics — deities as **ascended souls**, the hive as a **Sauron-like possessor**,
glyphs as the deities' **hidden indirect channel** — live in `Lore/premise-and-the-one-accord.md`
and `Lore/the-deities-and-the-soul-economy.md`.

## Design intent

- Not a D&D wrapper. Not "Soulslike with different lore."
- Aim for a new systemic identity — an eventual "x-like" based on deep mechanics,
  not surface aesthetics.
- 2D RPG at roughly Stardew Valley presentation scale, but not necessarily cozy.
- Structure is Dark Souls–like: a handful of dense authored regions (target
  **~7–8 dense + 3–4 mini**) with quieter traversal corridors between them. Not a
  huge open world. The **lore-demanded region set** is catalogued: Magizhee (mid
  starter/hub), Vendur (dense — the sword-girl's birthplace/trade hub), the Training
  Camp (mid, coming-of-age settlement), Vengarz Hold (mid mobile stronghold south of
  Rosetta), the Rosetta ruins (dense research ground-zero), the Ancient Deity Sanctum
  (mini, first Light glyph), the mountain Sword Sanctum (true-sword maiden), and
  Arghanzza (mini, the post-ferry threshold that forks the hive side). —
  `Regions/region-set.md`, `Regions/world-structure.md`
- Scale inspiration for settlements and tutorial: Fallout: New Vegas / Fallout 3
  (first settlement is Goodsprings-scale).

## The world in brief

- Most of humanity is already huskified. The plague is **history, not an active
  spread sim**: a manuscript-clockwork society couldn't feed thousands, so famine
  already settled the population to a thin, post-famine stillness (~400 alive, ~200
  ever seen in play). See `Regions/world-structure.md`.
- Survivors are post-collapse, cockroach-resilient: suspicious, procedure-bound,
  culturally adapted. They are not naive villagers. The old three-day quarantine is
  now a **Checkup** (screening for the soft-infected, since turning is impossible).
- The hive is **one mind on a finite thread budget** (`Mechanics/hivemind-threads.md`),
  dynamically allocating attention across husks, possessed matter, and soft-infected
  people. Killing its weak bodies forces it to **merge threads** into smarter
  husk-commanders — your progress sharpens the enemy (the tragic loop).
- ~40 named NPCs total (a hard cap); only some deeply simulated. The world feels
  large because most former human places are now empty, ruined, or husk-occupied.

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

- `Lore/` — ancient history & the sealed divinity, the hero & true Soul Sword,
  sword-girl backstory, setting/tech level (manuscript-clockwork), literacy lore.
- `Player/` — player premise (a Courier-style nobody), opening/tutorial
  (Three Nights Outside the Gate).
- `Sword/` — the sword as NPC: combat agency, the Clarity/Trust/Resonance metrics,
  Seek Accord & Voice Links, the deterministic dialogue pipeline, upgrades &
  identity, soul duels, glow/detection.
- `Mechanics/` — **the spine: the hivemind thread scheduler** (`hivemind-threads.md`)
  and its local face (`hive-concentration.md`); combat (Soulslike + consent); kill
  resolution (the four-tool economy: plain metal / fire / silver / soul-sword
  severance); Stillpoint; plague/seal/soft-infected model; literacy; log &
  agent-memory; village/union; forge & upgrades; relationship stats.
- `Regions/` — world structure, Magizhee starter settlement, `Arghanzza/`,
  `Vengarz/`, and `Vendur/`
  (deep subfolders). Only these three regions are concluded.
- `Npcs/` — NPC tiers, the Hivemind deep agent, the Core Five starter NPCs, core
  named roster, system NPC roles & facilities.
- `Enemies/` — hive enemy design (husks/actives/nodes + reusable archetypes),
  Arghanzza bestiary.
- `Glyphs/` — glyph system (elements × operators grammar, Light kill line,
  Telugu decoding), energy & stamina (the dyadic food→sword-bar economy),
  `spells/` (the 386-build tables + `generate_spells.py` scaffold, hand-authored).
- `genre-and-themes.md` — the descriptor-stack genre identity & thematic axes.
- `vibe-lines.md` — the canonical principle/vibe lines.
- `GLOSSARY.md` — single source of truth for named systems/vocabulary (one
  canonical term per concept, with source doc).
- `Production/` — the ideation→production bridge. `vertical-slice-spec.md` defines
  v0 (Three Nights + starter settlement + first sword bond) and the local-model
  stance (LFM2-8B-A1B as a pure language interface).
- `IDEATION-TODO.md` — the content-ideation worklist (build-dependency order) plus
  the production bridge; what's left before building.

## What's settled vs. what's open

**Settled (framework).** The genre identity, the spine (thread scheduler), the
seal/soft-infected model, the four-tool kill economy, the glyph grammar & classes,
forge levels, the sword metrics, the NPC cap & tiers, the enemy archetypes, and a
clean canon pass — all locked and indexed in `GLOSSARY.md`.

**Open (content) — the bulk of remaining ideation.** The framework decisions above
are mostly *empty containers*. Still to design, in build-dependency order
(`IDEATION-TODO.md`):

- **Regions & world structure:** only 3 of ~11 regions concluded; no connectivity
  map yet.
- **Buildings & mechanics:** building vocabulary + which systems live where.
- **NPCs:** only the Core Five + role-slots authored against the 40-named cap.
- **Quests:** greenfield — no quest taxonomy or main spine yet.
- **Progression:** the unifying spine across forge/Voice Links/glyphs/bond/union
  doesn't exist as one system yet.
- **Spells & weapons:** tier-0 spells authored; tiers 1–4 mostly scaffold; weapon
  forms and companion weapons not concretized.
- **Endgame:** shape recorded (one Hivemind, Mahabharata-scale war); the design is
  deferred.

**The production bridge** (engine, data formats, save, tooling, roadmap) comes
*after* that content. Early de-risking is done: the **vertical-slice spec** and
**MVP feature cut** are written (`Production/vertical-slice-spec.md`), and the local
model is chosen (**LFM2-8B-A1B**, a pure language interface; Zaya forsaken).
