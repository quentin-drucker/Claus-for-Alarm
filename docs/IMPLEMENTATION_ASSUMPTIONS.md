# Claus for Alarm — Implementation assumptions (P00-T08)

Entries are **PROPOSED defaults** unless marked APPROVED (master plan §5 / §12.3).

| Topic | Assumption | Why |
|---|---|---|
| Release target | Scope **S1 (hackathon playable)**; S0 is the fallback floor | Master plan §3.4 / §10 |
| Platform | Desktop browser, Godot Web export, single-threaded (`web_nothreads_*` templates are installed) | No special host headers needed |
| Primary test browser | Chrome (Chromium) on Windows 11; Firefox/Edge as spot checks | Owner's machine |
| Input | Mouse + keyboard only; no touch/controller requirement | Desktop target |
| Play time goal | One match ≈ 10–15 minutes | Short judge-friendly session |
| Rounds | **APPROVED (DEC-020):** exact BTD6 v56 rounds 1–16 + 3 custom finale rounds (ORIGINAL_DEVIATION, basic layers). Round 17 is the first source round with a non-basic type (Regrow Yellow) | Measured ~9.9 min with a greedy Rookie-only bot (`p07_full_run.txt`) |
| Prices | BTD6 v56 Medium baseline + verified v57 overrides, configurable | D-04 |
| Upgrade depth shipped | **Applied (D-07):** 3×5 data for all six; only tiers whose effects are on their source upgrade page (teemo.dev v56) or in M-11 (v57) are purchasable — 35/90 (`p09_upgrade_coverage.txt`). Everything else shows "coming soon". Abilities (Supply Drop etc.) DEFERRED: no shipped tier has one | Never extrapolate from upgrade names |
| Gold snowball | **APPROVED (DEC-018):** none for now | Not needed for the round count |
| Basic layers | **APPROVED (DEC-017):** strict 1:1 BTD6 Red/Blue/Green/Yellow/Pink: 1 HP per layer, one child, $1 per pop, source speeds | Balance comparison with BTD6 |
| Special snowballs | **APPROVED (DEC-019):** DEFERRED (Black, Rainbow, Stone=Ceramic, Metal=Lead, camo). Schema flags `camo`, `immune_<damage_type>` work; multi-child splits are rejected by the validator until P11 | Game functional first |
| Medium lives | **APPROVED (DEC-021):** 150 | |
| Projectile flight | All projectiles 300 u/s, lifetime 0.3 s; fragments/shrapnel 0.1 s (`PROTOTYPE_ASSUMPTION`; source pages list no speeds). Straight line, aimed one prediction step ahead along the track (lead), no homing | Without lead, fast layers crossing a shot slipped past the 0.4 m contact radius (found by the P09 bot) |
| Hit / range contact | Snowball contact radius 0.4 m (mesh radius) for all basic layers; a target is in range when the range circle touches it | BTD6-like edge contact |
| Immune contact | A shot touching an immune snowball uses 1 pierce and does nothing else (BTD6: Lead blocks darts) | P06-T07 |
| Area radii | Cannon blast 18 u, cluster blast 10 u, Fireball blast 10 u, Glue Splatter 10 u (`PROTOTYPE_ASSUMPTION`: not on the source pages) | Needed to implement the verified pierce/damage |
| Volley spread | Triple Shot 15° apart, Shrapnel 15° cone, frags 8 × 45° ring (`PROTOTYPE_ASSUMPTION`) | Counts verified, angles not |
| Wax | Base duration 11 s (`PROTOTYPE_ASSUMPTION`, not on the page; Stickier = 18 s v57 verified). Pure wax shots skip already-waxed snowballs. Strongest wax wins, equal refreshes, no stacking; a layer break sheds wax unless Glue Soak | BTD6 targeting rule unverified |
| Ticket Booth | 4 pickups × $20 dropped evenly over the round's spawn time (timing `PROTOTYPE_ASSUMPTION`), click to collect, expire after 15 s (source), uncollected = lost | No source for in-round timing |
| Footprints | Sniper 6, Glue 6, Farm 15 (source pages); Cannon/Sorcerer 6 (`PROTOTYPE_ASSUMPTION`) | |
| Minimum acceptance | Stranger can open the hosted URL, place/upgrade towers, finish or lose a match, restart | Master plan §13 |
| Hackathon deadline & submission rules | **Sun Nov 15, 10:00 AM**; game on itch.io + public studio website (`docs/HACKATHON.md`) | ~38 h total; drives scope cuts |
