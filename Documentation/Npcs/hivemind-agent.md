# The Hivemind (Tier 0 Deep Agent)

> One of the two deep agents. A single NPC wearing many bodies. For the
> god-origin lore see `../Lore/ancient-history.md`; for the population scaling
> see `../Mechanics/hive-concentration.md`.

## What it is

The hivemind is a **single NPC.** Every **active** husk is the same NPC wearing a
different body.

- **Husks** = many bodies.
- **Active husks** = bodies currently piloted/occupied by the hivemind.

## Knowledge is bounded, not omniscient

The hive is **not omniscient by default.** It knows through:

- Bodies, observation, **soft-infected takeovers**, overheard information,
  strategically gathered logs. (It cannot infect the living — see
  `../Mechanics/plague-and-infection.md` — so its human reach is the soft-infected
  backdoor, not new conversions.)

It should **not** know things it had no access to.

> Hivemind knowledge should feel **invasive, not intimate.**

## Sword vs. hive (the contrast)

| Sword | Hive |
| --- | --- |
| Knows through **closeness** | Knows through **surveillance** |
| Becomes **intimate** | Becomes **omnipresent** |
| Wants **partnership** | Wants **absorption** |

## The player is not special to it (at first)

The player is **one variable** among villages, unions, defenses, routes, food,
infected bodies, survivors, and the sword. The player becomes important **only
through repeated consequences** (log density).

The hive may care **more about another NPC** than the player if that NPC is
strategically more important (a healer, union organizer, etc.).

## What the hive tracks

Villages · leaders · healers · union organizers · routes · defenses · infected
bodies · strategic threats · social weaknesses.

## Strategic questions (its "goals")

Because the model is "preserve and exploit," not "infect everyone" (see
`../Mechanics/plague-and-infection.md`):

- How do I preserve bodies?
- Where do I **allocate threads**, and which bodies should I actively pilot
  (`../Mechanics/hivemind-threads.md`)?
- Which **soft-infected** backdoors are worth taking over, and when?
- Which survivor networks should I destabilize?
- When should I reveal intelligence?
- When should I stay as dumb husks?
- How do I stop villages from learning severance / Light-detection methods?

## Context priorities (for the LLM/memory system)

Regional concentration / thread density · available active bodies · known
soft-infected backdoors · recent losses · highest-threat villages/NPCs · observed
player actions (if any) · defense networks · union cohesion · targets of
opportunity · known sword capabilities · **thread allocation**. (See
`../Mechanics/hivemind-threads.md`, `../Mechanics/log-and-agent-memory.md`.)

## Behaviors over the game

- **Early:** spread thin; mostly dumb husks.
- **Mid:** an active "knows your name."
- **Late:** every remaining body is watching.
- **Endgame:** no distance between hive and body.

The hive can also **teach literacy dangerously** — e.g., "open" before "do not"
(see `../Mechanics/literacy-system.md`).
