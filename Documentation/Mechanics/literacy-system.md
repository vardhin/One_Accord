# Literacy System (Mechanic)

> The mechanical side. For narrative/world meaning, see `../Lore/literacy-lore.md`.

## The player starts illiterate

The player cannot read notes, ledgers, gate notices, old warnings, labels,
manuscripts, or technical records. Writing is just marks at first. They may
recognize icons / social symbols, but not script.

## Lexicon, not a leveled stat

The written language is **Chinese** (literal, not fake elvish). Literacy works as
a **lexicon system**:

- Learn a character → it is **automatically recognized everywhere** in the world.
- **Compounds** become **partially readable** before fully readable.
- No abstract "literacy level" — the player **remembers characters.**

## Word confidence states

Words can carry a **confidence state**:

```text
unknown · guessed · taught · confirmed · disputed · corrupted
```

This enables **dangerous partial literacy** as a real mechanic — a "taught" but
not "confirmed" word can be wrong; the hive can leave "corrupted" words.

## Biased teaching sources

Which words you learn first depends on **who teaches you.** Each source has a
domain vocabulary:

| Source | Sample words |
| --- | --- |
| **The sword** (first foothold, biased to her wound) | blade, blood, name, hand, oath, sever, iron, revenge, body |
| **Gate captain** | gate, outside, wait, open, close, dusk, three |
| **Healer** | sickness, fever, blood, breath, sleep |
| **Corpse-burner** | death, ash, salt, bone, burn |
| **Watchmaker** | hour, bell, early, late, tune, gear |
| **Scribe** | grammar, negation, numbers, names, particles |
| **The hive** (dangerous) | may teach "open" before "do not" |

## Danger as a feature

Partial literacy can kill. Knowing "gate" and "third bell" but **not "do not"**
can get people killed. The mechanic deliberately makes literacy **survival,
power, and risk** simultaneously.

## Sword's role

The sword gives the **first literacy foothold**, but only in a **biased way** (her
wound vocabulary). She does **not** grant full reading. Once the player has more
literacy, the sword can read signs, interpret old marks, decode quarantine rules,
recognize ancient architecture, and explain lore — but only when relationship and
systems allow (gated by Clarity — see
`../Sword/metrics-clarity-trust-resonance.md`).

## Design hooks (open)

- How are characters surfaced in the UI when partially known? (greyed glyphs,
  guessed glosses, etc.)
- How does the "corrupted" state manifest visually and in interpretation?
- Printing press as a future tech could mass-distribute primers (see
  `../Lore/setting-and-tech-level.md`).
