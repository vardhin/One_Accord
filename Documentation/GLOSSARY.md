# Canon Terms — Glossary

> Single source of truth for named systems and vocabulary. Build specs and code
> reference **one** term per concept — the canonical one below. If a doc uses a
> different word, the doc is stale; fix it to match this sheet.
>
> Format: **Canonical term** — definition. *(retired aliases, if any)* → source doc.

---

## The two deep agents

- **The Sword (sword-girl)** — the player's rusty sentient sword; a person whose
  body-slot is "weapon." A Tier 0 deep agent. NOT the true Soul Sword — a coerced
  occult imitation. → `Sword/sword-as-npc.md`, `Lore/sword-girl-backstory.md`
- **The Hivemind (the hive)** — one sealed possession-god mind distributed across
  bodies; the other Tier 0 deep agent. Knows through surveillance, not intimacy.
  → `Npcs/hivemind-agent.md`, `Lore/ancient-history.md`
- **True Soul Sword (the maiden)** — the legitimate, consent-born original weapon
  (flies, speaks aloud to anyone, casts, **severs divinity**). Did **not** vanish when
  the hero fell — it **withdrew to the divine-mountain sanctum and guards itself**, now
  as a **young sword maiden** (recent grief; no longer demands self-sacrifice).
  **Findable and obtainable** — the other half of the One Accord choice. Distinct from
  the player's rusty imitation. → `Lore/the-hero-and-true-sword.md`, `Lore/premise-and-the-one-accord.md`

## Souls, deities & the One Accord

- **The soul economy** — the unifying metaphysics: deities, soul swords, and the hive are
  **all souls** in one possession economy. Severance works because it meets the hive
  **soul-to-soul** (metal/fire/silver only hit bodies). → `Lore/the-deities-and-the-soul-economy.md`
- **The deities (~10)** — **ascended souls** from the beginning of eons; **forgotten but
  alive.** They **deliberately abstain** from direct action: the hive could take even one
  of them, and one taken deity = the hive wins. *(corrects the "they sealed him" line in
  `ancient-history.md`)* → `Lore/the-deities-and-the-soul-economy.md`
- **Glyphs are deity-lent (hidden)** — **all** glyph magic is the deities' **indirect
  channel**; humans believe it's merely decoded technique. The truth is a lore reveal.
  → `Lore/the-deities-and-the-soul-economy.md`, `Glyphs/glyph-system.md`
- **The hive as Sauron** — a possessing will that can **influence/take over** anything with
  a soul-channel: people, the soul swords, even deities. The **soul duel** is where that
  takeover is contested; **fail it and you die.** → `Lore/the-deities-and-the-soul-economy.md`, `Sword/soul-duels.md`
- **The One Accord (the title)** — you may bond with **two** sword-accords (your rusty
  sword; the true maiden) but may keep **only one.** A **forsaken** accord pursues its own
  path — may hunt you or take a new wielder (a rival). → `Lore/premise-and-the-one-accord.md`
- **Stalemate frame** — the world **works but cannot grow** (no more food, no expansion past
  the husk, no pushing the hive back). The player is the **breaking point**, special only as
  the **first to trust the sword** — **not** a savior. → `Lore/premise-and-the-one-accord.md`

## The hive engine

- **Thread scheduler** — the spine mechanic: the Hivemind is an AI on a **finite
  thread budget**, dynamically allocating attention. One thread drives one node.
  → `Mechanics/hivemind-threads.md`
- **Thread** — one unit of hive attention; drives one node (husk, possessed
  matter, or soft-infected person). → `Mechanics/hivemind-threads.md`
- **Concentration** — the *local face* of thread allocation: how dense the hive's
  attention is in a region. Has an **authored baseline** + player-driven **drift**.
  → `Mechanics/hive-concentration.md`
- **Merge / the tragic loop** — under player pressure, threads consolidate into
  fewer, smarter allocations (husk-commanders → ultimately one). Player progress
  sharpens the enemy. → `Mechanics/hivemind-threads.md`

## Enemy taxonomy

- **Husk** — infected body on low instinct/routine. Dumb, numerous. → `Enemies/hive-enemy-design.md`
- **Active** — a husk the scheduler is currently spending a thread on; smart,
  speaks as the hive. → `Enemies/hive-enemy-design.md`
- **Named Node** — a body that held hive attention long enough (merged threads) to
  grow a pseudo-personality: husk-commander / general / infiltrator / negotiator /
  assassin. Hive-grown, **not** an infected person. → `Enemies/hive-enemy-design.md`
