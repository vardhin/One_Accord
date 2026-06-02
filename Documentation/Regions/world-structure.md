# World Structure

> Not a huge open world. Not one tiny village. A handful of dense regions with
> quieter traversal corridors between them. Dark Souls structure, Stardew
> presentation scale, Fallout: New Vegas settlement scale.

## The shape

Places come in **three tiers**, distinguished by **size + population + story
weight** together (not one axis alone):

- **Dense** — large, populous, deeply-simulated **hubs you return to.** Target
  **~7–8** dense regions total.
- **Mid** — a real but smaller settlement with a focused cast (Goodsprings-scale).
- **Mini** — small **single-arc spokes** you visit for one problem: a handful of
  people or a single household.
- Target **3–4 mini** places.

Plus **quieter walking/traversal spaces** between them (decompression corridors,
below).

> **Three regions are concluded so far, and now tiered:**
>
> - **Vendur** — *dense.* The sword-girl's birthplace estate, now a trade hub — an
>   earth-rampart **hillfort of ~13 trader households** read as **two coupled nodes**
>   (upper fort / exposed lower town). "Dense" still means band-scale (~55–60 souls).
> - **Magizhee** — *mid.* Goodsprings-scale first settlement, placed between the
>   militia zone and Vendur.
> - **Arghanzza** — *mini.* A small village (deeply-developed in its own right,
>   but mini in scale).
>
> Everything else is undecided. (The old 7-name "skeleton" draft — Last Market,
> Mill Fields, etc. — is **deleted**; it was pointless scaffolding. New regions get
> designed concretely when there's a reason, under the ~7–8 dense / 3–4 mini
> targets.)

## Current square-map skeleton

The latest geography is deliberately simple: imagine a square map split by a
river flowing roughly **top-left → bottom-right**. The river divides the early
left-side human pocket from the hotter right-side hive ground.

- **Bottom-left / left / bottom edges:** huge mountain ranges. Husks do not
  arrive from these edges. The bottom-left-most high peak holds the **Sword
  Sanctum**.
- **Vendur:** inside the mountain basin, still bottom-left, perfect for a
  defended hillfort. From Vendur a mountain trail becomes visible, but it stops
  an early player. Midgame lore can make the player reinterpret that blocked
  trail and return toward the Sanctum.
- **Magizhee:** starting region, diagonal-opposite **Rosetta**, located between
  the militia zone and Vendur.
- **Militia zone:** left of the river, part of the first-half game. Reachable
  early from Magizhee; militia-first naturally sends the player toward Vendur
  for supplies or support.
- **River:** hard early boundary. Crossing requires a small boat or equivalent
  midgame permission/tool.
- **Arghanzza:** right of the river and close to it, likely a mangrove-like
  transition region after the first crossing.
- **Vengarz Camp:** right side, near Rosetta but not inside it. A mid-size mobile
  wooden/tent/wagon palisade held by remnants of an old anti-hive force from the
  hero's legion.
- **Rosetta region:** right of the river, farther past Arghanzza/Vengarz and between
  the river-crossing side and the Silent Core. This is a dense old research region
  and the hive's strategic focus because it arrived from here and wants a way to
  remove the old hero's seal.
- **Silent Core:** top-right, the most hive-mind-concentrated region.

The left side is not overrun because the old hero's seal prevents new infection.
Only runaway, drifted, or low-level husks leak into the left region; that is still
enough to threaten the few hundred humans left, because the world has no slack.

## What each dense region needs

When future regions are designed, each should have:

- A **distinct mood.**
- A **local survival/social problem.**
- A **local plague/hive behavior.**
- A **settlement or ruin.**
- A **defense/logistics challenge.**
- A **sword-relevant emotional/history layer.**

## Decompression corridors

The quiet spaces between regions are **decompression corridors**: roads, fields,
bridges, riverbanks, forest paths, dead suburbs.

They let the player:

- Breathe.
- Talk to the sword.
- See distant husks.
- Escort NPCs.
- Encounter patrols.
- Feel watched.

## Why the world feels large

Most former human places are now **empty, ruined, or husk-occupied.** The world is
**wide in implication** but **focused in gameplay.** ~40 named NPCs total; only
some deeply simulated.

> Named NPCs are rare because personhood is rare now.

## Why the world is small: famine already settled it

The low population is not an active crisis — it is **history.** After the binding,
a **few thousand** survived the *plague* — but a manuscript-clockwork society
**cannot feed thousands.** No potatoes, no fertilizer, no canning at scale, no
high-yield grain; ruined farmland and too few hands. So:

1. They **fragmented into small bands** to spread the foraging load.
2. Small bands were easy prey — the smaller, **more concentrated** hive (see
   `../Mechanics/hive-concentration.md`) picked them off over roughly a decade.
3. Survivors **re-merged** out of necessity into the handful of defensible regions
   that persist today — a net **~400 alive, ~200 ever seen** in play.

**The famine is over; equilibrium is reached.** Population shrank until it matched
what the land can feed. So the felt tone is a **thin, settled, post-famine
stillness** — not desperate scrambling.

- Everyone is **food-self-sufficient to a point**: each place has its own gardens,
  fishing spot, goat, mushroom cellar, terrace — small, personal, *enough*. There is
  **no food economy**; trade is for irreplaceables (silver, tools, maintenance
  knowledge, seed varieties, medicine).
- **There is no slack.** A region doesn't fear hunger; it fears **disruption** of a
  balance it can't rebuild — lose a few people and it may drop below viability and
  have to merge or die. The hive is the one thing that can still tip it.
- Quarantine holds **one or two people at most** — the population is simply that
  scarce, which makes every single life statistically enormous.

## Files in this folder

- `starter-settlement.md` — **Magizhee**, the Goodsprings-scale first settlement
  (**mid**).
- `Arghanzza/` — the deeply-developed forest village (**mini**); its own subfolder.
- `Vengarz/` — the mobile stronghold near Rosetta (**mid**); its own subfolder.
- `Vendur/` — the sword-girl's birthplace estate, now a trade hub (**dense**);
  its own subfolder.
- `connectivity-map.md` — the square-map adjacency graph, corridor/gate model,
  river threshold, and current route shape.
- `region-set.md` — the **lore-demanded** catalogue: every region the story requires
  (Vendur, the Rosetta ruins, the deities' underground sanctum, the mountain Sword Sanctum,
  Arghanzza-as-pass-through) with tier, heat, and quest-hook.

## Status

Three concluded regions, tiered: **Vendur** (dense), **Magizhee**
(mid), **Arghanzza** (mini). Targets: **~7–8 dense + 3–4 mini.** No further regions
named or designed yet — they get authored concretely when there's a reason, not as
abstract skeleton.
