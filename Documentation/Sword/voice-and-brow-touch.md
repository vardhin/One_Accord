# Sword Voice, Seek Accord & Voice Links

> How the sword communicates, when, and how the player requests it.
>
> **Canonical name:** the brow-touch input action is **Seek Accord** (gesture:
> touch the sword to your brow to seek her alignment/attention). The word *Accord*
> ties to the title and the sword bond; the **verb phrase** keeps it distinct from
> the combat **accord roll** (cooperation roll — `../Mechanics/combat-system.md`).
> Older drafts called this "Brow-Touch"; that is now just the *gesture*, and
> **Seek Accord** is the action.

## Private speech only

Nobody else can hear the sword. Her speech is **private to the holder/player.**
It is not outward audio; NPCs do not hear it.

- To use sword knowledge socially, the player must **relay, hide, distort, or
  lie** about it through dialogue choices.
- The sword can privately react if the player misrepresents it: *"I said no such
  thing."*

## Normal interaction states

- **Held / drawn:** the sword may speak privately whenever it wants.
- **Sheathed / not held:** the sword is muted or inaccessible.
- **Seek Accord:** the player requests private speech / comment / chat.
- **High-Trust Seek Accord:** opens a limited full conversation window.

## The sheath is a physical mute

If sheathed, the sword's outward/private output is **muted**.

- The sword still **knows** it was muted and can later react when unsheathed.
- The game logs important muted events in a **compact buffer**, then passes them
  to the LLM on unsheathe.
- Example reactions: *"You hid my voice from that conversation." / "You discussed
  the mark without me." / "Convenient silence."*
- **Do not call the LLM for every muted event** — compress and summarize.

### Implementation states

```text
is_sheathed
can_speak
mute_reason
events_observed_while_muted
time_muted_seconds
voice_state: unsheathed | sheathed | suppressed | overdrawn | anchored
```

The sword should know whether it's sheathed/unsheathed/muted/unmuted. If
unsheathed after relevant muted events, it can **auto-comment** in the UI,
subject to cooldowns and relevance thresholds.

## Seek Accord (the special input action)

Touching the sword to the **head/brow**. Not public speech — a **private request
for inward attention.** Canonically named **Seek Accord** (the *brow-touch* is the
gesture; *Seek Accord* is the action).

- Cleanest meaning: **Seeking Accord guarantees attention, not cooperation.**

Behavior by Trust:

- **At zero Trust:** still works (the gesture itself is a risky/intimate act of
  trust), but only forces a **brief comment** — does not unlock full
  conversation.
- **At high Trust:** the same action opens a **real chat window.** Trust controls
  how much she cooperates *after* attention is gained.

> The player can always request the sword's attention. They cannot always earn
> its answer.

## Voice Link progression

Communication starts one-sided and opens up over the game.

- **Voice Link I — Reflex only.** Danger barks and short private warnings. No
  player replies.
- **Voice Link II — One-sided voice.** Comments after events; no conversation.
- **Voice Link III — Triggered comment.** Player can request one comment via
  Seek Accord, even at zero Trust.
- **Voice Link IV — Single reply.** The sword allows one response/answer.
- **Voice Link V — Two-turn exchange.** Player can ask/follow up briefly.
- **Voice Link VI — Short channel.** In safe/anchored conditions, brief talk.
- **Endgame — Limited full chat.** ~Two minutes under the right conditions.
  **Never infinite.**

## Rebuke lines (repeated/abusive prompting)

> "Again?" / "No." / "You mistake contact for command." / "Look with your own
> eyes." / "I am not a map nailed to your hand." / "I am not a bell you strike
> for answers." / "Knocking is not ownership."

See `dialogue-system.md` for how these are selected deterministically.