- **Behavior archetypes** — the reusable enemy templates (Husk: Drone/Sentinel/
  Swarmer/Mimic-lure · Active: Skirmisher/Caster/Brute/Coordinator · Node: General/
  Infiltrator/Negotiator/Assassin). Stat numbers are implementation tuning.
  → `Enemies/hive-enemy-design.md`

## Plague & the seal

- **The seal** — the old hero's binding: **the living can no longer be infected.**
  No bite-risk, no incubation. The setting's defining inversion. → `Mechanics/plague-and-infection.md`
- **Soft-infected** — an ordinary adult NPC the sealed hive can puppet for a
  blackout (then they have no memory of it). The only human backdoor. **Never a
  child; not a turning case.** Detectable only by late-game Light.
  → `Mechanics/plague-and-infection.md`
- **Checkup** — the screening/observation practice that replaced the old (now
  pointless) turning-quarantine. → `Mechanics/plague-and-infection.md`

## Kill resolution — the four-tool economy

- **Four-tool economy** — every kill is a question of tool × body. → `Mechanics/kill-resolution.md`
  - **Plain metal** — always a **loan**; the body re-bodies mutated, adds drift.
  - **Fire** — perma-kills dumb husks; **backfires** on Actives (they re-body
    stronger). Loud, fuel-hungry.
  - **Silver** — perma-kills dumb husks **quietly**; also backfires on Actives.
    Scarce/hoarded (caused the historical **Silver Anarchy**).
  - **Severance (soul sword)** — the only true death for an Active/Named Node;
    clean cheap kill on the dumb.
- **Mutation** — a plain-metal (or failed) kill re-bodies as body-horror shaped by
  *how* it died. → `Mechanics/kill-resolution.md`
- **Pyrecraft** — the skill of confirming a body is dumb/unheld before burning, so
  fire kills clean instead of waking it. → `Mechanics/kill-resolution.md`
- **Severance** — removing a body from the hive permanently. For Actives/Nodes it
  requires a **soul duel**. → `Mechanics/kill-resolution.md`, `Sword/soul-duels.md`

## Combat & the sword's agency

- **Soulslike foundation** — spacing/timing/stamina/dodge/parry skill; dice never
  decide hit/miss. → `Mechanics/combat-system.md`
- **Accord roll (cooperation roll)** — the hidden roll after a *physically valid*
  action deciding **how well the sword cooperates** → **hit quality** (guided/true/
  dull/late/turned/refused/backlash), not hit/miss. → `Mechanics/combat-system.md`
