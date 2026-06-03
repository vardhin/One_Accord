# Demographic & Food System — How the World Sustains Itself

> The **world-level engine** under every settlement: how people are born, raised,
> trained, paired, and posted, and how the map feeds itself. This governs *every*
> region's headcount and economy, so it lives in `Mechanics/`, not in any one region
> folder. Region docs (`../Regions/`) derive their census *from* this.
>
> Built on `../Regions/world-structure.md` (no slack, ~400 alive, post-famine
> equilibrium) and `village-and-union-system.md`. This doc makes those constraints
> **operational** — the numbers that let the world close.

---

## 1. The core fact: population is regulated, not free

The famine already settled the population (`../Regions/world-structure.md`):
survivors shrank until they matched what the land can feed. This world **keeps it
that way on purpose.** Reproduction is not a private act — it is a **gated,
centralized function**, because in a world with **no slack**, an unsupportable child
is a death sentence for more than itself.

> The world doesn't let people breed faster than it can feed. It enforces that.

---

## 2. Naerchu — the single reproduction + training engine

**Naerchu (the Training Camp) is the world's one demographic institution.** It does
three jobs no other place does:

1. **Raising-to-hardness.** Every child, from **every (participating) settlement**, is
   sent to Naerchu at **age 6** and returns around **18** as a trained adult. Childhood
   ends at Naerchu (`../Regions/Naerchu/region-naerchu.md`). *(Exceptions: **Velduri**
   opts out entirely, and **Teling** guild-raises ~80% of its children — §5.)*
2. **Mating.** The world's **entire mating-age cohort passes through Naerchu.**
   Pairing happens here — wedlocks, communions, and open/live-in arrangements all
   exist. Mating continues **until menopause** (the biological cap; not a flat age).
3. **Regulation — the hard gate.** Naerchu **enforces who may reproduce.** A couple
   may wed / have a child **only if they can show a sustaining slot**: a trade
   lineage to inherit, a productive post, or demonstrable capacity to feed the child.
   No slot → no sanctioned child. This is the mechanism that holds population to the
   food supply.

> Naerchu is not just an army town. It is the **valve** on the species: training,
> pairing, and the permission to reproduce all run through one place. Take Naerchu
> and you take the future.

### Consequences of the Naerchu model

- **Young adults are a shared, mobile cohort**, not "a town's children." After 18
  they are **posted out to settlements as guards** (§4). They are *lineage-posted* —
  sent back **near their home/lineage town when possible** — but they are fundamentally
  the world's pooled young-adult labor, not local-born-and-stay.
- **Kids born at posts go home to be raised.** A guard couple posted to Vendur who
  have a child send that child to **their home town's elderly** to raise; at 6 the
  child goes to Naerchu like everyone else.
- **The elderly raise the children.** In every settlement, the **non-working old**
  (retired tradesfolk, in-laws) are the childcare layer for the under-6s. This is why
  every region's census has an elderly bracket doing more than "remembering."
- **Naerchu caps at ~50.** Everyone there is training-age and **grows no food** (§3),
  so it cannot be large — it is a focused ~50-person institution, fully import-fed.

### Naerchu's ~50, broken down

| Group | Count | Role |
| --- | ---: | --- |
| **Instructors** | **9** | Combat / survival / self-defence training. |
| **Craft-teachers** | **3** | A **blacksmith**, a **silversmith**, a **glyph master** — the three crafts taught here (they also hold lineages → own ~6 of the trainees). |
| **Elderly** | **4** | Cook and maintain the camp. |
| **Trainees** | **~38** | The world's **6–18 cohort** (every child of a *participating* region in that band). Soft number — ticks up/down as regions partly opt out (§5). |
| **Total** | **~54** | |

> **The of-age band (the hero's love interests).** Of the ~36 trainees, **≥8 are 15–18**
> — the pool the hero can court. **Hard rule: no romance with anyone under 18.** With
> the whole world only ~200–250 people, this small of-age cohort is *deliberately* the
> main romance pool. A hero may also find a love interest among the **posted guards**,
> but that is **rare — ~1–2 per region** (most guards are unpaired and pass through).

---

## 3. The food system — how the map eats

A **collapsed manuscript-clockwork society** has low agricultural yield
(`../Lore/setting-and-tech-level.md`, `../Regions/world-structure.md`): no
high-yield grain, no fertilizer, no canning at scale. **Roughly one farmer feeds
2–4 people.** That ratio is what forces the whole structure below.

### The three food sources

- **Magizhee — the breadbasket (grain/staples).** Magizhee is the **starter
  settlement AND the world's farm-dense region**: **26 farmers (13 farming couples)**
  working the one place with arable scale. It grows the **staple surplus** the rest of
  the map can't. (You start the game where the food comes from — a Stardew-true
  opening. See `../Regions/Magizhee/region-magizhee.md`.)
