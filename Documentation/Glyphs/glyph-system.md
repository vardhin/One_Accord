# Glyph System

> Glyphs power magic weapons and certain sword techniques. The system is built on
> **mass-gated slots** and a **glyph grammar** (elements × modifications), inspired
> by Witch Hat Atelier. Progression is driven by an NPC (the glyph master) who
> LEARNS over the game, not a static vendor.

## Three separate writing systems

These are **distinct languages**, not one language at different depths. Do not
conflate them:

| System | What it is | Role |
| --- | --- | --- |
| **Human Chinese** | The mundane written language of survivors | Literacy mechanic — read notes, ledgers, warnings (see `../Mechanics/literacy-system.md`) |
| **Glyphs** | A separate set of operative **symbols** | Magic — bind effects to weapon matter |
| **Ancient scripture** | The **old form of glyphs**, written in **Telugu** | The deep/divine root; mostly lore + endgame decoding |

Glyphs are NOT part of human Chinese. The ancient scripture is the archaic form
of the *glyphs*, not of Chinese — it is what the cleric and the hero decoded, and
it renders in **Telugu** (literal script, the glyph counterpart to "Chinese is the
mundane language"). Recovering and decoding ancient (Telugu) inscriptions is how
the glyph master deepens beyond surface glyphs. (See `../Lore/ancient-history.md`,
`../Lore/the-hero-and-true-sword.md`.)

## The glyph grammar (elements × modifications)

There are **~10 base glyphs**: **5 elements** and **5 modifications**. Effects are
**emergent combinations**, not a flat list — a small symbol set generates a large
operative space (the Witch Hat Atelier principle: a sigil sets the element, a sign
modifies it, and a flipped/opposite sign yields the opposite effect).

### 5 elements (the sigil — *what* the magic is)

| Element | Base reading |
| --- | --- |
| **Heat** | thermal energy |
| **Flow** | water / fluid / current |
| **Air** | wind / pressure / motion |
| **Earth** | mass / stone / weight |
| **Light** | radiance / sense / silver-adjacent (see open Q) |

*(Element roster is a working draft — names/identities can shift. "Light" is a
candidate to tie into silver/anti-hive themes; not committed.)*

### 5 modifications (the sign — *how* the magic behaves)

Modifications are **operators** applied to an element. The clearest pair is
**Addition / Subtraction**, which flips polarity:

- `Heat + Addition (+)` → **fire** (add heat)
- `Heat + Subtraction (−)` → **freezing chill** (remove heat)

Working set of 5 operators (draft):

| Modifier | Effect on the element |
| --- | --- |
| **Addition (+)** | amplify / project / give the element |
| **Subtraction (−)** | remove / invert / drain the element (the "reversed sign") |
| **Spread** | area / diffusion / spin |
| **Focus** | concentrate / pierce / line |
| **Bind** | attach / persist / ward (a lasting effect rather than a burst) |

So `Flow + Focus` ≠ `Flow + Spread`; `Air + Subtraction` pulls a vacuum where
`Air + Addition` pushes a gust. The same ~10 symbols cover dozens of effects.

> Open: exact operator set and whether "reversed sign = opposite" is literal
> mirroring (draw the glyph flipped) or a distinct subtraction glyph. Leaning
> Witch-Hat-literal: a flipped sign reverses the effect.

## Worked effect table (5 elements × 5 modifiers)

> The canonical named effects the grammar produces. Names are a working draft; the
> **classes** are load-bearing and tie directly to the four-tool kill economy
> (`../Mechanics/kill-resolution.md`).

### The class rule (why this table matters, not just flavors)

A glyph fires off the sword's **steel body**. By kill resolution, plain metal is
*always a loan*. So every glyph answers one question first — does it change *what
tool the hit counts as*, or only *how hard the loan lands*?

- **Loan-class** — a better plain-metal hit (more damage, control, mobility, or
  utility). Still a loan; still seeds a mutant; still adds drift. **Most glyphs.**
- **Kill-class** — converts the hit into a real *kill-tool*. **Only `Heat +`
  (fire) and the `Light` kill line (silver-equivalent)** do this, and they inherit
  the kill-resolution rule exactly: **perma-kill the dumb, backfire on Actives.**
  This is the bridge that makes the grammar matter to concentration — and the same
  trap as carrying a torch or silver: great on trash, a *mistake* on the awake.
- **Severance-class** — **nothing in the glyph grammar can sever.** Severance is
  the girl's *body*, not her inscriptions. This is the hard floor that keeps the
  Soul Sword special and the soul duel sacred (`../Sword/soul-duels.md`).

| | **+ Addition** | **− Subtraction** | **Spread** | **Focus** | **Bind** |
| --- | --- | --- | --- | --- | --- |
| **Heat** | **Ember Edge** — *kill-class (fire)*: true death on the dumb, **backfires on Actives** | **Killfrost** — drain heat; stagger + brittle (loan, control) | **Hearthwave** — cone of heat, crowd-stagger (loan) | **Lance-of-Coals** — armor-piercing burning thrust (*kill-class if target is dumb*) | **Smolder-Ward** — blade stays hot, ignites on next contact (kill-class, delayed) |
| **Flow** | **Tidecut** — water-jet pressure, knockback (loan) | **Cold-Needle** — chill needle; the healer's weapon, slows incubation in allies | **Mistveil** — diffusion; drops detection glow (stealth — see `glow-and-detection.md`) | **Hollowpoint** — focused current, floods/drowns one body (loan) | **Brine-Bind** — salt-water ward; *the salt circle as a glyph* (anti-incubation) |
| **Air** | **Gust** — push, gap-opener (loan) | **Vacuum-Pull** — pull bodies in, group them (sets up a sweep) | **Scatter** — wide pushback (crowd control) | **Whistlecut** — line of wind, ranged tick (loan) | **Stillwind-Bind** — local silence; suppresses bell-call / active-call (tactical) |
| **Earth** | **Weight** — heavy hit, the broadsword's friend (loan, +stagger) | **Hollow** — drain mass; shatters brittle/frozen targets (combo finisher) | **Quake** — area stagger/knockdown (crowd) | **Boring-Spike** — pierces stone & possessed masonry (Arghanzza/Silvergate matter) | **Anchor-Bind** — root self; immovable parry stance (defensive) |
| **Light** | **Silverlight** — *kill-class (silver-equivalent)*: true death on the dumb, **backfires on Actives**. The **rare, late, energy-brutal** line | **Dusklock** — drain radiance; blind / break an Active's coordination | **Dawnspread** — area reveal: lights up **held vs. dumb** bodies (*reads the kill-resolution check for you*) | **Pierce-of-Day** — focused silver lance (kill-class, scarce) | **Lantern-Bind** — persistent ward-light; husks avoid it, slows local drift |

### Notes the table is built to deliver

- **Two glyphs (Ember Edge, Silverlight) are the only grammar route to a clean
  dumb-kill** — and both backfire on Actives, so a fire/silver-glyph build carries
  the same strategic trap as the physical tools. The table folds into the
  four-tool economy rather than breaking it.
- **The freeze→shatter combo** (`Heat −` Killfrost → `Earth −` Hollow) is a
  2-glyph emergent finisher that's neither fire nor silver — a *loan that hits like
  a kill*. This is the "several small linked spells beat one big spell" payoff the
  energy rules promise.
- **`Light + Spread` (Dawnspread)** literally surfaces the **dumb-vs-awake read**
  that combat calls "a real combat stake" (`../Mechanics/combat-system.md`) — at
  the cost of a slot and the strength tax. A real build decision, not a freebie.
- **Three glyphs map straight to existing world customs**, making prevention
  *castable*: Cold-Needle (healer), Brine-Bind (the salt circle), Lantern-Bind
  (ward/bell custom). This is the "preventive measures become infrastructure"
  thread (`../Mechanics/plague-and-infection.md`) made mechanical.

## Light, silver, and the kill line

The **`Light` element is the silver-equivalent kill line** — but it is deliberately
**costly, late, and rationed**, so it never trivializes the scarce-silver economy
(`../Mechanics/kill-resolution.md`):

- **Telugu-gated.** The Light kill glyphs (Silverlight, Pierce-of-Day) come only
  from recovered **ancient/Telugu scripture**, not surface glyph codes — late-game
  by construction (see ancient-history / glyph-master progression below).
- **Energy-brutal.** They cost far more from the sword's bar than any other glyph,
  so firing one is a real sacrifice of her reserve, not a spam tool.
- **Same backfire.** Like physical silver, they perma-kill the dumb and **backfire
  on Actives** — scarcity by cost, not by prohibition.

So the grammar *has* a clean-kill answer, but it's the one you almost never want to
fire. Light utility glyphs (Dawnspread, Lantern-Bind, Dusklock) are cheaper and
surface earlier; only the kill line is gated.

## Mixing incompatible elements — energy penalty only

Incompatible co-inscribed elements (e.g. `Heat +` and `Flow +` on the same blade)
are **not** a misfire or relationship mechanic. They simply cost **much more
energy** to run from the sword's bar (`energy-and-stamina.md`). No new HP-loss or
backlash system; the cost is the cost.

This is self-balancing and needs no extra punishment layer: an over-mixed blade
**drains its bar fast and reverts to penalized plain steel** — the energy doc's
existing empty-bar failure state does the disciplining for free. A clean,
single-element or compatible build runs cheap and stays charged; a chaotic mixed
build is powerful in bursts but can't sustain.

## Mass-gated slots (the sword core)

The sword has a **core**. At the core, stripped down, **she is a dagger** — the
irreducible minimum. Forging/casting adds **mass** by reshaping her into larger
forms:

```text
dagger (core) → shortsword → katana / scimitar → longsword → broadsword / greatsword
   1 glyph         2 glyphs       3 glyphs            4 glyphs        4 glyphs (max)
```

- **More mass = more glyph slots.** Core/dagger holds **1 glyph**. Maximum is
  **4 glyphs**, available only on a long/greatsword.
- Form is set by **forging, casting, reforging** (ties directly to forge levels
  and the sword's consent over her own body — see below).

## The energy ↔ power balance

Glyphs draw **energy**. The core tradeoff:

- **More glyphs on a given mass** → stronger and/or **mixed/emergent** effects,
  but **higher energy cost**.
- **More mass, fewer glyphs** → each glyph's effect is **weaker/diffused** across
  the larger body, but **cheaper** to run.

There is also a flat **strength tax: each inscribed glyph lowers the blade's base
physical strength by ~15%** (a 4-glyph greatsword is ~−60% base, but carries the
most magic). The tax persists even when her stamina is empty, so an over-glyphed,
unfed sword is doubly weak. Full rules in `energy-and-stamina.md`.

This mirrors two Witch Hat Atelier rules:

- *Bigger seal = stronger* → more **mass** raises a glyph's ceiling.
- *Several small linked spells can beat one big spell* → loading **4 glyphs** on a
  greatsword can out-power 1 huge glyph, at the cost of energy and stability.

So the player is always trading **mass (form), glyph count, effect strength, and
energy** against each other. There is no strictly-best build; it's a balance.

**Energy is player stamina (calories), spent through the sword's own bar** — the
player eats, meditates to charge the sword, and glyphs fire from *her* reserve.
The full dyadic economy lives in `energy-and-stamina.md`.

> Open: how mixing incompatible elements destabilizes (backlash? Attunement
> loss?). See cross-links below.

## Glyphs, consent, and the sentient sword

Loading glyphs onto the **sword** is never neutral — it is inscription on **her
body**:

- Accepted glyph use **raises Attunement** (combat compatibility); incompatible or
  forced glyphs **lower it** (see `../Mechanics/relationship-stats.md`).
- The sword has consent over what is done to her body — glyph inscription and
  reforging her **form/mass** is an identity-loaded upgrade at high forge levels
  (see `../Sword/upgrades-and-identity.md`).
- A natural fit for the Witch Hat "complete ring gates activation" rule: an
  **incomplete ring = the sword withholding** consent — the glyph is inscribed but
  won't fire until she closes it.
- Forge Level 4 (living/soul forge) for modifying the sentient sword may require
  **glyph master + healer** support (see `../Mechanics/forge-and-upgrades.md`).

## Glyph master progression

The glyph master should **not** start as an all-knowing master.

- May know **one glyph**, or only have **copied** something before without
  understanding it.
- Once the player brings **glyph codes and examples** (and, later, ancient/Telugu
  inscriptions), the glyph master **reverse-engineers, experiments, and eventually
  creates new glyphs independently.**

### Requirements for glyph progression

A glyph master · glyph codes · decoding · tools · test weapons · practice ·
(deeper) recovered **ancient/Telugu scripture**.

Once the glyph master learns enough, they can **forge magic weapons for teammates
too.**

## Companion magic weapons

Companion weapons can become magic weapons — **not as special as the sword**, and
**not core-bearing**, so they follow the same mass/slot logic with their own forms.
Examples mapped to roles:

- Guard **salt-pikes**
- Scout **bell-knife**
- Healer **cold-needle** (e.g. `Flow + Subtraction` → chill needle)
- Corpse-burner **ash-axe** (e.g. `Heat + Addition` → burning edge)

(See `../Npcs/system-npc-roles.md`.)

## Glyphs vs. spellcasting

These are **related but distinct** training tracks:

- **Glyphs** → glyph workshop, glyph master (item/weapon enchanting).
- **Spellcasting** → rite/spell practice hall, rite/spell instructor (the player
  or companions learning to cast — flame spells trace back to the hero's tome,
  see `../Lore/the-hero-and-true-sword.md`).

Both ultimately draw on the same operative symbols; spellcasting is casting the
grammar *unbound* (in the air, Witch-Hat-style) where glyph craft **binds** it to
a weapon body.

## Connection to lore

The ancient scripture (Telugu, the old form of the glyphs) underlies all of this
— decoding is how the cleric released the hive and how the hero learned flame
spells. Glyph codes recovered in the world are fragments of that deeper system.
The danger is thematic: **using the grammar is touching the same thing that ended
the world.** (See `../Lore/ancient-history.md`, `../Lore/the-hero-and-true-sword.md`,
and `../Mechanics/literacy-system.md`.)

## Open

- Exact element roster and the 5 operators (drafts above).
- Whether "reversed sign = opposite" is literal mirroring or a distinct glyph.
- How ancient/Telugu scripture is surfaced and decoded in-game (parallel to the
  Chinese lexicon UI, or its own thing).
- Tuning: how much more energy mixed-element builds cost vs. clean ones, and how
  high the Light-kill-line energy cost sits relative to a normal glyph.

### Resolved

- **Worked effect table** — the 5×5 named-effect table is now drafted above, sorted
  by loan-class / kill-class / severance-class.
- **Light = silver-equivalent kill line**, but Telugu-gated, late, and
  energy-brutal so it never trivializes scarce silver (see "Light, silver, and the
  kill line" above).
- **Mixing incompatible elements = energy penalty only** — no misfire or
  Attunement coupling; the empty-bar failure state does the disciplining (see
  "Mixing incompatible elements" above).
