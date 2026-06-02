#!/usr/bin/env python3
"""Generate the spell scaffold for One Accord's glyph grammar.

A glyph is ONE of the 10 base symbols (5 elements + 5 modifiers). A blade has up to
four slots (mass-gated), and any slot may also be left EMPTY — an under-loaded blade
is a real build. A spell's *identity* is the **set of distinct real symbols** in it,
sized 0..4; remaining slots are empty.

Repeats are allowed in play (two Heats = a hotter Heat) but do NOT make a new spell —
duplicates only shift the stat balance, so they are not separate scaffold entries.

So the scaffold is every subset of the 10 symbols of size 0..4:
    C(10,0) + C(10,1) + C(10,2) + C(10,3) + C(10,4)
    =   1   +   10    +   45    +   120   +   210   = 386 builds.

This script writes one markdown file PER TIER into the `spells/` subfolder:

    spells/tier-0.md   the bare blade (no glyphs)            1 build
    spells/tier-1.md   one-glyph builds                     10 builds
    spells/tier-2.md   two-glyph builds                     45 builds
    spells/tier-3.md   three-glyph builds                  120 builds
    spells/tier-4.md   full four-glyph blades              210 builds

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
from itertools import combinations
from pathlib import Path

# The 10 base symbols. Order here only affects display/numbering, not the math.
ELEMENTS = ["Heat", "Flow", "Air", "Earth", "Light"]
MODIFIERS = ["Addition", "Subtraction", "Spread", "Focus", "Bind"]
SYMBOLS = ELEMENTS + MODIFIERS  # 10 total

SLOTS = 4  # max glyphs held at once (mass-gated; see glyph-system.md)
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
    """Spell an integer 0..999 in words (enough for 210)."""
    if n < 20:
        return _ONES[n]
    if n < 100:
        tens, ones = divmod(n, 10)
        return _TENS[tens] + (f"-{_ONES[ones]}" if ones else "")
    hundreds, rest = divmod(n, 100)
    head = f"{_ONES[hundreds]} hundred"
    return head if rest == 0 else f"{head} {number_to_words(rest)}"


def kind(symbol: str) -> str:
    return "element" if symbol in ELEMENTS else "modifier"


TIER_TITLES = {
    0: "Tier 0 — Bare Blade (no glyphs)",
    1: "Tier 1 — One-Glyph Builds",
    2: "Tier 2 — Two-Glyph Builds",
    3: "Tier 3 — Three-Glyph Builds",
    4: "Tier 4 — Four-Glyph Builds (full blade)",
}


def build_tier(tier: int) -> str:
    """Render the scaffold markdown for a single tier (subset size == tier)."""
    builds = list(combinations(SYMBOLS, tier))
    count = len(builds)

    lines = []
    lines.append(f"# {TIER_TITLES[tier]}")
    lines.append("")
    lines.append(
        f"> {number_to_words(count).capitalize()} ({count}) "
        f"build{'s' if count != 1 else ''} — every set of "
        f"**{number_to_words(tier)}** distinct base glyph"
        f"{'s' if tier != 1 else ''} drawn from the ten symbols "
        "(five elements + five modifiers). Order does not matter; the remaining "
        f"{number_to_words(SLOTS - tier)} slot"
        f"{'s' if (SLOTS - tier) != 1 else ''} are empty."
    )
    lines.append(
        "> Repeats are allowed in play (two Heats = a hotter Heat) but do **not** "
        "make a new spell — they only shift the stat balance, so duplicates are not "
        "separate entries. See `../generate_spells.py` and `../glyph-system.md`."
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
    for i, combo in enumerate(builds, start=1):
        n_elems = sum(1 for s in combo if s in ELEMENTS)
        n_mods = sum(1 for s in combo if s in MODIFIERS)
        n_empty = SLOTS - len(combo)
        shape = f"{n_elems}E / {n_mods}M / {n_empty}∅"
        slots = list(combo) + [EMPTY] * n_empty
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
    for tier in range(SLOTS + 1):
        text = build_tier(tier)
        count = len(list(combinations(SYMBOLS, tier)))
        grand_total += count
        target = out_dir / f"tier-{tier}.md"
        target.write_text(text, encoding="utf-8")
        print(f"  tier-{tier}.md  →  {count} builds")

    print(f"Wrote {grand_total} builds across {SLOTS + 1} files to {out_dir}/")
    if not args.force:
        print("(Wrote to spells.generated/ to protect hand-written effects; "
              "use --force only on fresh files.)")


if __name__ == "__main__":
    main()