- **Belgond — protein & forage.** Belgond **doesn't farm**; it **hunts and forages**
  (game/deer meat, hide, mushrooms, berries — `../Regions/Belgond/region-belgond.md`).
  It supplies the **protein and the wild foods** grain can't provide.
- **Mauzuli — fish.** The displaced fisherfolk **supply fish**
  (`../Regions/Mauzuli/region-mauzuli.md`) — a third staple source. *But its best waters
  (the Old Dock) are husk-held until reclaimed*, so its output is reduced in the start
  state: losing the dock cut a food source, raising the stakes of the reclamation arc.

> Grain (Magizhee) + protein/forage (Belgond) + fish (Mauzuli) = the map's food base.
> Everything else either feeds itself partway or is fed from these three.

### The distribution backbone — the ownerless rotating caravan

Food moves on a **rotating caravan that no settlement owns.** It is **shared
infrastructure**: it loops the map, **loads grain at Magizhee, game/forage at Belgond,
and fish at Mauzuli**, and **distributes** to:

- **Naerchu (~54, pure consumer)** — its entire food supply rides this caravan.
- **Deficit towns** — any settlement whose own farming can't cover its mouths (e.g.
  Vendur, §5) gets topped up by the same circuit.

Each supplier town **loads the rotating caravan and lends escorts** when it passes,
but no one owns it. This is distinct from **normal trade caravans**, which are
town-owned and carry **irreplaceables** (silver, tools, masterwork, medicine,
blueprints — `village-and-union-system.md`), **not** bulk food.

> Two caravan systems, deliberately separate: **food rotates (ownerless); goods trade
> (town-owned).** The food backbone is a strategic target — choke the rotating caravan
> and Naerchu starves, which starves the future (§2).

### Why the math closes

- Magizhee's **26 farmers** at ~3 mouths each ≈ a **staple surplus** beyond Magizhee's
  own population — enough to cover **Naerchu's 50** and **top up deficit towns.**
- Belgond covers the **protein** that grain can't.
- Most other settlements are **partially self-feeding** (kitchen gardens, chickens,
  a goat, a fishing spot — `../Regions/world-structure.md`) and only need topping up.
- Result: a **closed loop** — Magizhee (grain) + Belgond (protein) → rotating caravan
  → Naerchu + shortfall towns. No invented breadbasket needed beyond Magizhee.

---

## 4. The guard / labor model

Posted young adults (§2) are the world's **guard and heavy-labor force.** A
settlement's defense and caravan crews are drawn from this cohort, lineage-posted
home when possible but topped up from the shared pool.

- **Unmarried** posted guards live in a **dorm**; **wedlocked / live-in** couples get
  **separate homes** at the post. (So a settlement's barracks is two kinds of housing,
  not one dorm.)
- **Trade lineages are inherited, not pooled.** Each settlement's **crafts** (smith,
  silversmith, trader, healer, etc.) are held by **resident lineage families** — the
  ones who came back to take the craft. A lineage has **one heir** who begins learning
  the art around **age 26** and eventually takes the trade; **surplus children stay
  guards/caravan crew for life** (trade slots are fixed).
- **Guards are work-cum-militia, not pure soldiers.** Off-shift, posted guards
  *work* — they farm, haul, quarry, hunt, escort. In extraction towns this is total:
  **Belgond's work-militia ARE its foragers/miners/hunters** (they extract on-shift,
  guard the worksites the rest), so there is no separate worker headcount there. This
  is what lets a small population both produce and defend (`../Regions/Belgond/`).
- So every settlement is, structurally: **a thin lineage layer (the trades) + an
  elderly layer (childcare, cooking, memory) + a thick work-cum-militia guard layer
  (defense + labor + caravans) + the under-6 kids.** The exact numbers are the region's
  census.

---

## 5. The world population table (it conserves)

