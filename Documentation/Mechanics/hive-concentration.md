# Hive Concentration Mechanic

> Identified as one of the strongest genre pillars. The enemy scales because you
> are removing places for its mind to hide.
>
> **This is the *local face* of the [thread scheduler](hivemind-threads.md).** The
> Hivemind is an AI that dynamically allocates a finite pool of threads;
> "concentration" is simply *where it has chosen to spend them.* Allocation is the
> cause, concentration the visible effect. Read `hivemind-threads.md` for the
> engine; this doc covers how that allocation reads per-region in play.

## The core idea

The hive has **finite bodies** and **finite attention** (its **threads** —
`hivemind-threads.md`).

- When there are **many husks**, the hive is **spread thin** — most bodies are
  dumb.
- As husks are **reduced**, the hive has **fewer bodies** to distribute attention
  across. Remaining bodies are **more likely to become active** — smarter,
  stronger, more dangerous, more personal. Mechanically: freed threads get
  **re-allocated denser**, and under sustained pressure they **merge** into fewer,
  far smarter allocations (husk-commanders → ultimately one) — see
  [the thread arc](hivemind-threads.md).

## The progression

- **Early game:** too many of them.
- **Midgame:** "that one knew my name."
- **Late game:** every remaining one is looking.
- **Endgame:** there is little/no distance between hive and body.

## Why this matters

> The enemy does not scale because of arbitrary RPG scaling. It scales because the
> player is removing places for its mind to hide.

This makes "clearing trash mobs" a **strategic act** with a cost: each husk you
remove concentrates the enemy. There is genuine tension between thinning the horde
and provoking sharper intelligence.

The cost is paid concretely through [kill resolution](kill-resolution.md): most
kills (ordinary weapons) are **loans** — the body re-bodies mutated and the region
drifts hotter — while only **fire** and **soul-sword severance** truly draw the
body-count down (which itself concentrates the will). There is no free move.

## Per-region concentration: authored baseline + drift

Concentration is **per region**, and it has two parts:

- **Authored baseline** — each region ships with a designed starting concentration,
  set by story order and intended difficulty. Region order ≈ ascending baselines.
  A region cannot fall **below** its baseline; that floor is its nature.
- **Drift** — the player pushes concentration **up** by fighting there. Over-killing
  (especially [plain-metal kills](kill-resolution.md)) raises it, and the damage is
  **sticky**: a region you over-cleared stays hotter when you return.

So the player's restraint is a live, per-region variable. You can't make a place
safer than its baseline, but you can absolutely make it worse.

## Environmental occupation is the general high-concentration look

When a region's concentration (by baseline **or** by player-driven drift) crosses a
threshold, the will starts soaking into **matter** — mud, rock, walls, floor — not
just bodies. This is the early-plague horror (it could possess rocks, dirt, sludge,
armor; see `../Lore/ancient-history.md`) returning *locally*.

- **Arghanzza is not a special biome.** It is simply the first region whose
  **baseline is already past the threshold** — so the player meets possessed matter
  there early.
- **Any region can be driven there.** Over-fight a low-baseline region and its walls
  can start breathing — the player can *Arghanzza-ify* a place by fighting wrong.
- The **material look varies** by region: organic forest (Arghanzza), possessed
  masonry, water/silt, tarnished silver and stopped clockwork, etc.

## Husks vs. Actives vs. Nodes

(Full detail in `../Enemies/hive-enemy-design.md`.)

- **Husks** — infected bodies on low instinct/routine. Dumb.
- **Actives** — bodies **currently piloted** by the hive. Smart, dangerous,
  strategic, can speak as the same entity.
- **Named Nodes** — bodies that held hive attention long enough to develop a
  pseudo-personality: mini-bosses, generals, infiltrators, negotiators, assassins.

## Relationship to the endgame

The endgame should be the literal expression of this mechanic: a place with
fewer husks than expected, where almost every remaining body is active. (No
endgame region is designed yet — see `../Mechanics/plague-and-infection.md`.)

The hive ultimately loses not by killing all husks, but because **humanity stops
being available as bodies** (union, protocols, severance, quarantine, bells,
defenses, and the sword's severance ability).
