#!/usr/bin/env python3
"""Generate the spell scaffold for One Accord's glyph grammar.

A carrier/emitter has up to four active glyph slots. The 10 learnable glyphs split
into two roles:

* 5 element sigils: the thing magic is made from.
* 5 modifiers: operators that shape element sigils.

Modifiers do NOT make spells by themselves. Repeating the same element sigil also
does NOT make a new spell; duplicates only shift stat balance/tuning. Multi-sigil
spells need at least one modifier, because "Heat Flow" is not a complete magical
statement while "Heat + Flow" or "Heat Flow +" is.

Valid spell identities therefore have:

* at least one distinct element sigil;
* no standalone modifiers;
* no repeated-symbol variants;
* at least one modifier whenever there is more than one element sigil;
* at most four total slots, which means the largest element mix is 3 sigils
  plus 1 modifier.

The spell scaffold is:
    tier 1:  C(5,1)                                      =   5 spells
    tier 2:  C(5,1)C(5,1)                                =  25 spells
    tier 3:  C(5,1)C(5,2) + C(5,2)C(5,1)                 = 100 spells
    tier 4:  C(5,1)C(5,3) + C(5,2)C(5,2) + C(5,3)C(5,1) = 200 spells
                                                            330 spells total

Tier 0 is kept as a single bare-blade baseline entry, but it is not a spell.

This script writes one markdown file PER TIER into the `spells/` subfolder:

    spells/tier-0.md   no-glyph carrier (not a spell)        1 baseline
    spells/tier-1.md   one-slot spells                       5 spells
    spells/tier-2.md   two-slot spells                      25 spells
    spells/tier-3.md   three-slot spells                   100 spells
    spells/tier-4.md   full four-slot spells               200 spells

Each section is one build (empties shown explicitly) with blank fields
(Effect / Class / Energy / Notes) to fill in over time. Splitting by tier keeps
each file small enough to author without scrolling past unrelated entries.

IMPORTANT — do not blindly overwrite hand-written effects:
    The default behaviour writes a fresh scaffold to a NEW folder
    (`spells.generated/`) so you never clobber `spells/` once you have started
    authoring effects into it. Diff/merge by hand, or pass --force to overwrite
    the `spells/` files directly (only safe before you have authored anything).
"""

import argparse
from itertools import combinations, product
from pathlib import Path

# The 10 learnable glyphs. Order here only affects display/numbering, not the math.
ELEMENTS = ["Heat", "Flow", "Air", "Earth", "Light"]
MODIFIERS = ["Addition", "Subtraction", "Spread", "Focus", "Bind"]

SLOTS = 4  # max active glyphs held at once; see glyph-system.md
EMPTY = "(empty)"  # an unfilled slot — under-loaded blades are real builds

# Spell out small integers as words (the doc wants the count "written by word").
_ONES = [
    "zero", "one", "two", "three", "four", "five", "six", "seven", "eight",
    "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen",
    "sixteen", "seventeen", "eighteen", "nineteen",
]
_TENS = [
    "", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy",
    "eighty", "ninety",
]


def number_to_words(n: int) -> str:
    """Spell an integer 0..999 in words (enough for all tier counts)."""
    if n < 20:
        return _ONES[n]
    if n < 100:
        tens, ones = divmod(n, 10)
        return _TENS[tens] + (f"-{_ONES[ones]}" if ones else "")
    hundreds, rest = divmod(n, 100)
    head = f"{_ONES[hundreds]} hundred"
    return head if rest == 0 else f"{head} {number_to_words(rest)}"


TIER_TITLES = {
    0: "Tier 0 — No-Glyph Carrier (not a spell)",
    1: "Tier 1 — One-Slot Spells",
    2: "Tier 2 — Two-Slot Spells",
    3: "Tier 3 — Three-Slot Spells",
    4: "Tier 4 — Four-Slot Spells (full blade)",
}


