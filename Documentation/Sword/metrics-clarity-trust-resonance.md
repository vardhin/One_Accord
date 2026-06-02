# Sword Metrics — Clarity, Trust, Resonance

> The three primary metrics that gate the sword's helpfulness as a diegetic
> guide. Intentionally implementation-friendly.

## The sword as diegetic guide ("Counsel")

The sword can function as an in-game guide / walkthrough / hint system — but
**not** as an always-on UI assistant. Frame it as **Counsel** (or similar
in-world concept). She provides hints, warnings, translations, quest reminders,
route suggestions, tactical advice, and lore interpretation — gated by metrics.

> The sword is a guide because she knows. She helps because she trusts. She
> explains because she has Clarity. She continues because she has Resonance.

## The three metrics

### Clarity = RAG / knowledge access

What she is **able to understand and reveal**. Maps to **retrieval scope**.

- Low Clarity: only immediate perception and vague fragments.
- Higher Clarity unlocks: local facts → regional knowledge → ancient lore →
  girl-related lore → eventually forbidden/endgame truths.

### Trust = conversational permission / rate limit

How much she **cooperates** after attention is gained. Maps to **conversational
access and turn limits.**

- Low Trust: speaks when she wants, minimal answers, or permits only one
  triggered comment.
- Higher Trust unlocks: player replies → one-question exchanges → short
  conversations → eventually a limited real chat window.

### Resonance = token / output budget

**How much she can say.** Maps to **output-token / session-token budget.**

- Low Resonance: silence, one-word warnings, or very short lines.
- Higher Resonance: longer comments, multi-sentence hints, short exchanges →
  eventually longer conversation windows.

## How they combine

- **Trust** determines hint **generosity**.
- **Clarity** determines whether she can **understand / interpret** the info.
- **Resonance** determines **how much** she can say.

## Worked examples

### Seek Accord near a quarantine mark

| State | Line |
| --- | --- |
| Low Trust / low Clarity | "Old. Misused." |
| Medium Trust | "That is not a plague mark." |
| High Trust / high Clarity | "Custody seal. The village carved plague law over it later." |

### Hints

| State | Line |
| --- | --- |
| Low Trust | "Read the wall." *(intentionally cruel — the hero is illiterate)* |
| Medium Trust | "The wall says west gate. You want the drainage stairs." |
| High Trust | "The west gate is bait. Take the drainage stairs, but oil the hinge first." |

## Related combat/relationship metrics

Trust also factors into combat. There are additional state metrics that live
mostly in combat — **Attunement** (combat compatibility — distinct from the
dialogue Resonance above), Sync, Autonomy, Resentment, Fatigue, Cooperation. See
`../Mechanics/relationship-stats.md` for the full set and how they rise/fall.
