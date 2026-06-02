# Spell Tables — Authoring Policy

> The canonical list of every glyph build and its effect. This README is the
> single source of truth for **how** these tables get filled.

## What's here

`tier-0.md` … `tier-4.md` — one file per glyph-count tier, covering **330 spell
identities plus one bare-blade baseline**. Valid spells use at least one element
sigil; modifiers never make spells by themselves; two or more element sigils need
at least one modifier. The split and numbering are produced by
`../generate_spells.py`:

```text
tier 0:   1 bare-blade baseline (not a spell)
tier 1:   5 spells
tier 2:  25 spells
tier 3: 100 spells
tier 4: 200 spells
total:  330 spells + 1 baseline
```

Each entry has: **Symbols** (fixed by the scaffold) and blank **Name / Effect /
Class / Energy / Notes** to author.

## Decided policy (canon)

- **Scaffold = generated.** The 330-spell *structure* is owned by
  `generate_spells.py`. Do not hand-edit the symbol lists or numbering — regenerate
  if the grammar ever changes.
- **Effects = hand-authored, all 330 spells, manually and slowly.** Every spell gets a
  bespoke, human-written effect over time. There is **no rules-engine
  auto-fill** and **no "anchors only" shortcut** — we tackle all 330 by hand,
  incrementally, as the game needs them. This is a **long production task**, not an
  ideation deliverable; it is expected to remain in progress well past "ideation
  done."

## Authoring rules (so entries stay consistent)

Anchor every effect to the locked systems — don't invent free-floating spells:

- **Class** must be one of: **loan** (better plain-metal hit; still seeds a mutant)
  · **kill** (only builds containing `Heat + Addition` or the `Light +` kill line;
  inherit the perma-kill-dumb / backfire-on-Actives rule) · **utility** (reveal,
  ward, stealth, control). **Nothing here can sever** — severance is the sword's
  body, never an inscription. See `../glyph-system.md`.
- **Energy** follows the **additive rule**: cost is linear in glyph count (N glyphs
  ≈ N× a single-glyph base); mixing elements adds nothing extra. The Light kill
  line is just a glyph with a very high per-fire base. Exact base values are
  implementation tuning. See `../energy-and-stamina.md`.
- **Grammar validity:** modifiers do not stand alone, and unmodified multi-sigil
  strings do not make spells. `Heat` is valid; `Addition` is not. `Heat Flow` is
  not valid until an operator is present (`Heat + Flow`, `Heat Flow +`, etc.).
  With four slots, the largest element mix is **3 element sigils + 1 modifier**.
- **The 25 single-element × single-operator effects** already have canonical names
  in the `glyph-system.md` **5×5 worked table** (Ember Edge, Killfrost, Silverlight,
  Dawnspread, …). When authoring the matching Tier-2 entries, **reuse those names
  and effects** — keep the two docs in sync; don't coin a second name.
- **Duplicates aren't separate spells.** Two Heats = a hotter Heat, not a new
  entry; repeats only shift the stat balance.

## Regenerating the scaffold (danger)

`generate_spells.py` writes to `spells.generated/` by default **specifically so it
won't clobber authored effects.** Only run it with `--force` against `spells/` on
fresh, unauthored files. Once any effect is written here, regenerate to the
side folder and diff/merge by hand.
