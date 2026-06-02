# Glyph Energy — Stamina, Food & the Sword's Bar

> The energy that fires glyphs is **player stamina = calories**. There is no
> abstract mana pool. The economy is **dyadic**: the player feeds the sword, the
> sword spends. For the glyph grammar/slots this energy drives, see
> `glyph-system.md`.

## Energy is food

The player must **eat** to have energy. Calories are the root resource.

### Two player stamina pools

| Pool | Role | Regen |
| --- | --- | --- |
| **Short stamina** | Moment-to-moment combat — dodge, swing, parry, sprint | Fast, in-fight |
| **Long stamina** | Deep calorie reserve | Slow; refilled by **eating food** |

- **Short stamina fights.** It is the soulslike combat breath and does **not**
  feed glyphs. You cannot dump your combat wind into magic.
- **Long stamina charges.** Glyph energy comes out of the **long** reserve, by
  sacrificing it during meditation (below). Feeding the sword literally costs you
  your deep reserve — and therefore costs you **food**.

## Charging the sword (meditation)

The player can **sit and meditate** to transfer **long stamina → the sword's
stamina bar**.

- The transfer is **variable**: it depends on **how much the sword is willing/able
  to accept** right then — not a fixed conversion rate.
- Acceptance scales with the relationship (Trust / Attunement / Fatigue, see
  `../Mechanics/relationship-stats.md`). A fatigued, resentful, or distrustful
  sword accepts **little**; an attuned, willing one accepts **generously**.

## The sword has her own stamina bar

For the Soul Sword loop, glyphs do **not** fire directly off the player. They fire
off **the sword's own stamina bar**, which the player keeps topped up.

This is the sword's special dyadic economy, not a rule that changes spell identity.
The same glyph formula can be emitted from a sword, staff, or hand; the carrier
defines the energy source and particle origin, not a new spell effect.

- She is an **NPC dependent on you**: you must **feed her from time to time**, like
  a companion who needs food. Neglect her bar and her glyphs go cold.
- In normal play she spends her bar to power glyphs as expected.
- In emergencies she may spend **deeply / by her own choice** — "usually she
  won't; she will if she wants to." This agency is hers, not an automatic system.
  It is the mechanism behind the **~95% emergency-cooperation override** in
  `../Mechanics/combat-system.md`: she chose to spend herself to save you both,
  which is exactly why the aftermath carries tension
  (*"I moved because I had to. Not because I forgave you."*).

## Empty bar — reverting to plain steel

When the sword's stamina bar hits **zero**, glyphs go **dead** and she behaves as a
**normal unglyphed sword** — she still swings, with no magic. This is a clean,
non-punishing fallback: you are not disarmed, you are back to baseline steel until
you feed her again.

But see the strength tax below — an empty *inscribed* sword is plain steel **with
the penalty still on it**, so a heavily-glyphed sword that runs dry is a notably
**weak** plain weapon. Keeping her bar fed is therefore real upkeep, not optional.

## The glyph strength tax

Inscribing a glyph on a weapon **reduces that weapon's base physical strength by
~15% per glyph.** This is the cost that keeps "load it up" from being a free
upgrade.

| Glyphs | Approx. base-strength penalty |
| --- | --- |
| 0 (plain) | — |
| 1 (dagger core) | ~ −15% |
| 2 | ~ −30% |
| 3 | ~ −45% |
| 4 (greatsword, max) | ~ −60% |

- The penalty comes from the glyphs being **inscribed**, not from them firing — so
  it **persists even when her bar is empty.** An empty 4-glyph greatsword is at
  ~−60% strength **and** has no magic: doubly weak. (See empty-bar fallback above.)
- This gives lean builds a real identity: a **1-glyph dagger core** pays only ~15%,
  keeps near-full base strength, and is trivial to keep charged — versus a 4-glyph
  blade that hits hardest *with magic up* but collapses hard when neglected.
- *(15% is a working number; tune later.)*

## What makes the Soul Sword different

A normal **silver sword with glyphs** has a **fixed** energy capacity for its size
— predictable, no variance. The **Soul Sword** has **variance** a dead weapon
cannot:

- **If she likes you, her bar carries MORE** than a normal silver sword of the
  **same size**. Affection literally raises her energy ceiling.
- If she doesn't, she carries less, accepts your charge poorly, or refuses to
  spend on a glyph she dislikes.
- She can **tap her own reserve in emergencies by choice** (above) — a normal
  silver sword never decides anything.

So the same forge/mass/slot rules from `glyph-system.md` apply to both, but the
Soul Sword's **effective** capacity floats with the relationship where a silver
sword's is flat.

## The full chain

```text
Food
  → player LONG stamina (deep reserve)
      → meditate (variable accept, relationship-gated)
          → sword's OWN stamina bar
              → glyphs fire from her bar
                  ↑ she chooses when to spend, including emergency soul-spends

(SHORT stamina runs combat only — never feeds glyphs.)
```

## Glyph energy cost is additive (linear in glyph count)

Glyph cost scales **additively** with the number of inscribed glyphs: **N glyphs
cost N× a single glyph's base.** If one glyph costs 20, two cost 40, three cost 60,
four cost 80. (Exact base value is implementation tuning; the **rule** — linear,
not exponential — is canon.)

**Mixing is free.** Co-inscribing incompatible elements (e.g. `Heat +` and
`Flow +`) is **allowed at no extra cost** — there is **no mix surcharge**, misfire,
backlash, or Attunement penalty. A mixed blade costs exactly the same as a clean
blade with the same glyph count.

What disciplines big builds is therefore the additive rule itself plus the
**strength tax**, not a mix penalty:

- **Additive drain** — a 4-glyph blade burns 4× per fire, emptying her bar fast and
  reverting to penalized plain steel (empty-bar fallback above).
- **Strength tax** — ~−15% base strength per glyph, firing or not.

So loading up is costly because it's *more glyphs*, never because they're *mixed*.
Full grammar context in `glyph-system.md`.

### The Light kill line under this rule

The Light kill glyphs (Silverlight, Pierce-of-Day) aren't a separate system: they
are simply glyphs with a **very high per-fire base cost**, so they dominate the
additive total when inscribed and make each shot a real sacrifice of her reserve.

## Cross-links

- Glyph slots / mass / grammar this energy powers → `glyph-system.md`
- Emergency override (~95% cooperation) → `../Mechanics/combat-system.md`
- Trust / Attunement / Fatigue that gate acceptance →
  `../Mechanics/relationship-stats.md`
- Consent over her body / upgrades → `../Sword/upgrades-and-identity.md`

## Open

- Numbers: single-glyph base cost, the Light-line's high per-fire base, the
  meditation transfer curve, and how big "likes you" can push her ceiling vs. a
  silver baseline. *(The **additive rule** — N glyphs = N× base, mixing free — and
  the **direction** Light ≫ normal are locked; only the base values are tuning.)*
- Whether food variety/quality matters (different foods → different long-stamina
  yield) or it's a single calorie value.
- Whether the sword's bar visibly drains over time (the "feed her periodically"
  loop) or only drains on glyph use.
- Whether an empty bar also opens a brief **vulnerable window** / triggers her to
  ask/demand to be fed, beyond just reverting to plain steel.
- Final tuning of the ~15%/glyph strength tax and the meditation transfer curve.