- **Stillpoint** — the bullet-time negotiation window when player intent and sword
  will collide; arguments are state-checked, not free text. *(retired alias: "Held
  Cut")* → `Mechanics/stillpoint.md`
- **Reverse Stillpoint** — the sword *initiating* the contest to demand action.
  → `Mechanics/stillpoint.md`
- **Emergency override** — cooperation can spike ~95% when both are in lethal
  danger; she spends her own reserve by choice. → `Mechanics/combat-system.md`
- **Soul duel** — the second-layer 1v1 fight where the player **becomes the
  sword-girl**; how Actives/Nodes are truly severed. → `Sword/soul-duels.md`

## Sword communication

- **Seek Accord** — the input action: touch the sword to the brow to request
  private attention. Guarantees attention, not cooperation. *(the "brow-touch" is
  now only the gesture; "Seek Accord" is the action)* → `Sword/voice-and-brow-touch.md`
- **Voice Links (I–VI → endgame)** — the staged unlock of two-way sword
  communication, from reflex barks to a limited full chat window (never infinite).
  → `Sword/voice-and-brow-touch.md`
- **Counsel** — the sword functioning as a diegetic, metric-gated hint/guide
  system (not an always-on UI assistant). → `Sword/metrics-clarity-trust-resonance.md`
- **Dialogue functions** — the deterministic set the engine picks from (WARN,
  IDENTIFY, GUIDE, CORRECT, REBUKE, REMEMBER, ASK, COMFORT, WITHHOLD, SILENCE); the
  LLM only writes the line. → `Sword/dialogue-system.md`

## Sword metrics & relationship stats

> Two related families. Keep the names distinct — **Resonance** (dialogue) and
> **Attunement** (combat) were deliberately split so they don't collide.

- **Clarity** — RAG / knowledge access: what the sword *can understand and reveal*.
  → `Sword/metrics-clarity-trust-resonance.md`
- **Trust** — conversational permission + long-term reliability: how much she
  *cooperates*. (Spans both the guide-metric and combat-stat families.)
  → `Sword/metrics-clarity-trust-resonance.md`, `Mechanics/relationship-stats.md`
- **Resonance** — output/token budget: *how much she can say*. **Dialogue only.**
  → `Sword/metrics-clarity-trust-resonance.md`
- **Attunement** — metaphysical/combat compatibility. *(renamed from "Resonance" to
  avoid collision with the dialogue metric above)* → `Mechanics/relationship-stats.md`
- **Sync** — short-term combat rhythm inside one encounter. → `Mechanics/relationship-stats.md`
- **Autonomy / Resentment / Fatigue** — the sword's independence, accumulated
  grievance, and overuse drain. → `Mechanics/relationship-stats.md`
- **Identity axes (upgrade lens)** — trust, resentment, shame, hunger, autonomy,
  dependence, fear, bond depth, corruption, attunement. → `Sword/upgrades-and-identity.md`
- **The relationship IS the build** — bond paths (Dominating/Devotional/Romantic/
  Professional/Exploitative/Mutual-healing) replace class archetypes.
  → `Sword/upgrades-and-identity.md`

## Forge & upgrades

- **Forge levels (0–4)** — Cold bench → Working hearth → True heat → Pattern forge
  → Living/soul forge. Upgrades require world infrastructure, not a flat tree.
  → `Mechanics/forge-and-upgrades.md`
- **Glow / detection** — the *functional* rust-removal chain that unlocks
  enemy-proximity glow. Kept SEPARATE from the consent/identity rust drama.
  → `Sword/glow-and-detection.md`
- **Companion weapons** — magic weapons for teammates (salt-pike, bell-knife,
  cold-needle, ash-axe); never as special as the sword. → `Npcs/system-npc-roles.md`

## Glyphs & magic

- **Glyph grammar** — **5 elements** (Heat/Flow/Air/Earth/Light) × **5 operators**
  (Addition/Subtraction/Spread/Focus/Bind). Locked canon. → `Glyphs/glyph-system.md`
- **Glyph classes** — **loan** (better plain-metal hit) · **kill** (only `Heat +`
  fire and the `Light` line; perma-kill dumb, backfire on Actives) · **utility** ·
  and the hard floor: **nothing in the grammar can sever.** → `Glyphs/glyph-system.md`
- **Light kill line** — the silver-equivalent anti-hive kill glyphs (Silverlight,
  Pierce-of-Day): Telugu-gated, late, energy-brutal. Also the only thing that
  **detects the soft-infected**. → `Glyphs/glyph-system.md`
- **Mass-gated slots** — sword form sets glyph count: dagger(1) → shortsword(2) →
  katana(3) → longsword(4) → greatsword(4 max). → `Glyphs/glyph-system.md`
- **Additive energy rule** — glyph cost is **linear** (N glyphs = N× base);
  **mixing elements is free** (no surcharge). Discipline = additive drain + the
  ~15%/glyph **strength tax**. → `Glyphs/energy-and-stamina.md`
- **The dyadic energy economy** — glyph energy is **player calories → long stamina
  → (meditation) → the sword's own bar → glyphs**. Short stamina runs combat only.
  → `Glyphs/energy-and-stamina.md`
- **Spell tables (386 builds)** — every glyph subset of size 0–4; scaffold
  generated by `generate_spells.py`, **every effect hand-authored** (no auto-fill).
  → `Glyphs/spells/README.md`

## Three writing systems (do not conflate)

- **Human Chinese** — the mundane survivor script; the **literacy lexicon**
  mechanic (learn characters one by one; confidence states unknown→corrupted).
  → `Mechanics/literacy-system.md`
- **Glyphs** — the operative magic symbols (the grammar above). Not part of Chinese.
  → `Glyphs/glyph-system.md`
- **Ancient scripture (Telugu)** — the old form of the glyphs; its own
  **sword-led** decoding system (NOT the Chinese lexicon UI). The sword is the best
  reader; player recovers inscriptions and brings them to a reader.
  → `Glyphs/glyph-system.md`, `Mechanics/literacy-system.md`
- **Language fossils** — place and faction names often preserve eroded Telugu roots
  across millennia (e.g. `vendi + ooru -> Vendur`), even when modern people no
  longer understand the etymology. → `Lore/setting-and-tech-level.md`

## World, NPCs & progress

- **Region tiers** — **Dense** (~7–8, returnable hubs) · **Mid** (Goodsprings-scale
  settlement / focused stronghold) · **Mini** (~3–4, single-arc spokes). Current
  tiering: **Dense** — Vendur, Belgond, Rosetta, Teling · **Mid** — Old Dock (Mauzuli),
  Training Camp, Vengarz Hold, Velduri (Magizhee also mid) · **Mini** — Arghanzza,
  Sword Sanctum, Ancient Divine Labyrinth, glyph hermit's hole, medicine hermit's
  homestead (5; the 3–4 target was soft). **Undecided** — Silent Core (may not be a
  walkable region at all; could dissolve into the endgame war). → `Regions/world-structure.md`
- **Magizhee** — the Goodsprings-scale starter settlement; the **hub** at the center
  of the human pocket (Old Dock north, Training Camp east, Vendur south, predator-
  mountains west). → `Regions/starter-settlement.md`
- **Vendur** — silver trade hillfort; name fossil from `vendi + ooru -> venduru ->
  Vendur`. Dense hub, sword-girl's old home; south of Magizhee (Vendur Militia, then
  the Hill Fort Market beyond it, then **Teling** SE). "The silver place" because the
  map's silver (~80%) **circulates through it** — worked into tools/wards/coins, not
  hoarded. Forge does **basics (L1→2)** only; mastery is at Teling.
  → `Regions/Vendur/region-vendur.md`
