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
| Upgrade depth shipped | Architecture supports 3×5; ship only verified, tested tiers (D-07) | Data gaps GAP-001 |
| Gold snowball | **APPROVED (DEC-018):** none for now | Not needed for the round count |
| Basic layers | **APPROVED (DEC-017):** strict 1:1 BTD6 Red/Blue/Green/Yellow/Pink: 1 HP per layer, one child, $1 per pop, source speeds | Balance comparison with BTD6 |
| Special snowballs | **APPROVED (DEC-019):** DEFERRED (Black, Rainbow, Stone=Ceramic, Metal=Lead, camo). Schema flags `camo`, `immune_<damage_type>` work; multi-child splits are rejected by the validator until P11 | Game functional first |
| Medium lives | **APPROVED (DEC-021):** 150 | |
| Projectile flight | Rookie dart speed 300 u/s, lifetime 0.3 s (`PROTOTYPE_ASSUMPTION`; source page lists no speed). Straight line at the target's current position, no homing | Needed for P06 |
| Hit / range contact | Snowball contact radius 0.4 m (mesh radius) for all basic layers; a target is in range when the range circle touches it | BTD6-like edge contact |
| Immune contact | A shot touching an immune snowball uses 1 pierce and does nothing else (BTD6: Lead blocks darts) | P06-T07 |
| Attacking towers until P08 | Only the Snowball Rookie is in the shop; the other five base kits arrive in P08 | Owner: prove G3 with the Rookie |
| Minimum acceptance | Stranger can open the hosted URL, place/upgrade towers, finish or lose a match, restart | Master plan §13 |
| Hackathon deadline & submission rules | **Sun Nov 15, 10:00 AM**; game on itch.io + public studio website (`docs/HACKATHON.md`) | ~38 h total; drives scope cuts |
