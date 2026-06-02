# Sword Dialogue System — Pipeline & Functions

> How the sword's LLM-backed lines are produced **deterministically**. The LLM is
> a line-writer, not a decision-maker.

## Core stance

The sword's LLM should **not** be open-ended. Best implementation is
**deterministic / function-driven.**

> The LLM should be treated as a **line writer**, not the source of truth and not
> the game-state manager.

### Hard rules

- Do **not** let the LLM choose the function.
- Do **not** let the LLM choose canon truth.
- Do **not** let the LLM manage Trust.
- Do **not** let the LLM decide quest state.
- **Let it do voice and phrasing only.**

## The pipeline

1. Game state comes in.
2. System checks whether sword speech is **allowed** (sheathed? combat? etc.).
3. A **seeded dice roll** selects a dialogue function from the **eligible** set.
4. The function determines: intent, tone, output length, allowed knowledge, and
   few-shot examples.
5. **Canonical game data** determines what truth may be revealed.
6. The **LLM writes the final line** in the sword's voice.
7. Output is validated, displayed, and **metrics are updated.**

## Seeded determinism

Use **seeded deterministic randomness**, not uncontrolled random behavior.

Seed from stable inputs: player ID, scene ID, sword state hash, event ID,
interaction count. This gives variety while staying reproducible.

## Dialogue functions

- **WARN** — danger, traps, hive signs, ambushes.
- **IDENTIFY** — object / sign / body interpretation.
- **GUIDE** — hint / walkthrough direction.
- **CORRECT** — when the player misunderstands or misrepresents sword knowledge.
- **REBUKE** — spam, misuse, sheathing during important moments, forced
  prompting.
- **REMEMBER** — lore fragments near Anchors or memory triggers.
- **ASK** — the sword asks the player a question (unlocked by Trust).
- **COMFORT** — rare, high Trust, restrained support.
- **WITHHOLD** — insufficient Clarity/Trust; refusal or partial answer.
- **SILENCE** — no LLM call, or an authored UI line only.

## Eligibility by context

| Context | Eligible functions |
| --- | --- |
| Sheathed | SILENCE / muted-event logging only |
| Seek Accord | IDENTIFY, GUIDE, REMEMBER, WITHHOLD, REBUKE |
| Combat | WARN, CORRECT, REBUKE, SILENCE |
| High-Trust idle | ASK, REMEMBER, COMFORT, GUIDE |
| Low Trust + repeated prompting | REBUKE, WITHHOLD, SILENCE |

## Canonical truth as payloads (outside the LLM)

Truth is stored as data, gated by Clarity. Example for a sign/object:

```text
object_id
surface_description
true_type
public_belief
allowed_reveal_by_clarity
```

### Example reveal tiers (a sign/mark)

| Clarity | Reveal |
| --- | --- |
| 0 | "old mark" |
| 1 | "not plague" |
| 2 | "custody seal" |
| 3 | "witness containment" |
| 4 | "used during first severance" |

### Example hint payload tiers

| Tier | Hint |
| --- | --- |
| 0 | "there is another route" |
| 1 | "look near kitchen" |
| 2 | "kitchen drain bypasses gate" |
| 3 | "use oil on hinge before opening" |
| 4 | "avoid opening during bell cycle; hive listens then" |

Remember the split:

- **Trust** → hint generosity (which tier she's willing to give).
- **Clarity** → whether she can understand/interpret it at all.
- **Resonance** → how much she can say.

## Validation

Output must be validated before display (length within Resonance budget, no
canon beyond allowed Clarity, in-voice). Then update metrics.

See `metrics-clarity-trust-resonance.md` and `voice-and-brow-touch.md`.
