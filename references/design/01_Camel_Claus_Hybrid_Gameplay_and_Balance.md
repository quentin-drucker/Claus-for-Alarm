# Camel Claus — Hybrid Gameplay, Simulation & Balance Specification

**Edition:** H0 — design-lock draft for review; **date:** 2026-11-13. **Status:** Planning document, NOT an instruction to begin coding.  
**Reference files:** `BTD6_Gameplay_Systems_Mechanics_and_Balance.md`; `BTD6_Art_Audio_Visuals_and_UX.md`; `BTD6_3D_Asset_Modeling_and_Blender_Production_Reference.md`.  
**Partner hybrid files:** `02_Camel_Claus_Hybrid_Art_UI_Audio.md` and `03_Camel_Claus_Hybrid_3D_Assets_Blender.md`.

**Owner scope decision (2026-11-14): Winter Games Lodge (Monkey Village) and Track Gritter (Spike Factory) are DEFERRED beyond the hackathon submission. Do not create, implement, or include these towers in the hackathon build. Existing concepts are retained only for a possible later expansion/extension; future production requires renewed authorization.**

> **Scope lock:** Six INITIAL towers: Snowball Rookie ← Dart Monkey; Avalanche Cannon ← Bomb Shooter; Biathlon Ranger ← Sniper Monkey; Slope Wax Sprayer ← Glue Gunner; Snow Sorcerer ← Wizard Monkey; Ski Resort Ticket Booth ← Banana Farm. **Hero:** Camel Claus ← Quincy. Two PLANNED towers: Hockey Slapper ← Boomerang Monkey; Snowboard Trickster ← Ninja Monkey. Two DEFERRED optional post-hackathon towers: Winter Games Lodge ← Monkey Village; Track Gritter ← Spike Factory. **Explicit exclusions:** Dartling Gunner, Monkey Ace, Engineer Monkey / Rink Engineer, Ice Monkey, Tack Shooter, Alchemist, and their reskins. Exclusion is a *roster decision*, not a ban on using underlying reusable engine concepts.

## M-00. Reading policy and truth labels

- `[LOCKED]`: user-approved creative direction or scope; `[PROPOSED]`: original design suggestion for approval.
- `[V56]`: extracted/reference price or stat from the prior BTD6 v56 research; not a verified 57.4 figure.
- `[P57]`: publisher patch-note change in BTD6 v57.0; check it with later minor patches before declaring exact 57.4 parity.
- `[EVIDENCE]`: current corroborating source cited by URL.
- `[GAP]`: a missing exact behavior, timing, crosspath interaction, or data field; **NEVER invent a value** to close a gap.
- `[ENGINEERING]`: recommended Godot implementation; not a claim about BTD6 internals.