def valid_spell_builds(tier: int) -> list[tuple[tuple[str, ...], tuple[str, ...]]]:
    """Return valid spell identities for a slot tier.

    Each identity is a pair of distinct element sigils and distinct modifiers.
    Repeats are intentionally omitted because they tune strength rather than
    creating a new spell entry.
    """
    if tier == 0:
        return []

    builds = []
    for element_count in range(1, min(len(ELEMENTS), tier) + 1):
        modifier_count = tier - element_count
        if modifier_count > len(MODIFIERS):
            continue
        if element_count > 1 and modifier_count == 0:
            continue
        if element_count > 3:
            continue

        for elements, modifiers in product(
            combinations(ELEMENTS, element_count),
            combinations(MODIFIERS, modifier_count),
        ):
            builds.append((elements, modifiers))
    return builds


def build_tier(tier: int) -> str:
    """Render the scaffold markdown for a single slot tier."""
    builds = valid_spell_builds(tier)
    count = 1 if tier == 0 else len(builds)

    lines = []
    lines.append(f"# {TIER_TITLES[tier]}")
    lines.append("")
    if tier == 0:
        lines.append(
            "> One (1) baseline entry — a carrier with no glyphs. This is kept "
            "for balance/reference, but it is not a spell."
        )
    else:
        lines.append(
            f"> {number_to_words(count).capitalize()} ({count}) "
            f"spell{'s' if count != 1 else ''} — valid **{number_to_words(tier)}**"
            f"-slot identities made from element sigils plus optional/required "
            "modifiers. Modifiers cannot stand alone; two or more element sigils "
            "require at least one modifier."
        )
        lines.append(
            "> Repeats are allowed in play (two Heats = a hotter Heat) but do "
            "**not** make a new spell — they only shift stat balance, so duplicates "
            "are not separate entries. See `../generate_spells.py` and "
            "`../glyph-system.md`."
        )
    lines.append("")
    lines.append(
        "Fill each entry over time: a name, what it does, its **class** "
        "(loan / kill / utility), energy cost, and any other key info. We are NOT "
        "authoring everything at once — append effects as they are discovered."
    )
    lines.append("")
    lines.append("---")
    lines.append("")

    width = max(len(str(count)), 2)
    if tier == 0:
        builds_to_render = [((), ())]
    else:
        builds_to_render = builds

    for i, (elements, modifiers) in enumerate(builds_to_render, start=1):
        n_elems = len(elements)
        n_mods = len(modifiers)
        n_empty = SLOTS - n_elems - n_mods
        shape = f"{n_elems}E / {n_mods}M / {n_empty}∅"
        slots = list(elements) + list(modifiers) + [EMPTY] * n_empty
        num = str(i).zfill(width)
        lines.append(f"## T{tier}-{num} — {number_to_words(i).capitalize()}")
        lines.append("")
        lines.append("- **Symbols:** " + " · ".join(slots) + f"  ({shape})")
        lines.append("- **Name:** _(unnamed)_")
        lines.append("- **Effect:** _(TODO)_")
        lines.append("- **Class:** _(loan / kill / utility — TODO)_")
        lines.append("- **Energy:** _(TODO)_")
        lines.append("- **Notes:** _(TODO)_")
        lines.append("")

    return "\n".join(lines) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--force",
        action="store_true",
        help="overwrite the spells/ files directly (only safe before authoring)",
    )
    args = parser.parse_args()

    here = Path(__file__).parent
    out_dir = here / ("spells" if args.force else "spells.generated")
    out_dir.mkdir(exist_ok=True)

    grand_total = 0
    spell_total = 0
    for tier in range(SLOTS + 1):
        text = build_tier(tier)
        count = 1 if tier == 0 else len(valid_spell_builds(tier))
        grand_total += count
        if tier > 0:
            spell_total += count
        target = out_dir / f"tier-{tier}.md"
        target.write_text(text, encoding="utf-8")
        label = "baseline" if tier == 0 else "spells"
        print(f"  tier-{tier}.md  →  {count} {label}")

    print(
        f"Wrote {spell_total} spells + {grand_total - spell_total} baseline "
        f"across {SLOTS + 1} files to {out_dir}/"
    )
    if not args.force:
        print("(Wrote to spells.generated/ to protect hand-written effects; "
              "use --force only on fresh files.)")


if __name__ == "__main__":
    main()
