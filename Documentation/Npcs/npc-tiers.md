# NPC Depth Tiers

> Not everyone is deeply simulated. If everyone is deep, the world becomes
> exhausting. Personhood is rare now — so depth is rare too.

## Target

**No more than ~40 named NPCs total.** Not everyone needs deep LLM context; some
have random/basic dialogue. This is good, not a limitation.

> Named NPCs are rare because personhood is rare now.

## The tiers

### Tier 0 — Deep persistent agents

**The Sword and the Hivemind.** Full memory, long-context callbacks, strategic
adaptation, relationship/world arcs, system authority.

- Sword → `../Sword/sword-as-npc.md`
- Hivemind → `hivemind-agent.md`

### Tier 1 — Core named NPCs (~10–12)

Schedules, goals, relationships, local memory, and system authority.

Examples: innkeeper, blacksmith, union organizer, militia captain, healer, farmer
leader, priest/ritualist, trader, infected child/teen, former-wielder candidate,
village elder, corpse-burner.

(See `core-named-roster.md`.)

### Tier 2 — Secondary named NPCs (~15–25)

A job, a home, a social link, a village opinion, **limited reactive memory.** They
remember major events.

### Tier 3 — Ambient NPCs

Basic Skyrim-style short lines, rumors, greetings, fear reactions, schedule
behavior. They exist to make the world feel populated — **not** to become full
chat partners.

## How memory differs by tier

All NPCs can be backed by the same local model with context switching, but they
get **very different context budgets.** The deep agents have world-centric,
hierarchical memory (see `../Mechanics/log-and-agent-memory.md`); ambient NPCs may
have little more than canned lines and a few local flags.

## The two deep agents do NOT center the player

Critical for both Tier 0 agents:

- The **sword** may care about former wielders or nearby people more than the
  player.
- The **hive** may care about a strategically important NPC more than the player.
- The player becomes salient only through **log density** — consequences,
  overlap, repetition.

> The player is not the subject of memory. The player is an entity inside memory.