The whole world is **~400 people** (`../Regions/world-structure.md`: ~400 alive, ~200
ever seen). Fully derived region-by-region below, the modeled total lands at **~403** —
matching the "~400 alive" figure almost exactly. (The "~200 ever seen" is the subset the
player actually meets: the human-pocket settlements; the hive side is ruins + lone
figures.) The key constraint is **cohort conservation**: every person flows
**kid (0–6, home) → trainee (6–18, Naerchu) → adult (18+, posted guard, maybe trade).**
So the **34 Naerchu trainees ARE the world's entire 6–18 cohort**, and they must trace
back to the regions' **reproducing (sanctioned) couples** — mostly the trade lineages.

### Core regions (present headcount + kids away at Naerchu)

| Region | Present | Owns at Naerchu | Shape (top-down) |
| --- | ---: | ---: | --- |
| **Vendur** | **83** | ~5 | 9 trade couples + 44 work-militia guards + ~13 elderly + ~5 kids<6. Two-tier silver/trade fortress. (`../Regions/Vendur/vendur-census-and-economy.md`) |
| **Magizhee** | **~67** | ~15 | **13 farming couples (26)** + 3 specialists (healer, blacksmith, silversmith — lightly partnered, some bachelors) + 7 elderly + **18 work-militia (9 shift)** + ~10 kids<6. The breadbasket. |
| **Belgond** | **~37** | ~8 | **24 work-militia = the foragers/miners/hunters/timber crews** (12 shift) + 1 headman + 1 tool-smith + 6 elderly + ~5 kids<6. Scattered extraction colony. |
| **Naerchu** | **~54** | — | 9 instructors + 3 craft-teachers + 4 elderly + **~38 trainees** (the world's 6–18 cohort; drifts above the round 34 as participating regions add shares). The demographic engine. |
| **Velduri** | **~64** | **0 (opts out)** | 6 elite couples + 6 elderly + 8 servants + 25 veteran guards + 1 instructor + 12 kids (all home). **Full demographic dissenter** — arranged endogamous marriage, in-house training; off the Naerchu grid entirely. (`../Regions/Velduri/region-velduri.md`) |
| **Teling** | **~48** | **~2 (~20% only)** | 10 master craftsmen (6 silversmith, 2 blacksmith, 2 glyph master) + 10 farming wives + 16 elite guards (best of the posted cohort) + 4 elderly + ~10 kids. **Partial dissenter** — guild-raises ~80% of its children in-blood to keep craft secrets. (`../Regions/Teling/region-teling.md`) |
| **Mauzuli** (Fishermen Camp) | **~24** | ~2 | 16 fisherfolk (8 couples — fishermen/dock-keepers/ferrymen; **self-guarding**, but the dock husks overpowered them → fled) + 4 elderly + 4 kids<5. **A food producer (fish).** Census = the displaced camp; the Old Dock proper is empty until reclaimed. (`../Regions/Mauzuli/region-mauzuli.md`) |
| **Medicine hermit** | **3** | **0 (off-grid)** | Husband + wife + apprentice. A single off-grid household; the map's **external healer by design.** (`../Regions/MedicineHermit/region-medicine-hermit.md`) |
| **Vengarz Hold** | **~20** | **0 (off-grid)** | A hardened anti-hive war-remnant; **self-contained martial order** (raises/trains its own, no children at the Hold, not Naerchu-posted). (`../Regions/Vengarz/region-vengarz.md`) |
| **Vaelp** (Sword Sanctum) | **1** | — | The **true sword maiden** alone in an untouched sanctum. Off-grid (not a human survivor). (`../Regions/Vaelp/region-vaelp.md`) |
| **Arghanzza** | **1** | — | The lone **corpse-burner / ferryman** (runs Mauzuli's ferry, burns the dead at his pyres). Off-grid. (`../Regions/Arghanzza/region-arghanzza.md`) |
| **Glyph hermit** | **1** | — | A lone self-warded glyph-master in his hobbit-hole. Off-grid. (`../Regions/GlyphHermit/region-glyph-hermit.md`) |
| **Rosetta** | **0** | — | Dense **ruin**, no living population — the *site* is the content; Vengarz raid it from outside. |
| **Digzarr** | **0** | — | The great fallen **city**, hive-held ruin; no living faction — raided for old-tech (`../Regions/Digzarr/region-digzarr.md`). |
| **Pathali** | **0** | — | A **maze-dungeon**, not a settlement; hazards + abstaining deities, no people. |
| **Silent Core** | **0** | — | Densest hive-mind ground (may dissolve into the endgame); **hive mind only.** |
| **WORLD TOTAL** | **~403** | **~38 at Naerchu** | The whole modeled map. Matches `../Regions/world-structure.md`'s "~400 alive." Living population is concentrated in the human-pocket settlements; the hive side is ruins + lone figures. |

### Why it conserves

- **Kids:** Magizhee ~15, Belgond ~8, Naerchu's craft-teacher couples ~6, Vendur ~5,
  Teling ~2, Mauzuli ~2 → **~38 total** = Naerchu's trainee count. ✓ (Most kids are
  **trade-lineage** children; the small bands contribute a couple each.) **Naerchu's
  trainee total is soft** — it drifts above the round 34 as participating regions add
  shares, and *down* as regions opt out (Velduri fully, Teling 80%).
- **Birth rate is fine because the game is a 1-year snapshot.** ~3 children enter the
  world per year; over a decade that's the ~30+ that fill Naerchu's 6–18 band. The
  population is **steady, not growing** — exactly the post-famine equilibrium. Most
  adults (the bulk of the work-militia) are **unpaired and non-reproducing**; only the
  sanctioned slot-holders breed. A large guard layer is *not* a population paradox —
  guards are the **terminal state** for most people, not breeders.
- **Adults conserve too:** each region's guards are the posted 18+ cohort, lineage-
  posted home where possible, topped up from the shared pool — so guard totals don't
  have to match local-born counts (Vendur imports most of its 44, §4).
- **The documented exception — Velduri opts out.** The silver-elite **refuse Naerchu's
  unselected mating**: their elders **arrange endogamous marriages**, they **train their
  own children in-house** (their own instructor), and their 25 guards are veterans
  bought from Naerchu long ago (now ~40), rarely renewed. So Velduri's ~64 are **off the
  grid** — its kids never enter the 34, and it draws nothing from the posted pool. In a
  world built on one shared reproduction engine, **opting out is the ultimate statement
  of elite separateness.**
- **The partial exception — Teling.** The craft-guild **guild-raises ~80% of its
  children** (only ~20% go to Naerchu), keeping craft and bloodline in-house to protect
  its secrets — but it still **draws its elite guards from the Naerchu pool.** So Teling
  withholds most of its young while taking the system's best fighters: a *partial*
  dissenter, the reason it stayed a separate region rather than folding into Vendur.
  (Other off-grid cases: the **hermits** — single households — and the **external
  healers** by design.)

> **This is why headcounts can't be set independently** (the trap: guards 20 / traders
> 40 / elderly 60 → kids 0). They're all slices of **one** age pyramid feeding **one**
> Naerchu. Change a region's couples and you change its Naerchu-kids; change the guard
> count and you change the posted-cohort draw. The table above is balanced; edits must
> re-balance it.

