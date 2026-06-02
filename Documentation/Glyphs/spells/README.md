# Spell Tables — Authoring Policy

> The canonical list of every glyph build and its effect. This README is the
> single source of truth for **how** these tables get filled.

## What's here

`tier-0.md` … `tier-4.md` — one file per glyph-count tier, covering **all 386
builds**: every subset of the 10 base symbols (5 elements + 5 operators) of size
0–4, with the remaining slots empty. The split and numbering are produced by
`../generate_spells.py` (see that file for the combinatorics: 1 + 10 + 45 + 120 +
210 = 386).

Each entry has: **Symbols** (fixed by the scaffold) and blank **Name / Effect /
Class / Energy / Notes** to author.

## Decided policy (canon)

- **Scaffold = generated.** The 386-build *structure* is owned by
  `generate_spells.py`. Do not hand-edit the symbol lists or numbering — regenerate
  if the grammar ever changes.
- **Effects = hand-authored, all 386, manually and slowly.** Every build gets a
  bespoke, human-written effect over time. There is **no rules-engine
  auto-fill** and **no "anchors only" shortcut** — we tackle all 386 by hand,
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