- **Belgond** — dense raw-materials supplier town west of Magizhee on the
  predator-mountain Sanctum road; ships quarry stone, timber, hide, mushroom, and
  game down to Vendur, buys back tools, militia-for-hire, silver/wards, and finished
  leather. One main colony of homes with worksites ~5 min out; reached by armed
  caravan (the predator road kills lone travelers); last inhabited place before the
  Sword Sanctum trail. → `Regions/region-set.md`
- **Old Dock (Mauzuli)** — **mid** region north of Magizhee with two coupled states:
  the displaced **Fishermen Camp** (sub-node — the fisherfolk pushed off the dock by
  the husks) and the **reclaimed Dock**. The ferry is the **only river crossing (hard
  gate)**: meet the fishermen → clear & repair the dock → they relocate back → ferry
  runs → hive side opens. The fisherfolk are the ferry's old operators. Name fossil:
  **Mauzuli** (echoing Machilipatnam / Masulipatnam). → `Regions/connectivity-map.md`
- **Teling** — **dense** mastery-smithing hub SE of Vendur (human-pocket side); the
  forge **L3→4** gate (glyph-embedding, silver wards, masterwork weapons). A
  hereditary smith-guild / craft-lineage / glyph-keepers with **old-hero-legion
  links** — the *making* counterpart to Vengarz's *doctrine*. Vendur does basics
  (L1→2); the player reaches Teling to take the sword past L2. Name fossil from
  "Teling steel" (Telangana wootz). → `Regions/region-set.md`
