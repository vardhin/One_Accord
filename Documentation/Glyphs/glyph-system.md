# Glyph System

> Glyphs power magic weapons, hand-cast spells, and certain sword techniques. The
> system is built on **slot limits** and a **glyph grammar** (elements ×
> modifications), inspired by Witch Hat Atelier. Progression is driven by an NPC
> (the glyph master) who LEARNS over the game, not a static vendor.

## Three separate writing systems

These are **distinct languages**, not one language at different depths. Do not
conflate them:

| System | What it is | Role |
| --- | --- | --- |
| **Human Chinese** | The mundane written language of survivors | Literacy mechanic — read notes, ledgers, warnings (see `../Mechanics/literacy-system.md`) |
| **Glyphs** | A separate set of operative **symbols** | Magic — produce effects from a carrier/emitter |
| **Ancient scripture** | The **old form of glyphs**, written in **Telugu** | The deep/divine root; mostly lore + endgame decoding |

Glyphs are NOT part of human Chinese. The ancient scripture is the archaic form
of the *glyphs*, not of Chinese — it is what the cleric and the hero decoded, and
it renders in **Telugu** (literal script, the glyph counterpart to "Chinese is the
mundane language"). Recovering and decoding ancient (Telugu) inscriptions is how
the glyph master deepens beyond surface glyphs. (See `../Lore/ancient-history.md`,
`../Lore/the-hero-and-true-sword.md`.)

## The glyph grammar (elements × modifications)

There are **~10 learnable glyphs**: **5 element sigils** and **5 modifications**.
Effects are **emergent combinations**, not a flat list — a small symbol set
generates a large operative space (the Witch Hat Atelier principle: a sigil sets
the element, a sign modifies it, and a flipped/opposite sign yields the opposite
effect).

### 5 elements (the sigil — *what* the magic is)

| Element | Base reading |
| --- | --- |
| **Heat** | thermal energy |
| **Flow** | water / fluid / current |
| **Air** | wind / pressure / motion |
| **Earth** | mass / stone / weight |
| **Light** | radiance / sense / **silver-equivalent kill line** (locked) |

*(Element roster is **locked canon**: Heat / Flow / Air / Earth / Light. **Light is
committed** as the silver-equivalent anti-hive kill line — see "Light, silver, and
the kill line" below.)*

### 5 modifications (the sign — *how* the magic behaves)

Modifications are **operators** applied to one or more element sigils. They do
**not** make spells by themselves: `Addition` alone is incomplete, and `Heat Flow`
without an operator is also incomplete. Multi-sigil spells need at least one
modifier (`Heat + Flow`, `Heat Flow +`, etc.) so the grammar says what the sigils
are doing together.

The clearest operator pair is **Addition / Subtraction**, which flips polarity:

- `Heat + Addition (+)` → **fire** (add heat)
- `Heat + Subtraction (−)` → **freezing chill** (remove heat)

The **5 operators (locked canon):**

| Modifier | Effect on the element |
| --- | --- |
| **Addition (+)** | amplify / project / give the element |
| **Subtraction (−)** | remove / invert / drain the element (the "reversed sign") |
| **Spread** | area / diffusion / spin |
| **Focus** | concentrate / pierce / line |
| **Bind** | attach / persist / ward (a lasting effect rather than a burst) |

So `Flow + Focus` ≠ `Flow + Spread`; `Air + Subtraction` pulls a vacuum where
`Air + Addition` pushes a gust. The same ~10 glyphs cover hundreds of valid spell
identities without treating modifiers-alone or repeated sigils as new spells.

> **Resolved:** the 10 glyphs are a **fixed set**, and Addition / Subtraction are
> **two distinct entries** in it. So "reversed sign = opposite" is the **fiction /
> mnemonic** — Subtraction *reads* as Addition's mirror (mystically the same root
> sign inverted), but in practice the player learns and inscribes it as its own
> glyph. **No orientation-sensitive input engine** is required (you don't reverse
> the effect by drawing a glyph flipped). Poetic grammar, simple implementation.

## Worked effect table (5 elements × 5 modifiers)

> The canonical named effects the grammar produces. Names are a working draft; the
> **classes** are load-bearing and tie directly to the four-tool kill economy
> (`../Mechanics/kill-resolution.md`).
>
> These 25 single-element × single-operator effects are the **anchors** for the
> full spell tables (`spells/tier-0..4.md`, 330 spell identities plus the bare
> blade baseline). Policy: the **scaffold is generated**, every **effect is
> hand-authored manually over time** (all 330 spells, no auto-fill) — see
> `spells/README.md`. When authoring the matching entries, reuse the names below;
> don't coin a second name.

### Medium does not change the spell

The glyph formula is the spell. The carrier/emitter — sword, staff, hand, or some
other implement — does **not** create a separate version of the effect. This is
not a weapon-scaling moveset table.

`Heat + Addition` always means the same thing: fire/heat is added and projected.
On a sword, activation can make the blade blaze **and** release a heat blast; if
held, it keeps releasing fire as a heat wave. On a staff, the same formula emits
the same heat blast from the staff. On a hand, it emits from the hand. The medium
only changes origin point, collision feel, animation, and how the particle stream
inherits movement.

Implementation note: model glyph output as particles/fields emitted from the
active carrier. If the carrier swings, thrusts, points, or drifts, the particles
inherit that motion and can read as a projectile, arc, cone, trail, or wave. The
spell table still has **one** `Heat + Addition` entry.

### The class rule (why this table matters, not just flavors)

A glyph fires from its active carrier/emitter. By kill resolution, plain metal is
*always a loan*, but the glyph output can change what the contact counts as. So
every glyph answers one question first — does it change *what tool the hit counts
as*, or only *how hard the loan lands*?

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
| **Heat** | **Ember Edge** — *kill-class (fire)*: emits a fire/heat blast; hold to sustain it into a heat wave. On a sword, the carrier also blazes. True death on the dumb, **backfires on Actives** | **Killfrost** — drain heat; stagger + brittle (loan, control) | **Hearthwave** — broad sustained fire/heat wave, crowd-stagger (loan) | **Lance-of-Coals** — armor-piercing burning thrust (*kill-class if target is dumb*) | **Smolder-Ward** — carrier stays hot, ignites on next contact (kill-class, delayed) |
| **Flow** | **Tidecut** — water-jet pressure, knockback (loan) | **Cold-Needle** — chill needle; the healer's weapon, slows incubation in allies | **Mistveil** — diffusion; drops detection glow (stealth — see `glow-and-detection.md`) | **Hollowpoint** — focused current, floods/drowns one body (loan) | **Brine-Bind** — salt-water ward; *the salt circle as a glyph* (anti-incubation) |
| **Air** | **Gust** — push, gap-opener (loan) | **Vacuum-Pull** — pull bodies in, group them (sets up a sweep) | **Scatter** — wide pushback (crowd control) | **Whistlecut** — line of wind, ranged tick (loan) | **Stillwind-Bind** — local silence; suppresses bell-call / active-call (tactical) |
| **Earth** | **Weight** — heavy hit, the broadsword's friend (loan, +stagger) | **Hollow** — drain mass; shatters brittle/frozen targets (combo finisher) | **Quake** — area stagger/knockdown (crowd) | **Boring-Spike** — pierces stone & possessed masonry (Arghanzza/Vendur matter) | **Anchor-Bind** — root self; immovable parry stance (defensive) |
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
- **Energy-brutal.** The Light kill glyphs simply have a **much higher per-fire
  base cost** than any other glyph (the additive rule still holds — they're just an
  expensive glyph to fire), so each shot is a real sacrifice of her reserve, not a
  spam tool. The cost lives in the *firing*, not a separate penalty system.
- **Same backfire.** Like physical silver, they perma-kill the dumb and **backfire
  on Actives** — scarcity by cost, not by prohibition.

So the grammar *has* a clean-kill answer, but it's the one you almost never want to
fire. Light utility glyphs (Dawnspread, Lantern-Bind, Dusklock) are cheaper and
surface earlier; only the kill line is gated.

## Mixing elements — freely allowed, no penalty

Co-inscribing any elements in a valid statement (e.g. `Heat + Flow`, `Heat Flow +`,
or a larger sigil mix with an operator) is **freely allowed** and carries **no
special cost**. There is no misfire, backlash, Attunement penalty, **or mixing
energy surcharge.** A mixed blade costs exactly the same as a clean blade with the
same number of glyphs.

This follows the **additive energy rule** (`energy-and-stamina.md`): glyph cost is
**linear in glyph count** — N glyphs cost N× a single glyph's base, regardless of
whether they're compatible. If one glyph costs 20, two cost 40, three cost 60, four
cost 80.

What disciplines "load it up" is therefore **not** a mix penalty but the two
standing costs that apply to *every* extra glyph:

- **Additive energy drain** — a 4-glyph blade burns 4× per the rule above, so it
  empties her bar fast and reverts to penalized plain steel (empty-bar fallback).
- **The strength tax** — each glyph is ~−15% base strength whether it's firing or
  not (a 4-glyph blade is ~−60%).

So mixing is a creative freedom, not a trap; build size is what costs you. The
grammar cap is four slots, which means the largest mixed spell is **three element
sigils plus one modifier**.

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
- Sword form changes slot capacity, reach, origin points, collision geometry, and
  how emitted particles inherit motion. It does **not** create separate spell
  effects; `Heat + Addition` remains `Heat + Addition` on every form.
- Form is set by **forging, casting, reforging** (ties directly to forge levels
  and the sword's consent over her own body — see below).

## The energy ↔ power balance

Glyphs draw **energy**. The core tradeoff:

- **More glyphs on a given mass** → stronger and/or **mixed/emergent** effects,
  but **higher energy cost**.
- **More mass / larger carrier** → more slot capacity and different emission
  geometry, but not a different spell list.

There is also a flat **strength tax: each inscribed glyph lowers the blade's base
physical strength by ~15%** (a 4-glyph greatsword is ~−60% base, but carries the
most magic). The tax persists even when her stamina is empty, so an over-glyphed,
unfed sword is doubly weak. Full rules in `energy-and-stamina.md`.

This mirrors two Witch Hat Atelier rules:

- *Bigger seal = stronger* → more **mass** raises a glyph's ceiling.
- *Several small linked spells can beat one big spell* → loading **4 glyphs** on a
  greatsword can out-power 1 huge glyph, at the cost of energy and stability.

So the player is always trading **form, glyph count, emission geometry, physical
strength, and energy** against each other. There is no strictly-best build; it's a
balance.

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
**not core-bearing**, so they can carry glyphs with their own slot limits and
emission origins. Their weapon type does **not** rewrite the spell.
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

## Surfacing & decoding ancient Telugu scripture

> **Resolved:** Telugu is **not** a player lexicon. It does **not** reuse the
> Chinese literacy UI (`../Mechanics/literacy-system.md`). Almost no one alive can
> read it; the player never learns it character-by-character.

**Who can read Telugu, ranked:**

- **The sword — the best reader alive.** She was **present during the
  renaissance**: she saw how the early glyphs were discovered, and she knew how
  **people were made into weapons** (the soul-sword rite — her own origin, see
  `../Lore/sword-girl-backstory.md`, `../Lore/the-hero-and-true-sword.md`). She is
  a *primary source*, not a scholar reconstructing from fragments.
- **The glyph master** — reads **bits and pieces**; reconstructs slowly through
  research, tools, and cross-referencing recovered inscriptions.
- **A few very rare NPCs** — fragmentary, partial, often wrong (hermits, the last
  who remember, a corrupted scribe-line).

**How it surfaces in play:**

- The player **recovers** Telugu inscriptions in the world (ruins, the hero's
  trail, deep regions) — as *objects/evidence*, not vocabulary to memorize.
- Meaning comes from **bringing them to a reader.** The **sword is the strongest
  decode path**, but she is **gated by relationship** — reading the thing that
  *ended the world and made her a sword* is loaded for her, so deep Telugu reads
  unlock through **Clarity/Trust/Resonance** (`../Sword/metrics-clarity-trust-resonance.md`),
  not on demand. She may **refuse**, **partially read**, or **withhold**.
- The **glyph master** is the slower, safer, always-available path: hand over an
  inscription and they grind out a partial decode over time — the route that
  *doesn't* cost sword relationship but is weaker and incomplete.

**What decoding outputs** (never "reading fluency"): new glyphs, the **Light kill
line** (Silverlight, Pierce-of-Day — Telugu-gated by construction above), lore
truth about the renaissance / the rite / the hero, and glyph-master progression.

**Why this is the right shape:**

- It makes the **sword a narrative authority**, not just a weapon — she is the
  living memory of how the world's magic *and* her own curse came to be.
- It gates deep power through the **sword relationship**, reinforcing "you
  negotiate with your weapon" instead of adding a second literacy grind.
- It keeps the danger theme intact: **using the grammar is touching the thing that
  ended the world**, and the best translator is its first victim.

## Connection to lore

The ancient scripture (Telugu, the old form of the glyphs) underlies all of this
— decoding is how the cleric released the hive and how the hero learned flame
spells. Glyph codes recovered in the world are fragments of that deeper system.
The danger is thematic: **using the grammar is touching the same thing that ended
the world.** (See `../Lore/ancient-history.md`, `../Lore/the-hero-and-true-sword.md`,
and `../Mechanics/literacy-system.md`.)

## Open

- Tuning: how much more energy mixed-element builds cost vs. clean ones, and how
  high the Light-kill-line energy cost sits relative to a normal glyph.

### Resolved

- **Element roster + operators LOCKED.** Canon: **5 elements** (Heat / Flow / Air /
  Earth / Light) × **5 operators** (Addition / Subtraction / Spread / Focus / Bind).
  Draft disclaimers removed.
- **"Reversed sign = opposite" = fiction only.** Addition/Subtraction are two
  distinct glyphs in the fixed 10; the mirror idea is the mnemonic, not an
  orientation-based input mechanic. No flip-to-reverse engine needed.
- **Worked effect table** — the 5×5 named-effect table is now drafted above, sorted
  by loan-class / kill-class / severance-class.
- **Light = silver-equivalent kill line**, but Telugu-gated, late, and
  energy-brutal so it never trivializes scarce silver (see "Light, silver, and the
  kill line" above).
- **Energy cost is ADDITIVE & mixing is free.** Glyph cost is linear in count
  (N glyphs = N× base); a mixed blade costs the same as a clean blade of the same
  size — **no mix penalty.** Discipline comes from additive drain + the ~15%/glyph
  strength tax. The **Light kill line** is just a glyph with a very high per-fire
  base. (See "Mixing elements" above and `energy-and-stamina.md`.)
- **Telugu decoding = its own system, sword-led** (not the Chinese lexicon UI).
  The **sword** is the best reader (she lived the renaissance); glyph master + rare
  NPCs read fragments; player recovers inscriptions and brings them to a reader.
  Output = glyphs / Light line / lore, gated by sword relationship. See "Surfacing
  & decoding ancient Telugu scripture" above.
