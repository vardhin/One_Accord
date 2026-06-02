# Log & Agent-Memory System

> The backbone for LLM-backed NPCs. Simulation owns world mutation; the LLM
> writes voice. Built on the local model (Zaya) with context switching.

## LLM integration premise (Zaya)

- The local model (Zaya) has been tested and works: small, fast enough, usable.
  Exact architecture details don't need further dwelling.
- **Every NPC can be backed by the same local model with context switching.**
- **But not every NPC gets equal depth.** Context management is crucial. (See
  `../Npcs/npc-tiers.md`.)

## The cardinal rule

> The log can **describe** the world, but only the **simulation** can **change**
> the world.

- Every meaningful action has a **verbal log.**
- Logs are managed, summarized, and used to build **context packets.**
- Systems update from **typed events**, not from freeform model hallucination.
- **Do NOT let LLMs directly rewrite world canon.** Simulation owns world
  mutation.

## The processing flow

```text
Action / event occurs
  → verbalized into logs
  → relevant agents receive ONLY the parts they could know
  → context builder constructs agent-specific context
  → LLM produces dialogue / interpretation / emotional framing / classification
  → typed game systems update bounded state
```

## Event logs are perspective-split

The same event produces **different versions** for different agents — each gets
only what they could know:

| Lens | Example |
| --- | --- |
| Raw event | "Player repaired the sword using grave-iron without asking." |
| **Sword memory** | "Player respected/refused/violated my body." |
| **Hive memory** | "Player avoids using sword against living greenwood." |
| **Villager rumor** | "Player was seen with farmer's sickle." |
| **World fact** | "Greenwood vines were cleared." |

More raw examples:

- "Player entered Mira's inn while carrying the rusted sword."
- "Possessed husk observed player hiding the wound on their left arm."
- "Blacksmith called the sword worthless; player stayed silent."
- "Player promised not to let the blacksmith reforge the sword."

## Hierarchical logs

Logs roll up through levels:

```text
Raw event → Scene summary → Relationship memory → World fact → Rumor
          → Trauma/obsession → Secret
```

## The most important context principle

> **No agent should have a player-centric memory.** They should have a
> **world-centric** memory in which the player is one frequent entity.

## Context priorities per deep agent

### Sword context, prioritize

Events involving sword body · player actions while carrying sword · mentions of
previous wielders · nearby people matching sword memories · unresolved promises ·
sword emotional state · current strategic need · comparison candidates.

### Hive context, prioritize

Regional infection state · available active bodies · recent losses · highest-
threat villages/NPCs · observed player actions (if any) · defense networks ·
union cohesion · targets of opportunity · known sword capabilities · attention
allocation.

## Knowledge boundedness

- The **sword** knows through **closeness** → becomes intimate.
- The **hive** knows through **surveillance** → becomes omnipresent.
- Neither knows things it had **no access to.**

> Nothing knows everything. Everything remembers something.

## Related

- NPC depth tiers → `../Npcs/npc-tiers.md`
- The two deep agents → `../Npcs/hivemind-agent.md`, `../Sword/sword-as-npc.md`
- Combat logs feeding sword dialogue → `combat-system.md`