**Reference version policy.** BTD6 57.4 was reported available for most platforms on November 13, 2026; our comprehensive price tables inherit v56; explicit v57 changes are overrides. References: [Ninja Kiwi Nov. 13](https://www.reddit.com/r/NinjaKiwiOfficial/comments/1xv5l7j/whats_up_at_ninja_kiwi_13th_november_2026/), [v57 patch notes](https://gameupdatenotifier.com/g/bloons-td-6/v/57-0), [v56 extracted model](https://teemo.dev/game-design/bloons-td-6/wiki/). Maintain `reference_version`, `source_url`, `verification_status`, `difficulty`, `crosspath` and `observed_at` on each numeric claim.

**Do not declare strict BTD6 parity merely because the price names and 140 round RBE are known.** The inherited references lack a fully checked set of every upgrade's exact attack transforms, all legal crosspath variants, and 140 rounds' complete group start/duration schedules. A `source_gameplay_mode` is a *target fidelity mode*, not proof of exact reproduction.

## M-01. Project identity and boundaries [LOCKED]

- Studio/team: **Camel Claus**; game title: **Claus for Alarm**.
- Event themes: festive/Christmas-at-Connecticut-College plus secret sub-theme **Winter Sports**.
- World: a playful snowy college winter-games festival, not an existing BTD6 level, franchise or ripped art collection.
- Defenders: toy-like humanoid winter athletes and winter-sport machines; their bodies are not realistic humans. One camel hero: Camel Claus.
- Opponents: **rolling, colored, layered snowballs**, not humanoid invaders or balloons; outer color communicates current tier; separately shaped indicators communicate special properties.
- Planned release target: desktop-browser playable Godot 4.7.2 project, GDScript, Compatibility renderer. Web build must be tested in an actual browser.
- Development priority: **simulation/mechanics first** with disposable shapes/UI placeholders; art/models/sound in subsequent replaceable passes. **Do not start implementation until the user approves these three hybrid references and later requests the separate master plan.**

## M-02. System invariants and contract with presentation

Each functional operation must emit a semantic presentation event and remain correct even if no VFX, music or models are loaded. Event contracts include `tower_placed`, `purchase_failed`, `tower_upgraded`, `target_changed`, `attack_fired`, `enemy_hit`, `enemy_immune`, `layer_broken`, `enemy_split`, `enemy_leaked`, `status_applied`, `ability_ready`, `ability_used`, `hero_level_up`, `round_started`, `round_complete`, `income_collected`, `match_won`, `match_lost`. UI/FX never decide damage, income or round outcomes. See `02...md`, sections A-05 to A-09.

**Minimum loop:** load map → choose placements → buy eligible defenders → run scripted snowball waves → hit/resolve layers → earn cash → buy and crosspath → activate hero ability → defend exit → win or lose → replay. Rounds are preparation/spawn/cleanup/reward states, not a single timer that ends while child snowballs remain.

**Core strategic axes:** affordability; attack interval; projectiles/volley; projectile range and travel; pierce and hit count; attack geometry; typed immunity/detection; slowing and DoT; anti-large-enemy damage; global targeting; income investment; timing for saving for tier-3 and tier-4 power spikes; spatial path exposure. Towers that are strong on a short path may be weak on a long double-bend, even with identical listed DPS.

## M-03. Color-layer snowball rules: preserve the readable mechanic and expose the deviation

### M-03.1 User-approved visual spectrum [LOCKED]

| Visible snowball | Relative depth | Display cue | Suggested internal combat analogue | Fidelity caveat |
|---|---:|---|---|---|
| Powder | 1 | pale frosted white with deep shadow edging | Red bloon | The source uses red, not white; new color only |
| Blue | 2 | saturated cool blue shell | Blue bloon | Same one-layer break concept |
| Mint | 3 | green-mint crystalline crust | Green bloon | Same layering concept |
| Violet | 4 | violet shell and swirl grooves | Yellow bloon | Preserve Yellow's speed class, not just HP |
| Coral | 5 | peach-coral shell with bright flecks | Pink bloon | Preserve Pink's fast movement class |
| Gold | 6 | warm golden shell with star-like ice flakes | **Original extension** OR special branching class | **NOT a one-to-one standard basic color** in BTD6 |

**Important design conflict:** BTD6's early conventional layer ladder is Red → Blue → Green → Yellow → Pink (five common tiers). Black, White, Purple, Zebra, Lead and Ceramic introduce *branching children, resistances and special interactions*, not a generic sixth step. Therefore, **a Gold sixth snowball with six linear layers is an ORIGINAL balance change**, even if its texture fits perfectly. Recommended conservative plan: keep BTD6's five foundational mechanical tiers as Powder/Blue/Mint/Violet/Coral and reserve Gold as a visually striking later special/armored snowball with an explicit `child_spawn_tree` and immunity rule. If the user wants Gold as a true sixth basic layer, label its new 6→5 mechanics and rebalance waves/income accordingly. **Approval gate: choose Gold semantics before round scripts are finalized.**

### M-03.2 Layer break behavior

- A normal `damage = 1` removes one corresponding layer in the vanilla linear tier chain. Outer-shell loss instantly changes shell appearance and may change movement speed according to the descendant type; do not treat layer as merely a color on an unchanged HP bar.
- Simulate the *source* child structure using canonical snowball `type_id` and `on_break_spawns` definitions. A source Ceramic, Lead, Zebra, MOAB, DDT and BAD are not implemented as merely larger colored balls with one HP integer.
- Maintain separate `shell_hp`, `descendant_tree`, `speed`, `rbe`, `leak_damage`, `properties`, `on_break_spawn`, and `movement_progress`. Apply inherited effects to children according to explicit source/implementation rules.
- A tower's ability to target a snowball, see its camo analog, damage its material, apply wax, and destroy its descendants are four distinct checks.
- **Gold art rule:** gold conveys rarity/elite status; do not teach Gold = fixed 6 HP unless the six-tier custom mode is approved.

### M-03.3 Special classes [PROPOSED cosmetics; BTD6 mechanics pending mapping]

| Source mechanic | Original snowball concept | Required separate visible cue |
|---|---|---|
| Camo | Whiteout snowball / hidden snowfall | patterned shimmering tracks or goggles glyph; visibility toggle |
| Regrow | Repacking snowball | orbiting stitch/snowflake regeneration motif |
| Lead | Steel-core or rock-hard snowball | visible hard metal plate and dull impact |
| Purple | Arcane insulation snowball | violet etched circuitry / shielding ring |
| Black | Blast-resistant coal-core snowball | charcoal seams and heavy silhouette |
| White | Cold-resistant glacier snowball | ice crust and cold-reflection pattern |
| Zebra | Alternating resistant snowball | unmistakable stripes, not color-only |
| Ceramic | Packed-ice shell snowball | cracked plate shell with state-driven break |
| Fortified | Armored snowball | distinct riveted armor band visible with base shell color |
| MOAB / BFB / ZOMG / DDT / BAD | Giant rolling snow masses / festival-course hazard bosses | six **separately recognizable** silhouettes, fast/stealth/armor cues where relevant |

Preserve **property channels** instead of relabeling every resistance as simply extra HP. All special types above need exact v56/v57 base speed/durability/children records from the BTD6 reference before declaring parity. The choice of giant snowball versus animated avalanche machine is visual, not mechanical.

## M-04. BTD6 baseline player economy and rounds

**Difficulty pricing:** medium stores base cost; Easy 0.85×; Hard 1.08×; Impoppable 1.20×; reference rounding applied per purchase to nearest $5. **Verify corner-case rounding before claiming bit-identical parity.**  
**Selling:** standard 70% investment return, modified by modes/knowledge.  
**Income:** pop income per layer/descendant subject to phase multipliers, plus baseline end-of-round payout `100 + round`, plus farm/bank/supply ability income. **Farm income is not pop income**. Source: [rounds/economy](https://teemo.dev/game-design/bloons-td-6/systems/rounds-and-economy/) and [price modifiers](https://teemo.dev/game-design/bloons-td-6/systems/prices-discounts-and-selling/).

Do not make the entire first 10–15-round playable demo draw random waves and then call it BTD6-balanced. Reference exact scripted enemy counts, type and spawn offsets in the actual [round pages](https://teemo.dev/game-design/bloons-td-6/wiki/rounds/). Source round 1 is 20 Reds over 17.5 seconds; round 40 introduces one MOAB; round 63 is a notorious ceramic rush. **The full 140-round index in the original document supplies RBE and income, not the precise group schedule.** The team can choose a short event-length session, but MUST state whether rounds are an exact slice of BTD6 or an original condensed campaign; they are not interchangeable balance assumptions.

**Source checkpoints to test** (only when relevant to chosen round range): first camo counter; first armor/Lead counter; first large shell; first grouped rush; round 40 single MOAB; round 63 layered ceramic challenge; round 80 ZOMG; round 81 ceramic behavior transition; round 90 DDT; round 100 BAD. Earlier rounds are often easier; do not claim a 15-wave jam set follows the full source economy if tiers 4–5 cost tens of thousands.

## M-05. Targeting, collision and deterministic simulation [ENGINEERING]

- Use independent `TargetingPolicy` (`FIRST`, `LAST`, `CLOSE`, `STRONG`) and optional specialized policies. First/Last use normalized path progress, Strong uses **specified enemy tier ordering** rather than raw shell HP.
- Track attacks with separate definitions: `AttackDefinition`, `ProjectileDefinition`, `OnHitEffect`, `OnBreakEffect`, `AbilityDefinition`, `BuffDefinition`, `EconomyDefinition`.
- Pierce is a maximum number of distinct eligible collisions or targets handled by a hit source; **do not confuse with damage per target**.
- When an effect has no valid target due to immunity, emit an immune event, do not silently reduce HP or spend extra projectile pierce unless the rule specifies it.
- Line-of-sight, placement footprint, tower rotation/muzzle position, projectile travel, height-plane intersections and walls each need documented conventions; visual top-down range rings must correspond to exact simulation range.
- Prefer stable fixed simulation steps and deterministic spawn ordering. Represent screen speed multipliers as time scaling, not code branches altering attack data. Suspend gameplay timers (including cooldown and economy timers) consistently under pause.
- Unique attack IDs / per-target hit gates prevent unintended multiple hits in one frame from a single projectile; apply intentional recursion/fragmentation and child spawning in a deterministic order.
- Support statuses with typed stacking groups: normal wax, giant-snowball wax, corrosive wax, hero special, damage vulnerability, and support effects should not accidentally stack additively because scripts were written independently.

### M-05.1 Damage pipeline pseudocode

```text
for attack_event in stable_order:
    if actor_unavailable_or_attack_on_cooldown: continue
    target = acquire_target(range, line_of_sight, detection, priority)
    if no_valid_target: continue
    spawn_projectile_or_area_hit(attack_event, target)

for collision_event in stable_order:
    if hit_cache_contains(target) or pierce_exhausted: continue
    if target_rejects_damage_type: emit enemy_immune; continue
    damage = compute_damage(base, additive_bonuses, multipliers, target_properties)
    apply_damage_to_current_shell(damage)
    apply_status_if_allowed()
    if shell_broken: reward_income_and_spawn_children_preserving_progress()
    consume_projectile_pierce_using_defined_rule()
    emit hit_and_layer_events()
```

**Special tests:** Frozen/Lead/Black/Purple immunity, camo detection, area explosive child hits, huge snowballs splitting into multiple descendants, wax soak/splash, crosspath upgrade legality, snipers selecting global targets, boss shell damage, and tower actions while paused.

## M-06. Roster status and mechanical source mapping

| Status | Winter name | BTD6 original | Role | Modeling family |
|---|---|---|---|---|
| INITIAL | Snowball Rookie | Dart Monkey | Cheap direct fire / pierce; multiple-shot squad; precision launcher | Athlete |
| INITIAL | Avalanche Cannon | Bomb Shooter | Area blast / giant-target missile / fragmentation clusters | Machine/Building |
| INITIAL | Biathlon Ranger | Sniper Monkey | Global precision / bouncing-ammo income / rapid fire | Athlete |
| INITIAL | Slope Wax Sprayer | Glue Gunner | Persistent slowing / corrosive damage / mass coating | Athlete |
| INITIAL | Snow Sorcerer | Wizard Monkey | Guided elemental projectile / heat wave summon / revived-snowball effects | Athlete |
| INITIAL | Ski Resort Ticket Booth | Banana Farm | Per-round income / bank / automated marketplace | Machine/Building |
| PLANNED | Hockey Slapper | Boomerang Monkey | Ricocheting blade / burst charge / giant pushback | Athlete |
| PLANNED | Snowboard Trickster | Ninja Monkey | Camo detection / multi-shuriken / sabotage / sticky burst | Athlete |
| DEFERRED (post-hackathon, optional) | Winter Games Lodge | Monkey Village | Area buffs / detection support / income discounts | Machine/Building |
| DEFERRED (post-hackathon, optional) | Track Gritter | Spike Factory | Persistent track traps / area bursts / long-lived hazards | Machine/Building |
| HERO | Camel Claus | Quincy | Automatic XP-based scaling, chain-hit attack, two abilities, Lv4 Focus toggle | Hero camel |

The four planned towers are **not** part of initial release commitment. No other existing BTD6 counterpart is automatically in scope.

## M-07. The crosspath upgrade matrix — all approved towers

**Rule [V56]:** ordinary towers have three 0–5 paths; a primary path may reach tier 3–5, one other path may reach tier 0–2, and the third remains 0. Thus `5-2-0`, `0-2-5`, `2-0-5` are legal examples. Each family has 64 broadly legal configurations before tower-specific restrictions. Tier-1/2 often act as secondary enhancements; tier-3 defines specialization; tier-4 frequently unlocks stronger attacks/active abilities; tier-5 is a decisive signature path. Special exceptions require overrides, not generic math.

**Upgrade table columns:** Original BTD6 names and v56 Medium prices are the factual *source reference*. Winter names are proposed original names. v57 changes are explicitly highlighted. Beyond base stats and listed overrides, this table is **not** a substitute for exact per-upgrade damage, interval, pierce, ability or crosspath verification. When coding, load the corresponding individual source upgrade pages or configuration models and write a verified `AttackDefinition` for each implemented row.

### Snowball Rookie — reference: Dart Monkey [INITIAL]
**Internal ID:** `snowball_rookie` · **BTD6 origin:** `Dart Monkey` · **Source:** https://teemo.dev/game-design/bloons-td-6/wiki/towers/dart-monkey/ · **v56 Medium base cost:** $200 · **Range reference:** 32.
**Fantasy appearance:** winter-sports rookie with a compact snowball sling. **Gameplay responsibility:** Cheap direct fire / pierce; multiple-shot squad; precision launcher.
**Mechanical contract:** inherit the BTD6 attack family, projectile behavior, resistances, targeting and legal crosspaths; do not infer exact stat mutations from tier titles. Every upgrade that adds/replaces an attack needs a separately validated attack definition. The following are *cosmetic working names* aligned by path/tier, not translations of copyrighted descriptions.

| Path | Tier | Original BTD6 upgrade | Working winter name | Medium reference price | Accuracy note |
|---|---:|---|---|---:|---|
| Top | 1 | Sharp Shots | Sharper Snow | $140 | v56 price; effect requires per-upgrade verification |
| Top | 2 | Razor Sharp Shots | Reinforced Ice | $200 | v56 price; effect requires per-upgrade verification |
| Top | 3 | Spike-o-pult | Ice Boulder Launcher | $320 | v56 price; effect requires per-upgrade verification |
| Top | 4 | Juggernaut | Championship Boulder | $1,800 | v56 price; effect requires per-upgrade verification |
| Top | 5 | Ultra-Juggernaut | Avalanche Juggernaut | $15,000 | v56 price; effect requires per-upgrade verification |
| Middle | 1 | Quick Shots | Quick Hands | $100 | v56 price; effect requires per-upgrade verification |
| Middle | 2 | Very Quick Shots | Faster Tosses | $190 | v56 price; effect requires per-upgrade verification |
| Middle | 3 | Triple Shot | Triple Toss | $450 | v56 price; effect requires per-upgrade verification |
| Middle | 4 | Super Monkey Fan Club | Rookie Rally | $7,200 | v56 price; effect requires per-upgrade verification |
| Middle | 5 | Plasma Monkey Fan Club | All-Star Rally | $45,000 | v56 price; effect requires per-upgrade verification |
| Bottom | 1 | Long Range Darts | Long-Distance Lob | $90 | v56 price; effect requires per-upgrade verification |
| Bottom | 2 | Enhanced Eyesight | Goggle Targeting | $200 | v56 price; effect requires per-upgrade verification |
| Bottom | 3 | Crossbow | Ski-Bow | $575 | v57: xx3 pierce 4→5 |
| Bottom | 4 | Sharp Shooter | Medal Marksman | $2,050 | v57: crit damage 50→60 |
| Bottom | 5 | Crossbow Master | Olympic Sharpshooter | $21,500 | v57: 2 parallel projectiles per attack; interval 0.475 s (was 1 / 0.2375 s) |

**Path identity and visual escalation:** top path should acquire a clearly recognizable precision/power silhouette by tier 3; middle should advertise its ability, attack pattern, or broad utility by tier 3; bottom should advertise its special attack / endurance / automation role by tier 3. Tier 1–2 mostly modify accessory and projectile effects. Tier 4–5 receive deliberately stronger silhouettes. The production art document specifies visual exceptions by tower.

### Avalanche Cannon — reference: Bomb Shooter [INITIAL]
**Internal ID:** `avalanche_cannon` · **BTD6 origin:** `Bomb Shooter` · **Source:** https://teemo.dev/game-design/bloons-td-6/wiki/towers/bomb-shooter/ · **v56 Medium base cost:** $375 · **Range reference:** 40.
**Fantasy appearance:** compact ski-slope snow cannon. **Gameplay responsibility:** Area blast / giant-target missile / fragmentation clusters.
**Mechanical contract:** inherit the BTD6 attack family, projectile behavior, resistances, targeting and legal crosspaths; do not infer exact stat mutations from tier titles. Every upgrade that adds/replaces an attack needs a separately validated attack definition. The following are *cosmetic working names* aligned by path/tier, not translations of copyrighted descriptions.

| Path | Tier | Original BTD6 upgrade | Working winter name | Medium reference price | Accuracy note |
|---|---:|---|---|---:|---|
| Top | 1 | Bigger Bombs | Wide Snowburst | $250 | v56 price; effect requires per-upgrade verification |
| Top | 2 | Heavy Bombs | Dense Charges | $650 | v56 price; effect requires per-upgrade verification |
| Top | 3 | Really Big Bombs | Massive Snowblast | $1,100 | v56 price; effect requires per-upgrade verification |
| Top | 4 | Bloon Impact | Impact Freeze | $2,800 | v56 price; effect requires per-upgrade verification |
| Top | 5 | Bloon Crush | Mountain Crusher | $55,000 | v56 price; effect requires per-upgrade verification |
| Middle | 1 | Faster Reload | Quick Reload | $250 | v56 price; effect requires per-upgrade verification |
| Middle | 2 | Missile Launcher | Snow Missile | $400 | v56 price; effect requires per-upgrade verification |
| Middle | 3 | MOAB Mauler | Big-Game Breaker | $1,000 | v56 price; effect requires per-upgrade verification |
| Middle | 4 | MOAB Assassin | Avalanche Assassin | $3,450 | v56 price; effect requires per-upgrade verification |
| Middle | 5 | MOAB Eliminator | Titan Eliminator | $26,000 | v56 price; effect requires per-upgrade verification |
| Bottom | 1 | Extra Range | Long Barrel | $200 | v56 price; effect requires per-upgrade verification |
| Bottom | 2 | Frag Bombs | Fragment Pack | $300 | v57: frag pierce 1→2, pierce penalty +1 |
| Bottom | 3 | Cluster Bombs | Cluster Burst | $700 | v56 price; effect requires per-upgrade verification |
| Bottom | 4 | Recursive Cluster | Recursive Clusters | $2,500 | v56 price; effect requires per-upgrade verification |
| Bottom | 5 | Bomb Blitz | Blizzard Blitz | $30,000 | v57: passive triggers at most once/round |

**Path identity and visual escalation:** top path should acquire a clearly recognizable precision/power silhouette by tier 3; middle should advertise its ability, attack pattern, or broad utility by tier 3; bottom should advertise its special attack / endurance / automation role by tier 3. Tier 1–2 mostly modify accessory and projectile effects. Tier 4–5 receive deliberately stronger silhouettes. The production art document specifies visual exceptions by tower.

### Biathlon Ranger — reference: Sniper Monkey [INITIAL]
**Internal ID:** `biathlon_ranger` · **BTD6 origin:** `Sniper Monkey` · **Source:** https://teemo.dev/game-design/bloons-td-6/wiki/towers/sniper-monkey/ · **v56 Medium base cost:** $350 · **Range reference:** whole map*.
**Fantasy appearance:** chibi biathlon athlete with safe fantasy-targeting sports equipment. **Gameplay responsibility:** Global precision / bouncing-ammo income / rapid fire.
**Mechanical contract:** inherit the BTD6 attack family, projectile behavior, resistances, targeting and legal crosspaths; do not infer exact stat mutations from tier titles. Every upgrade that adds/replaces an attack needs a separately validated attack definition. The following are *cosmetic working names* aligned by path/tier, not translations of copyrighted descriptions.

| Path | Tier | Original BTD6 upgrade | Working winter name | Medium reference price | Accuracy note |
|---|---:|---|---|---:|---|
| Top | 1 | Full Metal Jacket | Reinforced Ice Rounds | $350 | v56 price; effect requires per-upgrade verification |
| Top | 2 | Large Calibre | High-Caliber Pellet | $1,300 | v56 price; effect requires per-upgrade verification |
| Top | 3 | Deadly Precision | Medal Precision | $2,200 | v56 price; effect requires per-upgrade verification |
| Top | 4 | Maim MOAB | Giant-Snowball Stun | $6,300 | v56 price; effect requires per-upgrade verification |
| Top | 5 | Cripple MOAB | Champion Crippler | $32,000 | v56 price; effect requires per-upgrade verification |
| Middle | 1 | Night Vision Goggles | Night Ski Goggles | $250 | v56 price; effect requires per-upgrade verification |
| Middle | 2 | Shrapnel Shot | Scatter Shards | $450 | v56 price; effect requires per-upgrade verification |
| Middle | 3 | Bouncing Bullet | Bankshot Pellet | $2,100 | v56 price; effect requires per-upgrade verification |
| Middle | 4 | Supply Drop | Supply Beacon | $7,600 | v57: Cash Drop / Ammo Drop toggle; shared cooldown |
| Middle | 5 | Elite Sniper | Elite Biathlete | $12,000 | v56 price; effect requires per-upgrade verification |
| Bottom | 1 | Fast Firing | Fast Trigger | $450 | v56 price; effect requires per-upgrade verification |
| Bottom | 2 | Even Faster Firing | Faster Trigger | $450 | v56 price; effect requires per-upgrade verification |
| Bottom | 3 | Semi-Automatic | Rapid Cycle | $2,700 | v56 price; effect requires per-upgrade verification |
| Bottom | 4 | Full Auto Rifle | Automatic Sports Launcher | $4,100 | v56 price; effect requires per-upgrade verification |
| Bottom | 5 | Elite Defender | Final-Lap Defender | $14,900 | v56 price; effect requires per-upgrade verification |

**Path identity and visual escalation:** top path should acquire a clearly recognizable precision/power silhouette by tier 3; middle should advertise its ability, attack pattern, or broad utility by tier 3; bottom should advertise its special attack / endurance / automation role by tier 3. Tier 1–2 mostly modify accessory and projectile effects. Tier 4–5 receive deliberately stronger silhouettes. The production art document specifies visual exceptions by tower.
**Critical exception:** BTD6 Sniper has global targeting subject to sight/visibility rules; the displayed reference range is *not* an ordinary short circular attack radius. Model all three targeting conditions and v57 ammunition mode.

### Slope Wax Sprayer — reference: Glue Gunner [INITIAL]
**Internal ID:** `slope_wax_sprayer` · **BTD6 origin:** `Glue Gunner` · **Source:** https://teemo.dev/game-design/bloons-td-6/wiki/towers/glue-gunner/ · **v56 Medium base cost:** $225 · **Range reference:** 46.
**Fantasy appearance:** playful wax-and-slush ski technician. **Gameplay responsibility:** Persistent slowing / corrosive damage / mass coating.
**Mechanical contract:** inherit the BTD6 attack family, projectile behavior, resistances, targeting and legal crosspaths; do not infer exact stat mutations from tier titles. Every upgrade that adds/replaces an attack needs a separately validated attack definition. The following are *cosmetic working names* aligned by path/tier, not translations of copyrighted descriptions.

| Path | Tier | Original BTD6 upgrade | Working winter name | Medium reference price | Accuracy note |
|---|---:|---|---|---:|---|
| Top | 1 | Glue Soak | Deep Coating | $200 | v56 price; effect requires per-upgrade verification |
| Top | 2 | Corrosive Glue | De-Icing Formula | $300 | v56 price; effect requires per-upgrade verification |
| Top | 3 | Bloon Dissolver | Snowball Dissolver | $2,000 | v56 price; effect requires per-upgrade verification |
| Top | 4 | Bloon Liquefier | Slush Liquefier | $5,000 | v56 price; effect requires per-upgrade verification |
| Top | 5 | The Bloon Solver | The Meltdown | $22,500 | v56 price; effect requires per-upgrade verification |
| Middle | 1 | Bigger Globs | Bigger Splashes | $100 | v56 price; effect requires per-upgrade verification |
| Middle | 2 | Glue Splatter | Wax Splatter | $650 | v57: price $970→$650 |
| Middle | 3 | Glue Hose | Pressure Hose | $1,950 | v56 price; effect requires per-upgrade verification |
| Middle | 4 | Glue Strike | Slope Strike | $4,500 | v57: price $4,000→$4,500 |
| Middle | 5 | Glue Storm | Wax Storm | $16,000 | v56 price; effect requires per-upgrade verification |
| Bottom | 1 | Stickier Glue | Long-Lasting Wax | $280 | v57: glue duration 24→18 s |
| Bottom | 2 | Stronger Glue | Extra Grip | $400 | v56 price; effect requires per-upgrade verification |
| Bottom | 3 | MOAB Glue | Giant Snowball Wax | $3,600 | v56 price; effect requires per-upgrade verification |
| Bottom | 4 | Relentless Glue | Relentless Slip | $4,000 | v56 price; effect requires per-upgrade verification |
| Bottom | 5 | Super Glue | Absolute Traction Lock | $24,000 | v56 price; effect requires per-upgrade verification |

**Path identity and visual escalation:** top path should acquire a clearly recognizable precision/power silhouette by tier 3; middle should advertise its ability, attack pattern, or broad utility by tier 3; bottom should advertise its special attack / endurance / automation role by tier 3. Tier 1–2 mostly modify accessory and projectile effects. Tier 4–5 receive deliberately stronger silhouettes. The production art document specifies visual exceptions by tower.
**Critical exception:** wax is a status effect: a hit need not remove a snowball layer. Damage-over-time upgrades, slow stacking and special large-snowball compatibility must be explicit.

### Snow Sorcerer — reference: Wizard Monkey [INITIAL]
**Internal ID:** `snow_sorcerer` · **BTD6 origin:** `Wizard Monkey` · **Source:** https://teemo.dev/game-design/bloons-td-6/wiki/towers/wizard-monkey/ · **v56 Medium base cost:** $250 · **Range reference:** 40.
**Fantasy appearance:** winter-festival conjurer in sporty coat and snowflake staff. **Gameplay responsibility:** Guided elemental projectile / heat wave summon / revived-snowball effects.
**Mechanical contract:** inherit the BTD6 attack family, projectile behavior, resistances, targeting and legal crosspaths; do not infer exact stat mutations from tier titles. Every upgrade that adds/replaces an attack needs a separately validated attack definition. The following are *cosmetic working names* aligned by path/tier, not translations of copyrighted descriptions.

| Path | Tier | Original BTD6 upgrade | Working winter name | Medium reference price | Accuracy note |
|---|---:|---|---|---:|---|
| Top | 1 | Guided Magic | Guided Frost | $175 | v56 price; effect requires per-upgrade verification |
| Top | 2 | Arcane Blast | Arcane Snowburst | $450 | v56 price; effect requires per-upgrade verification |
| Top | 3 | Arcane Mastery | Frostcraft Mastery | $1,450 | v56 price; effect requires per-upgrade verification |
| Top | 4 | Arcane Spike | Arctic Spike | $10,000 | v56 price; effect requires per-upgrade verification |
| Top | 5 | Archmage | Grand Snowmage | $32,000 | v56 price; effect requires per-upgrade verification |
| Middle | 1 | Fireball | Warm Ember | $300 | v56 price; effect requires per-upgrade verification |
| Middle | 2 | Wall of Fire | Hot Cocoa Barrier | $800 | v56 price; effect requires per-upgrade verification |
| Middle | 3 | Dragon's Breath | Blizzard Breath | $3,300 | v56 price; effect requires per-upgrade verification |
| Middle | 4 | Summon Phoenix | Summon Snowbird | $6,000 | v56 price; effect requires per-upgrade verification |
| Middle | 5 | Wizard Lord Phoenix | Winter Phoenix | $50,000 | v56 price; effect requires per-upgrade verification |
| Bottom | 1 | Intense Magic | Deep Snowcraft | $300 | v56 price; effect requires per-upgrade verification |
| Bottom | 2 | Monkey Sense | Frost-Sight | $300 | v56 price; effect requires per-upgrade verification |
| Bottom | 3 | Shimmer | Goggle Shimmer | $1,500 | v56 price; effect requires per-upgrade verification |
| Bottom | 4 | Necromancer: Unpopped Army | Snow Spirit Army | $2,800 | v56 price; effect requires per-upgrade verification |
| Bottom | 5 | Prince of Darkness | Snowfall Sovereign | $26,500 | v56 price; effect requires per-upgrade verification |

**Path identity and visual escalation:** top path should acquire a clearly recognizable precision/power silhouette by tier 3; middle should advertise its ability, attack pattern, or broad utility by tier 3; bottom should advertise its special attack / endurance / automation role by tier 3. Tier 1–2 mostly modify accessory and projectile effects. Tier 4–5 receive deliberately stronger silhouettes. The production art document specifies visual exceptions by tower.

### Ski Resort Ticket Booth — reference: Banana Farm [INITIAL]
**Internal ID:** `ski_resort_ticket_booth` · **BTD6 origin:** `Banana Farm` · **Source:** https://teemo.dev/game-design/bloons-td-6/wiki/towers/banana-farm/ · **v56 Medium base cost:** $1,250 · **Range reference:** 40*.
**Fantasy appearance:** resort kiosk generating lift-pass tokens. **Gameplay responsibility:** Per-round income / bank / automated marketplace.
**Mechanical contract:** inherit the BTD6 attack family, projectile behavior, resistances, targeting and legal crosspaths; do not infer exact stat mutations from tier titles. Every upgrade that adds/replaces an attack needs a separately validated attack definition. The following are *cosmetic working names* aligned by path/tier, not translations of copyrighted descriptions.

| Path | Tier | Original BTD6 upgrade | Working winter name | Medium reference price | Accuracy note |
|---|---:|---|---|---:|---|
| Top | 1 | Increased Production | More Passes | $500 | v56 price; effect requires per-upgrade verification |
| Top | 2 | Greater Production | Peak Ticket Sales | $600 | v56 price; effect requires per-upgrade verification |
| Top | 3 | Banana Plantation | Ski Resort Expansion | $3,000 | v56 price; effect requires per-upgrade verification |
| Top | 4 | Banana Research Facility | Research Chalet | $19,000 | v56 price; effect requires per-upgrade verification |
| Top | 5 | Banana Central | Winter Games Central | $115,000 | v56 price; effect requires per-upgrade verification |
| Middle | 1 | Long Life Bananas | Better Accounting | $300 | v56 price; effect requires per-upgrade verification |
| Middle | 2 | Valuable Bananas | Savings Program | $800 | v56 price; effect requires per-upgrade verification |
| Middle | 3 | Monkey Bank | Resort Bank | $3,650 | v56 price; effect requires per-upgrade verification |
| Middle | 4 | IMF Loan | Investment Fund | $7,200 | v56 price; effect requires per-upgrade verification |
| Middle | 5 | Monkey-Nomics | World Cup Bank | $100,000 | v56 price; effect requires per-upgrade verification |
| Bottom | 1 | EZ Collect | Self-Service Window | $250 | v56 price; effect requires per-upgrade verification |
| Bottom | 2 | Banana Salvage | Tourist Merchandise | $400 | v56 price; effect requires per-upgrade verification |
| Bottom | 3 | Marketplace | Ski Marketplace | $2,700 | v56 price; effect requires per-upgrade verification |
| Bottom | 4 | Central Market | Sponsor Partnership | $15,000 | v56 price; effect requires per-upgrade verification |
| Bottom | 5 | Monkey Wall Street | Regional Ski Empire | $70,000 | v56 price; effect requires per-upgrade verification |

**Path identity and visual escalation:** top path should acquire a clearly recognizable precision/power silhouette by tier 3; middle should advertise its ability, attack pattern, or broad utility by tier 3; bottom should advertise its special attack / endurance / automation role by tier 3. Tier 1–2 mostly modify accessory and projectile effects. Tier 4–5 receive deliberately stronger silhouettes. The production art document specifies visual exceptions by tower.
**Critical exception:** this is an economic building with pickups/collection/storage/bank logic, not a ranged DPS unit. Maintain banana/payout cadence and economic constraints instead of substituting generic income every second.


## M-08. PLANNED, not initial, upgrade catalogs

These four families are documented so the engine remains extensible. Do not build them, their tier-five models, or their VFX for the first playable unless the scope is deliberately expanded.

### Hockey Slapper — reference: Boomerang Monkey [PLANNED]
**Internal ID:** `hockey_slapper` · **BTD6 origin:** `Boomerang Monkey` · **Source:** https://teemo.dev/game-design/bloons-td-6/wiki/towers/boomerang-monkey/ · **v56 Medium base cost:** $315 · **Range reference:** 43.
**Fantasy appearance:** ice-hockey athlete with signature returning puck. **Gameplay responsibility:** Ricocheting blade / burst charge / giant pushback.
**Mechanical contract:** inherit the BTD6 attack family, projectile behavior, resistances, targeting and legal crosspaths; do not infer exact stat mutations from tier titles. Every upgrade that adds/replaces an attack needs a separately validated attack definition. The following are *cosmetic working names* aligned by path/tier, not translations of copyrighted descriptions.

| Path | Tier | Original BTD6 upgrade | Working winter name | Medium reference price | Accuracy note |
|---|---:|---|---|---:|---|
| Top | 1 | Improved Rangs | Balanced Puck | $200 | v56 price; effect requires per-upgrade verification |
| Top | 2 | Glaives | Razor Puck | $280 | v56 price; effect requires per-upgrade verification |
| Top | 3 | Glaive Ricochet | Puck Ricochet | $600 | v56 price; effect requires per-upgrade verification |
| Top | 4 | M.O.A.R Glaives | Rapid Ricochet | $2,000 | v56 price; effect requires per-upgrade verification |
| Top | 5 | Glaive Lord | Puck Orbit Champion | $32,500 | v56 price; effect requires per-upgrade verification |
| Middle | 1 | Faster Throwing | Faster Slapshot | $175 | v56 price; effect requires per-upgrade verification |
| Middle | 2 | Faster Rangs | Turbo Stick | $250 | v56 price; effect requires per-upgrade verification |
| Middle | 3 | Bionic Boomerang | Motorized Stick | $1,250 | v56 price; effect requires per-upgrade verification |
| Middle | 4 | Turbo Charge | Overtime Charge | $4,200 | v56 price; effect requires per-upgrade verification |
| Middle | 5 | Perma Charge | Permanent Power Play | $35,000 | v56 price; effect requires per-upgrade verification |
| Bottom | 1 | Long Range Rangs | Long-Reach Puck | $100 | v56 price; effect requires per-upgrade verification |
| Bottom | 2 | Red Hot Rangs | Heated Puck | $300 | v56 price; effect requires per-upgrade verification |
| Bottom | 3 | Kylie Boomerang | Heavy Puck | $1,300 | v56 price; effect requires per-upgrade verification |
| Bottom | 4 | MOAB Press | Giant Snowball Press | $2,700 | v56 price; effect requires per-upgrade verification |
| Bottom | 5 | MOAB Domination | Final Period Domination | $50,000 | v56 price; effect requires per-upgrade verification |

**Path identity and visual escalation:** top path should acquire a clearly recognizable precision/power silhouette by tier 3; middle should advertise its ability, attack pattern, or broad utility by tier 3; bottom should advertise its special attack / endurance / automation role by tier 3. Tier 1–2 mostly modify accessory and projectile effects. Tier 4–5 receive deliberately stronger silhouettes. The production art document specifies visual exceptions by tower.

### Snowboard Trickster — reference: Ninja Monkey [PLANNED]
**Internal ID:** `snowboard_trickster` · **BTD6 origin:** `Ninja Monkey` · **Source:** https://teemo.dev/game-design/bloons-td-6/wiki/towers/ninja-monkey/ · **v56 Medium base cost:** $400 · **Range reference:** 40.
**Fantasy appearance:** chibi snowboarder with spinning snowflake discs. **Gameplay responsibility:** Camo detection / multi-shuriken / sabotage / sticky burst.
**Mechanical contract:** inherit the BTD6 attack family, projectile behavior, resistances, targeting and legal crosspaths; do not infer exact stat mutations from tier titles. Every upgrade that adds/replaces an attack needs a separately validated attack definition. The following are *cosmetic working names* aligned by path/tier, not translations of copyrighted descriptions.

| Path | Tier | Original BTD6 upgrade | Working winter name | Medium reference price | Accuracy note |
|---|---:|---|---|---:|---|
| Top | 1 | Ninja Discipline | Trick Discipline | $350 | v56 price; effect requires per-upgrade verification |
| Top | 2 | Sharp Shurikens | Sharper Snowflakes | $350 | v56 price; effect requires per-upgrade verification |
| Top | 3 | Double Shot | Double Tricks | $900 | v56 price; effect requires per-upgrade verification |
| Top | 4 | Bloonjitsu | Championship Spins | $2,750 | v56 price; effect requires per-upgrade verification |
| Top | 5 | Grandmaster Ninja | Grandmaster Freestyle | $35,000 | v56 price; effect requires per-upgrade verification |
| Middle | 1 | Distraction | Distraction Move | $250 | v56 price; effect requires per-upgrade verification |
| Middle | 2 | Counter-Espionage | Anti-Camo Sweep | $400 | v56 price; effect requires per-upgrade verification |
| Middle | 3 | Shinobi Tactics | Rider Crew | $1,200 | v56 price; effect requires per-upgrade verification |
| Middle | 4 | Bloon Sabotage | Course Sabotage | $5,200 | v56 price; effect requires per-upgrade verification |
| Middle | 5 | Grand Saboteur | Total Whiteout | $22,000 | v56 price; effect requires per-upgrade verification |
| Bottom | 1 | Seeking Shuriken | Seeking Snowflake | $300 | v56 price; effect requires per-upgrade verification |
| Bottom | 2 | Caltrops | Ice Caltrops | $450 | v56 price; effect requires per-upgrade verification |
| Bottom | 3 | Flash Bomb | Flash Snowbomb | $2,250 | v56 price; effect requires per-upgrade verification |
| Bottom | 4 | Sticky Bomb | Sticky Snowbomb | $5,000 | v56 price; effect requires per-upgrade verification |
| Bottom | 5 | Master Bomber | Master Bombardier | $40,000 | v56 price; effect requires per-upgrade verification |

**Path identity and visual escalation:** top path should acquire a clearly recognizable precision/power silhouette by tier 3; middle should advertise its ability, attack pattern, or broad utility by tier 3; bottom should advertise its special attack / endurance / automation role by tier 3. Tier 1–2 mostly modify accessory and projectile effects. Tier 4–5 receive deliberately stronger silhouettes. The production art document specifies visual exceptions by tower.

### Winter Games Lodge — reference: Monkey Village [DEFERRED — optional post-hackathon expansion]
**Internal ID:** `winter_games_lodge` · **BTD6 origin:** `Monkey Village` · **Source:** https://teemo.dev/game-design/bloons-td-6/wiki/towers/monkey-village/ · **v56 Medium base cost:** $1,200 · **Range reference:** 40.
**Fantasy appearance:** ski-lodge support building with pennants. **Gameplay responsibility:** Area buffs / detection support / income discounts.
**Mechanical contract:** inherit the BTD6 attack family, projectile behavior, resistances, targeting and legal crosspaths; do not infer exact stat mutations from tier titles. Every upgrade that adds/replaces an attack needs a separately validated attack definition. The following are *cosmetic working names* aligned by path/tier, not translations of copyrighted descriptions.

| Path | Tier | Original BTD6 upgrade | Working winter name | Medium reference price | Accuracy note |
|---|---:|---|---|---:|---|
| Top | 1 | Bigger Radius | Youth Team Support | $400 | v56 price; effect requires per-upgrade verification |
| Top | 2 | Jungle Drums | Starter Team Drills | $1,500 | v56 price; effect requires per-upgrade verification |
| Top | 3 | Primary Training | Rookie Academy | $800 | v56 price; effect requires per-upgrade verification |
| Top | 4 | Primary Mentoring | Premier Academy | $2,500 | v56 price; effect requires per-upgrade verification |
| Top | 5 | Primary Expertise | National Training Center | $25,000 | v56 price; effect requires per-upgrade verification |
| Middle | 1 | Grow Blocker | Extra Coverage | $250 | v56 price; effect requires per-upgrade verification |
| Middle | 2 | Radar Scanner | Signal Flare | $2,000 | v56 price; effect requires per-upgrade verification |
| Middle | 3 | Monkey Intelligence Bureau | Goggle Supply | $7,500 | v56 price; effect requires per-upgrade verification |
| Middle | 4 | Call to Arms | Full Course Radar | $20,000 | v56 price; effect requires per-upgrade verification |
| Middle | 5 | Homeland Defense | Winter Sports Command | $40,000 | v56 price; effect requires per-upgrade verification |
| Bottom | 1 | Monkey Business | Vendor Discounts | $500 | v56 price; effect requires per-upgrade verification |
| Bottom | 2 | Monkey Commerce | Resort Savings | $500 | v56 price; effect requires per-upgrade verification |
| Bottom | 3 | Monkey Town | Festival Market | $10,000 | v56 price; effect requires per-upgrade verification |
| Bottom | 4 | Monkey City | Merchandise Engine | $3,000 | v56 price; effect requires per-upgrade verification |
| Bottom | 5 | Monkeyopolis | Olympic Commerce | $5,000 | v56 price; effect requires per-upgrade verification |

**Path identity and visual escalation:** top path should acquire a clearly recognizable precision/power silhouette by tier 3; middle should advertise its ability, attack pattern, or broad utility by tier 3; bottom should advertise its special attack / endurance / automation role by tier 3. Tier 1–2 mostly modify accessory and projectile effects. Tier 4–5 receive deliberately stronger silhouettes. The production art document specifies visual exceptions by tower.

### Track Gritter — reference: Spike Factory [DEFERRED — optional post-hackathon expansion]
**Internal ID:** `track_gritter` · **BTD6 origin:** `Spike Factory` · **Source:** https://teemo.dev/game-design/bloons-td-6/wiki/towers/spike-factory/ · **v56 Medium base cost:** $1,000 · **Range reference:** 34.
**Fantasy appearance:** snow-course hazard spreading apparatus. **Gameplay responsibility:** Persistent track traps / area bursts / long-lived hazards.
**Mechanical contract:** inherit the BTD6 attack family, projectile behavior, resistances, targeting and legal crosspaths; do not infer exact stat mutations from tier titles. Every upgrade that adds/replaces an attack needs a separately validated attack definition. The following are *cosmetic working names* aligned by path/tier, not translations of copyrighted descriptions.

| Path | Tier | Original BTD6 upgrade | Working winter name | Medium reference price | Accuracy note |
|---|---:|---|---|---:|---|
| Top | 1 | Bigger Stacks | Harder Grit | $800 | v56 price; effect requires per-upgrade verification |
| Top | 2 | White Hot Spikes | Heavy-Duty Grit | $600 | v56 price; effect requires per-upgrade verification |
| Top | 3 | Spiked Balls | Steel-Tipped Grit | $2,300 | v56 price; effect requires per-upgrade verification |
| Top | 4 | Spiked Mines | Ceramic Breaker | $9,500 | v56 price; effect requires per-upgrade verification |
| Top | 5 | Super Mines | Snowstorm Supermine | $125,000 | v56 price; effect requires per-upgrade verification |
| Middle | 1 | Faster Production | Faster Spread | $600 | v56 price; effect requires per-upgrade verification |
| Middle | 2 | Even Faster Production | Rapid Seeder | $800 | v56 price; effect requires per-upgrade verification |
| Middle | 3 | MOAB SHREDR | Course-wide Spreading | $2,500 | v56 price; effect requires per-upgrade verification |
| Middle | 4 | Spike Storm | Spike Barrage | $7,000 | v56 price; effect requires per-upgrade verification |
| Middle | 5 | Carpet of Spikes | Carpet of Grit | $41,000 | v56 price; effect requires per-upgrade verification |
| Bottom | 1 | Long Reach | Longer Lasting | $150 | v56 price; effect requires per-upgrade verification |
| Bottom | 2 | Directed Spikes | Extra Durable | $400 | v56 price; effect requires per-upgrade verification |
| Bottom | 3 | Long Life Spikes | Snow Course Stockpile | $1,300 | v56 price; effect requires per-upgrade verification |
| Bottom | 4 | Deadly Spikes | Persistent Ice Traps | $3,600 | v56 price; effect requires per-upgrade verification |
| Bottom | 5 | Perma-Spike | Permanent Winter Shield | $30,000 | v56 price; effect requires per-upgrade verification |

**Path identity and visual escalation:** top path should acquire a clearly recognizable precision/power silhouette by tier 3; middle should advertise its ability, attack pattern, or broad utility by tier 3; bottom should advertise its special attack / endurance / automation role by tier 3. Tier 1–2 mostly modify accessory and projectile effects. Tier 4–5 receive deliberately stronger silhouettes. The production art document specifies visual exceptions by tower.

## M-09. Camel Claus hero — Quincy-compatible level curve

**Single hero per match.** Default available as first hero choice. Do not give Camel Claus a generic team-aura in version one: Quincy's reference is a damage hero, not an Alchemist/Village support role. Use the **Quincy level XP curve**, which is *not* damage-dealt XP; the hero gains progression from rounds played according to the hero XP system. Medium placement price **$540 [V56]**; base **range 50**, **0.95-s attack interval**, **1 damage**, **3 pierce**, **one sharp projectile** that bounces to distinct targets. BTD6's hero range/damage units must be tied to a defined world-scale conversion rather than guessed Godot meters. Sources: [Quincy full level table](https://teemo.dev/game-design/bloons-td-6/wiki/heroes/quincy/), [detailed historical guide](https://bloons.fandom.com/wiki/Quincy_(BTD6)), [v57 Focus patch](https://gameupdatenotifier.com/g/bloons-td-6/v/57-0).

**Art equivalence:** stylized camel with a playful two-handed ski-pole bow that launches short-lived compressed snowballs, each bouncing between targets. Quincy's explosive arrows become explosive ice pellets; Storm of Arrows becomes Blizzard Barrage. All attack mechanics should be preserved unless a deviation is declared in the balance ledger. Hero character concept is NOT a copy of Quincy's distinctive character design.

| Level | XP from preceding level | Total cumulative XP | Cosmetic level name / event | BTD6 numerical / functional anchor |
|---:|---:|---:|---|---|
| 1 | — | 0 | Base ricocheting chain shot | 1 projectile, 1 damage, pierce 3, range 50, 0.95 s |
| 2 | 180 | 180 | More bounces | pierce 3→4 |
| 3 | 460 | 640 | Snowball Frenzy ability | 3× speed; ~8 s; cooldown 60 s in historic detailed guide |
| 4 | 1,000 | 1,640 | Longer range + Focus stance | range 50→52; v57 Focus: cooldown ×1.25, projectile speed ×1.25, range ×1.20; precision behavior |
| 5 | 1,860 | 3,500 | Snow Goggles | camo detection |
| 6 | 3,280 | 6,780 | Double ice shots | projectiles 1→2 |
| 7 | 5,180 | 11,960 | Exploding ice pellets | every 3rd shot adds explosion |
| 8 | 8,320 | 20,280 | Large-mass specialist | bonus vs MOAB class +2; 3× base damage |
| 9 | 9,380 | 29,660 | More chain hits | pierce 4→6 |
| 10 | 13,620 | 43,280 | Blizzard Barrage ability | area storm; cooldown 70 s |
| 11 | 16,380 | 59,660 | Faster attack | interval 0.95→0.6 s |
| 12 | 14,400 | 74,060 | More pierce | 6→7 |
| 13 | 16,650 | 90,710 | Range + ability duration | 52→54; Frenzy lasts longer |
| 14 | 14,940 | 105,650 | Large-target bonus | vs MOAB bonus +2→+3 |
| 15 | 16,380 | 122,030 | Frenzy upgrade | 4× attack speed; cooldown 60→45 s |
| 16 | 17,820 | 139,850 | Faster attack | interval 0.6→0.4 s |
| 17 | 19,260 | 159,110 | Longer projectile life; more explosions | 25% longer lifetime; explosion every 2nd shot |
| 18 | 20,700 | 179,810 | Faster attack and barrage | 0.4→0.25 s; barrage cooldown 70→55 s |
| 19 | 16,470 | 196,280 | Triple ice shots | projectiles 2→3; pierce 7→9 |
| 20 | 17,280 | 213,560 | Maximum speed and barrage | interval 0.25→0.2 s; enhanced storm |

**IMPORTANT v57 patch override:** At **level 4**, Camel Claus must gain a selectable **Focused Shot** stance mirroring Quincy's new toggle: initial-shot precision, **+25% attack cooldown**, **+25% projectile speed**, **+20% range** when Focus is active. This is a *slower* rate for improved accuracy and reach. The v56-derived hero table alone misses this feature. Additional mode interaction with other levels must be separately verified.

**Special-ability acceptance tests:** abilities correctly appear at levels 3/10; Rapid Shot / Snowball Frenzy cooldown and multiplier are correct; barrage is limited to eligible targets; cooldown freezes on pause; Focused stance toggles and changes only the specified stats; ability feedback in art volume shows targeting and ready/active/cooldown. All 20 level rows are planning data, but playable event scope may reach only levels available during the event's selected rounds.

## M-10. Additional exact base attacks for initial six — inspected source pages

| BTD6 tower → Winter defender | Base Medium | Range reference | Attack cycle | Damage | Pierce | Important caveat | Evidence |
|---|---:|---:|---:|---:|---:|---|---|
| Dart → Snowball Rookie | $200 | 32 | 0.95 s | 1 | 2 | Sharp-style, no intrinsic camo | [Dart](https://teemo.dev/game-design/bloons-td-6/wiki/towers/dart-monkey/) |
| Bomb Shooter → Avalanche Cannon | $375 | 40 | 1.5 s | 1 splash | 22 splash | 1 contact projectile creates one 1-damage explosion; do not confuse contact pierce 1 with blast pierce 22 | [Bomb](https://teemo.dev/game-design/bloons-td-6/wiki/towers/bomb-shooter/) |
| Sniper → Biathlon Ranger | $350 | Global LOS | 1.59 s | 2 | 1 | **Global** targeting rather than circular range; special ammo and shrapnel later | [Sniper](https://teemo.dev/game-design/bloons-td-6/wiki/towers/sniper-monkey/) |
| Glue → Slope Wax Sprayer | $225 | 46 | 1.0 s | no base damage | 1 | base wax applies 50% slowing, not layer damage; status duration needs crosscheck | [Glue](https://teemo.dev/game-design/bloons-td-6/wiki/towers/glue-gunner/) |
| Wizard → Snow Sorcerer | $250 | 40 | 1.1 s | 1 | 3 | energy damage, immune classes matter | [Wizard](https://teemo.dev/game-design/bloons-td-6/wiki/towers/wizard-monkey/) |
| Farm → Ski Resort Ticket Booth | $1,250 | not an attack radius | 4 income pickups/round | $20/pickup | N/A | 80 currency/round baseline; collection expiration and overlap require rules | [Farm](https://teemo.dev/game-design/bloons-td-6/wiki/towers/banana-farm/) |

These are v56 source baselines, not claims of an independently verified complete v57.4 matchup. **Do not equate reference range units with pixels/meters** without calibrating world scale.

## M-11. Version 57 delta and deviation register (must survive copy/paste)

| Affected family | Verified v57 change | Game counterpart consequence |
|---|---|---|
| Camel Claus (Quincy) | Level 4 Focus toggle: ×1.25 attack interval, ×1.25 projectile velocity, ×1.2 range, improved initial aim | Implement stance and UI toggle; do not use old hero table unpatched |
| Snowball Rookie (Dart) | xx3 Crossbow pierce 4→5; xx4 critical damage 50→60; xx5 1→2 projectiles and interval 0.2375→0.475s | Adapt precision snow launcher path with BOTH projectile and cooldown changes |
| Avalanche Cannon (Bomb) | Fragment pierce/penalty changes; x2x projectile origins revised; xx5 passive limited 1 trigger per round | Reconcile fragment child attacks and timer cap before late tiers |
| Slope Wax Sprayer (Glue) | x2x price $970→$650; x4x $4000→$4500; xx1 duration 24→18s | Use corrected prices/duration, not frozen v56 values |
| Biathlon Ranger (Sniper) | x4x Supply Drop can toggle Cash Drop versus Ammo Drop (shared cooldown) | Include money/offense toggle; do not design only monetary supply |

**Other known policy caveats:** Quincy's base ricochet is not a simple straight projectile with high pierce; Sniper global targeting requires line-of-sight behavior; Glue is primarily status not damage; Banana Farm collection is its own subsystem; crosspath rules modify multiple attacks/child fragments nonlinearly; later-tier Wizard necromancy requires a spawn/summon system; the hero/ability is not a normal tiered upgrade.

## M-12. Data implementation manifest [ENGINEERING]

Suggested content contracts (`.tres` / JSON / dictionaries, chosen consistently by implementer):

```yaml
source_reference:
  game: BTD6
  baseline_version: 56
  patch_overlays: [57.0]
  verification_status: per_field
  source_url: https://teemo.dev/game-design/bloons-td-6/wiki/
unit:
  id: slope_wax_sprayer
  display_name: Slope Wax Sprayer
  source_tower: Glue Gunner
  release_status: INITIAL
  price_medium: 225
  placement_types: [land]
  radius_reference_units: 46
  attacks: [wax_projectile]
  upgrades: {top: 5, middle: 5, bottom: 5}
  presentation_profile: slope_wax_sprayer
```

Suggested core modules:

```text
scenes/match/MainMatch.tscn
scenes/match/SnowballEnemy.tscn
scenes/towers/TowerBase.tscn
scenes/hero/CamelClaus.tscn
scenes/projectiles/Projectile.tscn
scenes/ui/HUD.tscn
scripts/data/TowerDefinition.gd
scripts/data/UpgradeDefinition.gd
scripts/data/EnemyDefinition.gd
scripts/data/RoundDefinition.gd
scripts/core/SimulationClock.gd
scripts/core/MatchState.gd
scripts/core/PlacementValidator.gd
scripts/core/PathFollower.gd
scripts/core/TargetingService.gd
scripts/core/DamageResolver.gd
scripts/core/StatusManager.gd
scripts/core/EconomyLedger.gd
scripts/core/RoundSpawner.gd
scripts/core/UpgradeValidator.gd
scripts/core/HeroXPService.gd
scripts/core/EventBus.gd
scripts/data/BalanceRegistry.gd
```

**Godot implementation cautions:** avoid circular script dependencies; don't embed cosmetics into numeric Resources; use physical render objects separate from simulation state; use glTF/GLB exports later; choose supported Web renderer/feature level; avoid C# in browser version; keep CPU/memory budgets realistic; run headless simulation invariants and test real browser web export early.

### M-12.1 Balance QA requirements

For every active tower and upgrade configuration, maintain machine-testable assertions of base price, price multiplier, legal path state, range/LOS, attack frequency, damage class/immunity, pierce/hit count, special property targeting, effect duration, ability cooldown, and sell cost. For every round, assert exact enemy groups, count, spawn schedule, RBE, projected income, and survival result of a canonical test setup. Record tests for 1x and 2x game speed. The six starter unit families contain **90 nominal upgrade tier entries**; supporting all crosspaths faithfully requires more than 90 separate price rows.

### M-12.2 Strategy/compatibility cases to preserve

- Rookie (Dart) high-pierce is cost-effective on straightaways; Fan Club-style buffs should not accidentally affect every unit class.
- Cannon (Bomb) creates bursts with multi-target pierce and counters groups or large targets, but damage-type immunity is consequential.
- Biathlon (Sniper) can hit visible priority targets anywhere; weaknesses include crowds and sight obstruction; new ammo ability adds late-game choice.
- Wax (Glue) prolongs engagement time rather than 'popping' by default; corrosive branch changes that; reapplication and hierarchy matter.
- Sorcerer (Wizard) supplies elemental damage, area effects and later spawned units; energy-type limitations force diversity.
- Ticket Booth (Farm) trades upfront cash for future cashflow; higher levels become expensive investments; don't grant a free refund with interest.
- Camel Claus (Quincy) rewards early placement, grows autonomously and can make emergency burst plays via abilities.

## M-13. Explicitly undecided decisions — review gates, not hidden implementation tasks

| Decision | Conservative recommendation | Consequence if changed |
|---|---|---|
| Final public game title | **Claus for Alarm** (locked) | UI/logo/web site branding |
| Gold visual tier | late special class, NOT a sixth generic 1-HP layer | custom enemy HP, RBE, cash, rounds if made linear |
| Demo wave count | choose only after reference round and income review | 10–15 compressed waves cannot support normal BTD6 T5 cost curve |
| Source starting difficulty | Medium baseline for all reference prices | affects early accessibility and tower affordability |
| Theme balance fidelity | preserve available source numbers; mark missing data | completion requires extra research, not guessing |
| Entire 20-level Quincy arc | preserve complete table as design goal; short demo only reaches some | hero level rates / encounter length |
| Paragons, boss events, freeplay | out of initial scope | expensive late-system coupling |
| Audio/art schedule | simulation first, polished replacement later | permits early testing and rapid iteration |

## M-14. Sources and cross-document handoff

**Primary attached source:** `BTD6_Gameplay_Systems_Mechanics_and_Balance.md` (complete upgrade name/price list and round summaries; v56 baseline).  
**Verified tower pages:** [Dart](https://teemo.dev/game-design/bloons-td-6/wiki/towers/dart-monkey/), [Bomb](https://teemo.dev/game-design/bloons-td-6/wiki/towers/bomb-shooter/), [Sniper](https://teemo.dev/game-design/bloons-td-6/wiki/towers/sniper-monkey/), [Glue](https://teemo.dev/game-design/bloons-td-6/wiki/towers/glue-gunner/), [Wizard](https://teemo.dev/game-design/bloons-td-6/wiki/towers/wizard-monkey/), [Farm](https://teemo.dev/game-design/bloons-td-6/wiki/towers/banana-farm/), [Quincy](https://teemo.dev/game-design/bloons-td-6/wiki/heroes/quincy/).  
**Version corrections:** [v57 detailed patch](https://gameupdatenotifier.com/g/bloons-td-6/v/57-0) and [official latest-status post](https://www.reddit.com/r/NinjaKiwiOfficial/comments/1xv5l7j/whats_up_at_ninja_kiwi_13th_november_2026/).  
**Full round source index:** https://teemo.dev/game-design/bloons-td-6/wiki/rounds/ ; **round economy:** https://teemo.dev/game-design/bloons-td-6/systems/rounds-and-economy/.

**Handoff to `02...md`:** UI for crosspaths, shell-break VFX, camo/armor marks, ability feedback, winter sports map theme, music/sound, and seasonal identity. **Handoff to `03...md`:** rigged character / hero / machines / props / shadow and placement footprints / GLB authoring with placeholder swaps. **No code or models commissioned merely by possessing this file.**
