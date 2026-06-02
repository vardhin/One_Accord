# Vertical-Slice Spec — v0 ("Three Nights")

> The first concrete answer to "what do we actually build first." This is the
> ideation→production bridge for **Scope & slice** (Section C of `../IDEATION-TODO.md`).
> Tech (engine) and the full-game production target are **deliberately deferred** —
> see "Deferred" at the bottom. This doc fixes *what is in v0* and *what each system
> looks like at slice scale*, nothing more.

## The slice, in one line

**Three Nights Outside the Gate → the starter settlement → the first sword bond.**
One settlement, the Core Five NPCs, one local crisis, one acquisition of the sword.
No second region, no union-building across settlements, no endgame.

This is the slice the docs already converge on
(`../Player/opening-and-tutorial.md`, `../Regions/starter-settlement.md`,
`../Npcs/starter-npcs.md`).

## What's IN v0

### Content

- **Tutorial zone**: the quarantine compound (Three Nights Outside the Gate),
  three-day structure — Day 1 procedure, Day 2 first sword contact, Day 3 breach.
- **Starter settlement**: Goodsprings-scale layout (yard, gatehouse, well,
  storehouse, healer shed, forge lean-to, training yard, common room, corpse pit).
- **The Core Five NPCs**: Guard Captain, Healer, Blacksmith, Trainer, Quartermaster.
- **One local crisis**: the "accused of turning before the third night" dilemma,
  with the five stakeholders pulling different ways and the sword able to contest
  the killing (Stillpoint).
- **The first sword bond**: acquisition (Day 3 protocol breach), the first
  Clarity/Trust/Resonance beats, the "Say nothing" choice.

### Systems (at slice scale)

- **The deterministic dialogue pipeline** — built for real, not stubbed. See
  "Sword & NPC language layer" below.
- **Clarity / Trust / Resonance** metrics — real, driven by typed events.
- **Log & agent-memory** — real but small: perspective-split logs, world-centric
  context packets for the sword (the only deep agent in the slice).
- **Combat** — Soulslike basics + the consent gate, enough for the breach fight and
  the Trainer's tutorial. Stillpoint present (it's the crisis pivot).
- **Forge** — Level 0→1 only (grindstone → sharpening). No deeper upgrades.
- **Seek Accord** (the brow-touch gesture) — the sword-consult verb.

## What's OUT of v0 (deferred, not cut from the game)

- Second/third regions (Arghanzza, Vendur) and all traversal between regions.
- **Village/union mobilization across settlements** — the slice has one settlement;
  the Quartermaster only *seeds* the loop.
- **Glyphs & the 386-spell tables** — no spellcasting in v0. (The Light kill line,
  glyph grammar, Telugu decoding all wait.)
- **Soul duels / phase-2 boss / merged husk-commanders** — the hive thread
  scheduler does not visibly escalate in one settlement.
- **Literacy lexicon UI** (Chinese-text learning) — out; the slice can gesture at
  it but doesn't implement the system.
- **The hive as a live deep agent** — in v0 the hive is *offscreen pressure*
  (the breach, the rumor of turning), not a second LLM-backed planner. Only the
  **sword** is a live deep agent in the slice.
- **The four-tool kill economy** at full breadth — v0 needs only plain metal +
  the sword; fire/silver(Light)/soul-severance wait.

## Sword & NPC language layer — the corrected stance

> The LLM is **only a language interface.** It does not choose functions, manage
> state, or decide canon. This sharpens, not changes, `../Sword/dialogue-system.md`.

The model receives, per line:

1. The **dialogue function** the simulation already picked (WARN, IDENTIFY, GUIDE,
   CORRECT, REBUKE, REMEMBER, ASK, COMFORT, WITHHOLD — SILENCE never calls it).
2. A few-shot **tone exemplar set** for that function (hand-authored voice samples).
3. The **accumulated context** packet (what this agent could know).
4. The **canonical payload** (the truth it's allowed to reveal at current Clarity).

The model returns **one in-voice line** fitting that situation and context. That's
it. Everything else — eligibility, the seeded function roll, the Clarity gate on
truth, the Trust/Resonance updates, validation — is **deterministic simulation
code around the model.**

### Active model (replaces Zaya)

- **LiquidAI LFM2-8B-A1B**, `Q4_K_M` GGUF quant.
  - On disk: `~/.cache/huggingface/hub/models--LiquidAI--LFM2-8B-A1B-GGUF/`.
- Served locally via **llama.cpp `llama-server` on port 8080** (OpenAI-compatible
  `/v1/...` endpoints). The game talks to it as a local HTTP language service.
- **Zaya is forsaken** — every doc that named Zaya as the model should be read as
  "the local language model," now LFM2-8B-A1B. (`../Mechanics/log-and-agent-memory.md`
  is updated; the `../game_idea` braindump keeps "Zaya" as a historical note.)

This is a small, fast MoE-ish model — appropriate precisely *because* the LLM only
writes phrasing. The deterministic shell is what makes a small model safe to use.

## v0 success criteria (what "the slice works" means)

1. A player can be processed through the three-night quarantine, take the sword in
   the Day 3 breach, enter the settlement, help (or not) each of the Core Five, and
   reach the crisis — with the crisis outcome changed by those choices.
2. The sword speaks **in voice**, with lines that are (a) produced by the real
   pipeline, (b) gated correctly by Clarity (no truth leaks above tier), and
   (c) within the Resonance length budget — using LFM2 only as the phrasing step.
3. Trust and Clarity visibly move from typed events (lying about the sword speaking,
   honoring/violating its body, repeated spam → REBUKE, etc.).
4. The "Say nothing" first-contact beat works and the sword *notices* a lie.
5. Stillpoint fires at the crisis and can contest the killing.

## Deferred (explicitly, per decision 2026-06-02)

- **Production target** (proof-of-concept-first vs. slice-as-episode-1) — **deferred.**
  We are not committing the full ~7–8-region scope yet; the slice is built first and
  the target decided later. Do not size architecture for the full game on the basis
  of this doc.
- **Engine / framework** (Godot vs. Unity vs. bespoke) — **deferred** to a later
  bridge pass. This spec is engine-agnostic on purpose.

## Related

- `../Player/opening-and-tutorial.md`, `../Regions/starter-settlement.md`,
  `../Npcs/starter-npcs.md` — the slice content.
- `../Sword/dialogue-system.md` — the pipeline this implements.
- `../Mechanics/log-and-agent-memory.md` — the memory backbone (model name now LFM2).
- `../IDEATION-TODO.md` — Section C, the rest of the bridge.
