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
> - **Magizhee** — *mid.* Goodsprings-scale first settlement; the **hub** at the
>   center of the human pocket (Old Dock north, Training Camp east, Vendur south,
>   mountains west).
> - **Arghanzza** — *mini.* A small village (deeply-developed in its own right,
>   but mini in scale).
>
> Everything else is undecided. (The old 7-name "skeleton" draft — Last Market,
> Mill Fields, etc. — is **deleted**; it was pointless scaffolding. New regions get
> designed concretely when there's a reason, under the ~7–8 dense / 3–4 mini
> targets.)

## Current square-map skeleton

The geography is fixed by the drawn map (`One_Accord_Map.png`; adjacency and gates
in `connectivity-map.md`). A square split diagonally by a **broad body of water**
running roughly **west → lower-east**. The water divides the **lower-left human
pocket** from the **upper / across-the-water hive ground**.

- **Western / southern edges:** huge mountain ranges. Husks do not arrive from
  these edges. The **SW mountain above the pocket** holds the **Sword Sanctum**.
- **Magizhee:** the **hub** at the center of the human pocket. Four early directions
  radiate from it: **north** to the husk-held Old Dock (the crossing), **west** into
  predator-mountains (toward the Sanctum, blocked early), **east** to the Training
  Camp, **south** to Vendur. East and south are the two safe early routes.
- **Old Dock:** north of Magizhee, on the water. The ferry crossing **and** a
  husk-infested chokepoint — crossing it is a midgame fight, not a free move.
- **Training Camp:** NE of Magizhee. The coming-of-age / militia hardening
  settlement; safe early direction.
- **Vendur:** south of Magizhee — the **Vendur Militia** node first, then up to the
  **Vendur Hill Fort Market** beyond it. The defended hillfort trade hub. From
  Vendur the mountain trail toward the Sanctum becomes visible but stops an early
  player; midgame lore makes the player reinterpret it and return.
- **The water:** hard early boundary. Crossing is by **ferry from the Old Dock**.
- **Arghanzza:** a short distance across the water past the landing — a mangrove-like
  possessed-matter threshold, and **the fork point of the hive side.**
- **Two paths leave Arghanzza:** a **puzzle route → Vengarz Hold → (north) Rosetta →
  (north) Silent Core**, and a **second path → Ancient Deity Sanctum**.
- **Vengarz Hold:** the human foothold before Rosetta. A mid-size mobile
  wooden/tent/wagon palisade held by remnants of an old anti-hive force from the
  hero's legion. Technically a camp; they call it a **Hold.**
- **Rosetta:** north of Vengarz Hold. A dense old research region and the hive's
  strategic focus because it arrived from here and wants a way to remove the old
  hero's seal.
- **Silent Core:** north of Rosetta (top-right), the most hive-mind-concentrated
  region.

The human pocket is not overrun because the old hero's seal prevents new infection.
Only runaway, drifted, or low-level husks leak in (the Old Dock being a standing
example); that is still enough to threaten the few hundred humans left, because the
world has no slack.

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
  river threshold, Arghanzza fork, and current route shape.
- `One_Accord_Map.png` — the drawn world map; the **visual source of truth** for
  geography.
- `region-set.md` — the **lore-demanded** catalogue: every region the story requires
  (Vendur, the Rosetta ruins, the deities' underground sanctum, the mountain Sword Sanctum,
  Arghanzza-as-pass-through) with tier, heat, and quest-hook.

## Status

Three concluded regions, tiered: **Vendur** (dense), **Magizhee**
(mid), **Arghanzza** (mini). Targets: **~7–8 dense + 3–4 mini.** No further regions
named or designed yet — they get authored concretely when there's a reason, not as
abstract skeleton.
