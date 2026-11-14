# Claus for Alarm — Implementation assumptions (P00-T08)

Entries are **PROPOSED defaults** unless marked APPROVED (master plan §5 / §12.3).

| Topic | Assumption | Why |
|---|---|---|
| Release target | Scope **S1 (hackathon playable)**; S0 is the fallback floor | Master plan §3.4 / §10 |
| Platform | Desktop browser, Godot Web export, single-threaded (`web_nothreads_*` templates are installed) | No special host headers needed |
| Primary test browser | Chrome (Chromium) on Windows 11; Firefox/Edge as spot checks | Owner's machine |
| Input | Mouse + keyboard only; no touch/controller requirement | Desktop target |
| Play time goal | One match ≈ 10–15 minutes | Short judge-friendly session |
| Rounds | **APPROVED (DEC-025/026):** exact BTD6 rounds 1–25, 1:1 (groups, counts, timing, types → snowball counterparts); win = survive round 25. Endless "Continue" to round 80 later (DEC-027) | Owner: rounds must match BTD6 exactly for balance comparison |
| Prices | BTD6 v56 Medium baseline + verified v57 overrides, configurable | D-04 |
| Upgrade depth shipped | **APPROVED (DEC-024):** tiers 1–3 purchasable on all paths of all six towers (54/90, `p10_upgrade_coverage.txt`); tiers 4–5 "coming soon". Sourced from the teemo.dev v56 upgrade pages / M-11 v57 except these fillers (PROTOTYPE_ASSUMPTION, page has no numbers): Guided Magic pierce +1 + lifetime ×1.5; Wall of Fire = one 15 u fire burst where it lands (no lingering wall); Corrosive Glue 1 layer / 2 s; Stronger Glue slow 70%; MOAB Glue (large-only, none in this build) wax +2 s; Bouncing Bullet reach 30 u; Banana Salvage auto-collect 90%. Not modelled: Shimmer de-camo, Deadly Precision ceramic bonus, Semi-Automatic pierce 5 (global hit has one target), EZ Collect radius | Owner 2026-11-14 |
| Ticket Booth economy | **APPROVED (DEC-023) ORIGINAL_DEVIATION:** ticket value $50 (source $20), Valuable Bananas ×1.5 (source ×1.25), Bank tickets $112 (source $45, scaled). Bank: tickets go straight in, 15% interest at each round end, cap $7,000, withdraw from the card, paid out on sale. Marketplace pays 16 tickets directly | Base payback 6.25 rounds in a 19-round match |
| Gold snowball | **APPROVED (DEC-018):** none for now | Not needed for the round count |
| Basic layers | **APPROVED (DEC-017):** strict 1:1 BTD6 Red/Blue/Green/Yellow/Pink: 1 HP per layer, one child, $1 per pop, source speeds | Balance comparison with BTD6 |
| Special snowballs | **DEC-025:** Black, White, Purple, Camo Green chain ACTIVE (needed by source rounds 20–25; v56 speeds/children/immunities, `REGISTRY.md`). Rainbow, Ceramic, Lead, Zebra stay DEFERRED (DEC-019). Regrow not used (DEC-031) | Only what rounds ≤ 25 need |
| Multi-child split | A multi-child break turns the snowball into its first child and adds the others **0.15 m behind it on the track** (`PROTOTYPE_ASSUMPTION`; BTD6 scatters them slightly). Leftover damage goes on into **every** child (`PROTOTYPE_ASSUMPTION`, BTD6 overflow as commonly described), stopping at a child immune to the damage type. Every child gets a fresh id; the projectile/burst that caused the split cannot hit any of them (lineage hit history). Wax state is copied to all children (a normal break still sheds non-soak wax first) | P11-T03 |
| Damage types vs immunities | Rookie/Ranger/hero sharp/normal/shatter; Cannon explosion; Sorcerer bolt `energy` (its upgrade sub-attacks are `explosion` / `plasma` as in the data); Wax `glue`. No shipped attack is `cold`, so White is only a faster 2-Coral layer here | Mapped from v56 page wording |
| Medium lives | **APPROVED (DEC-021):** 150 | |
| Projectile flight | All projectiles 300 u/s, lifetime 0.3 s; fragments/shrapnel 0.1 s (`PROTOTYPE_ASSUMPTION`; source pages list no speeds). Straight line, aimed one prediction step ahead along the track (lead), no homing | Without lead, fast layers crossing a shot slipped past the 0.4 m contact radius (found by the P09 bot) |
| Hit / range contact | Snowball contact radius 0.4 m (mesh radius) for all layers incl. specials (BTD6 Black/White are smaller: not modelled); a target is in range when the range circle touches it | BTD6-like edge contact |
| Immune contact | A shot touching an immune snowball uses 1 pierce and does nothing else (BTD6: Lead blocks darts) | P06-T07 |
| Area radii | Cannon blast 18 u, cluster blast 10 u, Fireball blast 10 u, Glue Splatter 10 u (`PROTOTYPE_ASSUMPTION`: not on the source pages) | Needed to implement the verified pierce/damage |
| Volley spread | Triple Shot 15° apart, Shrapnel 15° cone, frags 8 × 45° ring (`PROTOTYPE_ASSUMPTION`) | Counts verified, angles not |
| Wax | Base duration 11 s (`PROTOTYPE_ASSUMPTION`, not on the page; Stickier = 18 s v57 verified). Pure wax shots skip already-waxed snowballs. Strongest wax wins, equal refreshes, no stacking; a layer break sheds wax unless Glue Soak | BTD6 targeting rule unverified |
| Ticket Booth | 4 pickups × $20 dropped evenly over the round's spawn time (timing `PROTOTYPE_ASSUMPTION`), click to collect, expire after 15 s (source), uncollected = lost | No source for in-round timing |
| Footprints | Sniper 6, Glue 6, Farm 15 (source pages); Cannon/Sorcerer 6 (`PROTOTYPE_ASSUMPTION`) | |
| Minimum acceptance | Stranger can open the hosted URL, place/upgrade towers, finish or lose a match, restart | Master plan §13 |
| Hackathon deadline & submission rules | **Sun Nov 15, 10:00 AM**; game on itch.io + public studio website (`docs/HACKATHON.md`) | ~38 h total; drives scope cuts |
| Game speed | 1× / 2× / 4× (DEC-029, ORIGINAL_DEVIATION) | Faster demo; identical simulation results |
| Ticket Booth tuning | Re-checked for 25 rounds (2026-11-14): no retune. Booth bot (bought round 10, 2-0-0, $2,350) returned $6,000 by round 25 (+$3,650) but finished with fewer lives (125) than Rookie-only (147): strong, not run-breaking. DEC-023 values kept (ORIGINAL_DEVIATION) | `p12_full_run_25.txt` |
| Upgrade/hero depth | All tiers 1–5 + abilities and hero levels 6–20 implemented for Endless (DEC-030); "coming soon" only until then | Continue mode reaches round 80 |