- **Velduri** — **mid** wealthy self-exiled **silver-elite** enclave (old-order
  remnants who fled the collapse); holds the map's only **pure silver reserve**
  (~20%; Vendur's ~80% is all in circulation). A **rare** Vendur client; depends on the
  nearby **medicine hermit** for healing (paid in silver). **Endgame
  alliance** unlocks elite soldiers + pure-silver weapon supply. Name fossil from
  *velli* (silver), quietly echoing Vendur. **South of Vendur** in the southern
  mountains; **mountain-defended, not a hillfort** (off-spine). → `Regions/region-set.md`
- **Training Camp** — the coming-of-age / militia hardening settlement NE of
  Magizhee; the safe eastern early route. → `Regions/region-set.md`
- **Vengarz Hold** — mid-size mobile wooden/tent/wagon stronghold (a camp they call a
  **Hold**), south of Rosetta, reached from Arghanzza via the puzzle route; remnant
  of an old anti-hive force from the hero's legion. → `Regions/Vengarz/vengarz-camp.md`
- **Rosetta ruins** — confirmed dense hazard/lore region; old research ground-zero
  where the hive first entered; north of Vengarz Hold, below the Silent Core. → `Regions/region-set.md`
- **Ancient Divine Labyrinth** — mini **maze-dungeon** off the **second** path out of
  Arghanzza (not the Vengarz route); channel-point of the forgotten deities. The
  **first Light-glyph** is earned by navigating/surviving the labyrinth.
  (Renamed from "Ancient Deity Sanctum.") → `Regions/region-set.md`
- **Medicine hermit's homestead** — **mini** small-household spoke on the **human
  side, near Velduri** (off the main spine). A herbalist/medicine hermit + wife +
  apprentice who experiment with herbs and remedies; **Velduri patronizes them** (silver
  offerings for medicine the elite can't make), and they welcome anyone who makes the
  long trek. The healing counterpart to the glyph hermit (#12); **south of Vendur**,
  near Velduri. Reward and naming deferred. → `Regions/region-set.md`
- **Glyph hermit's hole** — **mini** single-NPC spoke in the **SE of the hive side**,
  off the main spine (not Arghanzza-linked). A strong, self-warded lone glyph-master
  living in a dug-in **"hobbit-hole"** who survives deep hive ground by his own power;
  an off-grid exploration reward who gives the player a **new glyph or modifier**
  (rarer/riskier than town-taught ones). Naming and access route deferred.
  → `Regions/region-set.md`
- **Silent Core** — northernmost, most hive-concentrated ground. **Tier undecided:**
  may not be a walkable settlement-style region at all — could dissolve into the
  endgame war structure (resolved in Stage 7 endgame design). → `Regions/region-set.md`
- **Decompression corridors** — the quiet traversal spaces between regions; on the
  map they are the **edges** of the graph (and playable rooms that can hold a single
  mini-arc). → `Regions/world-structure.md`, `Regions/connectivity-map.md`
- **Route shape** — Magizhee (hub) opens east → Training Camp or south → Vendur,
  converging at Vendur; ferries from the husk-held Old Dock into **Arghanzza**, which
  **forks**: puzzle route → Vengarz Hold → Rosetta → Silent Core, or a second path →
  Ancient Divine Labyrinth. West of Magizhee, the predator road leads by caravan to
  Belgond and then up to the Sword Sanctum. Region heat orders pressure; the map is anchored by natural
  boundaries and the water threshold. → `Regions/connectivity-map.md`
- **Reserved slot** — an unfilled position in the route shape with a known
  neighbor/gate/heat-band; future regions claim a slot rather than being designed
  in a vacuum. → `Regions/connectivity-map.md`
- **Gate types** — what blocks/opens a map edge, soft→hard: **heat gate** (baseline
  floor punishes going too early — the default ordering mechanism), **tool gate**
  (needs a learned traversal capability), **story gate** (opens on a narrative beat).
  Plus **shortcuts** (far-side-unlocked edges that turn the spine into a lattice).
  → `Regions/connectivity-map.md`
- **NPC tiers (0–3)** — Tier 0 deep agents (Sword, Hive) · Tier 1 core named
  (~10–12) · Tier 2 secondary (~15–25) · Tier 3 ambient. **40 named is a HARD CAP.**
  → `Npcs/npc-tiers.md`, `Npcs/core-named-roster.md`
- **The Core Five** — the starter-settlement NPCs (guard captain, healer,
  blacksmith, trainer, quartermaster). → `Npcs/starter-npcs.md`
- **Village & union system** — progress as regional organization/infrastructure,
  not just personal leveling. → `Mechanics/village-and-union-system.md`
- **Log & agent-memory** — agents act from bounded, **world-centric** logs; the
  simulation owns world mutation, the LLM only writes voice. → `Mechanics/log-and-agent-memory.md`
- **The local model** — **LiquidAI LFM2-8B-A1B** (`Q4_K_M` GGUF), served by
  llama.cpp `llama-server` on port 8080. A **pure language interface**: writes the
  line only; never selects functions, manages state, or decides canon. *(retired:
  "Zaya")* → `Production/vertical-slice-spec.md`, `Mechanics/log-and-agent-memory.md`

## Player & framing

- **The player** — a Courier-style nobody; special by **log density**, not
  ontology. Starts illiterate, with nothing. → `Player/player-premise.md`
- **Three Nights Outside the Gate** — the opening/tutorial quarantine zone; teaches
  the world through procedure. → `Player/opening-and-tutorial.md`
- **Vertical slice (v0)** — the first thing to build: Three Nights + the starter
  settlement + the Core Five + one local crisis + the first sword bond. One
  settlement, no second region, no endgame. Engine and full-game scope are
  **deferred**. → `Production/vertical-slice-spec.md`
- **Possession vs. partnership** — the central thematic axis: the hive possesses;
  the sword refuses to be possessed. → `genre-and-themes.md`
- **Genre** — no coined name; a **descriptor stack** (top-down 2D action-RPG
  survival-sim, Soulslike combat, living LLM-driven cast). → `genre-and-themes.md`