---

## 6. How a settlement's census derives (the method)

This is the **top-down method** every region's solidification should follow (Vendur
is the worked example — `../Regions/Vendur/vendur-census-and-economy.md`):

1. **What services must this place provide?** (e.g. silver, forge, trade, defense,
   food, healing, records.)
2. **What manpower does each service need?** (e.g. 3 silversmiths, 6 caravan guards
   per caravan, etc.) — manpower is derived from services, not guessed.
3. **What families/people does that manpower imply?** (lineage tradesmen + their
   farming/working spouses + posted guards + elderly + kids) — headcount is the
   **output** of steps 1–2, never the input.
4. **Does its food close?** Farm labor × (2–4 mouths) vs. total mouths. Any deficit is
   covered by the rotating caravan (§3) — or, if the deficit is structural for the
   whole map, it forces a new producer (this is exactly how Magizhee became the
   breadbasket).

---

## 7. Open

- **Exact yields** (calories/farmer, terrace output, game throughput) are modeled
  qualitatively here; tune if a survival/economy sim layer is built.
- **Rotating-caravan cadence & route** — frequency, escort rotation, which towns it
  touches in what order (coordinate with `../Regions/connectivity-map.md`).
- **Menopause/age curves** and how the sim tracks lineage succession (who becomes the
  heir) — deferred to per-NPC / sim authoring.
- **The hermits & Velduri** — do the off-grid (glyph/medicine hermits) and the
  self-sufficient silver-elite (Velduri) opt out of the Naerchu cycle? Likely partial
  exceptions; resolve when those regions are solidified.
- **Whether other settlements send to the rotating caravan too** (small surpluses
  aggregated) or only Magizhee + Belgond are net producers.
