# Combat System — Soulslike + Sword Consent

> Soulslike first, NOT D&D-like. Dice rolls never decide whether a basic attack
> magically hits/misses. Instead a hidden roll decides how well the sword
> cooperates AFTER a physically valid action.

## Soulslike foundation

The player still needs: spacing, timing, stamina control, dodging, parrying,
animation commitment, enemy-read skill, and punish-window discipline.

What dice **don't** do: decide whether a basic swing lands.

What the hidden roll **does**: after a physically valid action, decide **how well
the sword cooperates** → produces **hit quality**, not hit/miss.

## The combat pipeline

```text
Player input
  → stamina / body state check
  → range / contact / action validity
  → sword engagement / consent gate
  → animation & hitbox execution
  → sword cooperation / accord roll
  → hit quality
  → damage / severance / status
  → structured combat log
  → possible later sword/LLM dialogue
```

## Two sword decision layers

1. **Engagement** — will it allow the action at all? (See
   `../Sword/combat-agency.md`.)
2. **Cooperation** — if it engages, how well does it cooperate?

## Cooperation roll → hit quality

Tiers: **guided/perfect, true/clean, dull/rough, late/hesitant, turned edge,
refused, backlash.**

Design intent for **low cooperation**: it should **not** make the game feel
constantly random. It mostly:

- Reduces guidance.
- Increases rough hits.
- Increases recovery.
- Disables techniques.
- Creates **contest moments only when justified** (→ Stillpoint).

**High cooperation** makes skillful actions elegant, reliable, and meaningful.

## Emergency override

When **both** sword and player are in lethal danger, cooperation can temporarily
spike very high (~**95%**). This saves the player sometimes — but creates
**post-fight narrative tension**:

> "I moved because I had to. Not because I forgave you."

Mechanically this is the sword **choosing to spend her own stamina reserve** to
save you both — "usually she won't; she will if she wants to." (See
`../Glyphs/energy-and-stamina.md`.)

## Cooldowns

Cooldowns apply to **sword interventions, NOT basic attacks.** Basic combat stays
stamina/animation-based.

Cooldown-gated assists: Guided Cut, Refusal Guard, Emergency Edge, Memory
Technique, Severance Surge, and other major sword assists.

## Structured combat logs

The engine logs (no LLM involved in real time):

- Attempted attack type, target type, target state, danger level.
- Sword consent, trust, sync, roll result.
- Repeated action, warnings ignored.
- Whether the player **bypassed the sword with another weapon.**
- Whether **NPCs witnessed** it.

The **LLM only interprets these logs later** for dialogue/reflection. (See
`log-and-agent-memory.md`.)

## Related

- Kill resolution (mutation / fire / severance) → `kill-resolution.md`
- Sword agency & forcing → `../Sword/combat-agency.md`
- The Stillpoint contest → `stillpoint.md`
- Relationship metrics (Trust/Sync/Attunement/etc.) → `relationship-stats.md`
- Soul-layer combat → `../Sword/soul-duels.md`
