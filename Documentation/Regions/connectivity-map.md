# Connectivity Map — Square Layout, Gates, and Route Spine

> Companion to `world-structure.md` (tiers) and
> `../Mechanics/hive-concentration.md` (heat). This doc is **structure, not
> content**: it fixes the current map skeleton, the early route choices, the river
> threshold, and the late reinterpretation of the mountain Sanctum.

---

## The physical map

Imagine the world as a square.

- A river cuts it diagonally, flowing roughly **top-left → bottom-right**.
- The **left side of the river** is the first-half human pocket: less forested,
  more inhabited, and safer only by comparison.
- The **right side of the river** is hotter: reclaimed forest, mangrove, ruins,
  and hive-concentrated ground.
- The **left and bottom edges**, especially the bottom-left corner, are sealed by
  huge mountain ranges. Husks do not approach from those edges.
- The **bottom-left-most high peak** holds the **Sword Sanctum**.
- The **top-right** holds the **Silent Core**, the densest hive-mind region.

The big symbolic diagonal is:

```text
Sword Sanctum / mountains / old resistance  ⇄  Silent Core / forest / hive mind
```

Magizhee and Rosetta form another design diagonal:

```text
Magizhee / start / living procedure  ⇄  Rosetta / origin wound / seal mystery
```

## Current pinned regions

| Region | Tier | Map position | Role |
|---|---:|---|---|
| **Magizhee** | mid | Left of river; between militia zone and Vendur; diagonal-opposite Rosetta | Starter settlement and tutorial root. |
| **Militia zone** | mid | Left of river, near Magizhee | Early optional route; sends player to Vendur for supplies/support if visited first. |
| **Vendur** | dense | Bottom-left mountain basin | Hillfort trade hub, first dungeon, sword homecoming, full forge. |
| **Mountain trail / Sword Sanctum** | late-return destination | Bottom-left peak above/behind Vendur | Visible or implied early; blocks early player; becomes meaningful after right-side lore. |
| **River crossing** | gate/corridor | Diagonal river | Hard early boundary; requires boat, permission, or midgame route opening. |
| **Arghanzza** | mini | Right of river, close to crossing | Mangrove-like transition region and first true right-side pressure. |
| **Vengarz Camp** | mid | Right side, near Rosetta but not inside it | Mobile wooden/tent stronghold; old hero-legion remnant and Rosetta sortie base. |
| **Rosetta region** | dense | Right of river, past Arghanzza/Vengarz, before Silent Core | Hive arrival site; old research region; main lore source for seal, magic, and Sanctum reinterpretation. |
| **Silent Core** | endgame-tier | Top-right | Most hive-concentrated region; final hive-mind pressure. |

## Early-game routing

The start is simple on purpose. From **Magizhee**, the player has two sane routes:

```text
                 [Militia zone]
                       ║
                       ║
[blocked: river]══[Magizhee]══[Vendur: upper⇄lower]══[mountain trail: too hard early]
                       ║
             [blocked: husk-heavy ground]
```

- **Militia-first:** the militia asks the player to go to Vendur for supplies,
  repairs, grain, medicine, authority, or another practical need.
- **Vendur-first:** the sword suggests Vendur; Vendur opens the first dungeon and
  the sword's homecoming arc.
- **Other axes:** early player hits river, mountains, or husk-filled regions. These
  are readable world limits, not arbitrary walls.

Vendur is where the early routes converge. It is still the first major hub and the
region where the player gains enough material and emotional context to understand
that the world is older than the local survival problem.

## Midgame river threshold

The river is the true act boundary.

- The player cannot cross it freely at the start.
- Crossing should require a **small boat**, a restored ferry, permission, or a
  practical river-route solution.
- The first crossing should feel like leaving the human-maintained half of the map
  and entering ground the hive has had time to re-grow.

Right-side route sketch:

```text
[Vendur / Magizhee / Militia]══[river crossing]══[Arghanzza]══[Vengarz Camp]══[Rosetta region]══[Silent Core]
```

Arghanzza is no longer an early resource dependency. It is the first post-crossing
threshold: close to the river, wet, root-tangled, mangrove-like, and dangerous in a
different way from the left-side survival pocket.

Vengarz Camp is the human foothold before Rosetta: a mid-size mobile palisade /
tent / wagon stronghold of old anti-hive fighters. They do not live in Rosetta
because the hive is actively interfering there.

## The Sanctum return

After Vendur, the player can find or hear of the **mountain trail**. An early-level
player should be stopped by terrain, danger, traversal limits, or simple practical
impossibility.

The trail's real meaning unlocks later. The player returns because they have found
enough lore to reinterpret it, not because an NPC plainly says, "there is a magic
sword on the mountain."

Primary sources for this reinterpretation:

- Right-side lore, especially **Rosetta**.
- Old people speaking indirectly about **Silver Anarchy**, magic, old weapons with
  names, or the mountain's historical terror.
- The sword's own partial, emotional, and possibly unreliable nudges.

The midgame return reveals the **true Sword Maiden** at the Sanctum. This makes the
mountain a late-reinterpreted place, not simply a far-away final node.

## Hive pressure model on the map

The old hero's seal prevents new living infection. Because of that, the hive has
lost much of its motivation to actively invade the left-side human pocket. Its
attention bends toward **Rosetta**, the region where it arrived from, because that
is where it may find a way to remove or bypass the seal.

Left side danger still exists:

- Runaway husks.
- Low-level drift across roads or along water.
- Old husk pockets in ruins, caves, or bad corridors.
- Accidents that become catastrophic because only a few hundred humans remain.

So the left side is not "safe." It is simply not the hive's main strategic front.

## Gate types

1. **Natural boundary gates.** River, mountains, and husk-heavy ground establish
   early map legibility.
2. **Heat gates.** Hotter regions punish early entry through baseline hive
   concentration (`../Mechanics/hive-concentration.md`).
3. **Traversal/tool gates.** Boat crossing, mountain trail survival, Arghanzza
   navigation, and any later right-side tools.
4. **Story/lore gates.** The Sanctum return in particular should be unlocked by
   understanding, not just stats.

## Open

- Exact route from Magizhee to the militia zone: direct road, patrol corridor, or
  training-yard outpost chain.
- Exact supply/support reason the militia gives for sending the player to Vendur.
- Exact river-crossing method and whether it is controlled by militia, Vendur, or a
  separate ferryman.
- Whether Vengarz Camp becomes **Vengarz Hold** after the player unlocks old
  defensive tech with the sword.
- How many playable sub-areas the mountain trail and Sword Sanctum need.
- Whether the Silent Core is a single endgame region or a region cluster.
