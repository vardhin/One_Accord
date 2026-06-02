# Sword Combat Agency

> The sword is an NPC with agency in combat, not a stat-stick. For the full
> combat pipeline and Stillpoint, see `../Mechanics/combat-system.md`.

## Key principle

> You can choose violence. You cannot always choose her violence.

## Three layers of agency

1. **Engagement agency** — whether the sword participates in the action at all.
2. **Execution agency** — how well it cooperates during a valid action.
3. **Interpretive agency** — how it remembers and comments on what happened later.

## Engagement: it can refuse the swing

The sword can refuse to even allow a swing. This matters most when the player
tries to attack:

- Humans, nonhostile NPCs.
- Surrendering enemies.
- Fresh infected.
- Morally ambiguous targets.

Refusal is **not** a blunt "cannot attack humans." It **evaluates context.** It
may allow violence against humans if they are:

- Actively attacking.
- Clearly hive-compromised.
- Committing atrocities.
- Dueling by consent.
- Forcing the situation.

It may allow **nonlethal** action but refuse **lethal** execution.

### Permitted action levels

- Defend only.
- Nonlethal disable.
- One permitted strike.
- Full lethal engagement.
- Total refusal.

## Execution: the cooperation roll

After a physically valid action, a hidden roll decides **how well the sword
cooperates** — producing **hit quality**, not binary hit/miss.

Result tiers:

- Guided / perfect
- True / clean
- Dull / rough
- Late / hesitant
- Turned edge
- Refused
- Backlash

(See `../Mechanics/combat-system.md` for how cooperation level feeds these.)

## The sword can demand, too (reverse Stillpoint)

The sword is **not only a morality brake.** Sometimes **it** wants to act and the
player hesitates. It can **demand** violence, mercy, retreat, severance, or
refusal. This keeps it from being a one-way veto.

## Forcing the sword (possible but ugly)

The player can try to **dominate** the sword into acting:

- **If it succeeds:** the attack proceeds but causes **major relationship
  damage.**
- **If it fails:** the sword **locks, drops, causes stamina shock, or triggers
  backlash.**

## Interpretive agency: memory & comment

The sword **remembers** what happened and comments later — dialogue, reflections,
dreams, arguments, relationship comments. The real-time engine handles
consent/rolls/quality; the **LLM only interprets structured logs later** (see
`dialogue-system.md` and `../Mechanics/log-and-agent-memory.md`).

## Using other weapons

The player can pick other weapons later (see `upgrades-and-identity.md` and
`../Mechanics/forge-and-upgrades.md`). How the sword reacts depends on context:

- Tactical use at high Trust → may be accepted.
- Using another weapon to **bypass a refusal** and kill anyway → resentment.
- Abandoning the sword → it may return, act independently, become jealous, go
  silent, or even let another NPC carry it temporarily, depending on path.
