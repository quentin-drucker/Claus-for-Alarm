# Claus for Alarm — Implementation assumptions (P00-T08)

All entries are **PROPOSED defaults** until the owner confirms them (master plan §5 / §12.3).

| Topic | Assumption | Why |
|---|---|---|
| Release target | Scope **S1 (hackathon playable)**; S0 is the fallback floor | Master plan §3.4 / §10 |
| Platform | Desktop browser, Godot Web export, single-threaded (`web_nothreads_*` templates are installed) | No special host headers needed |
| Primary test browser | Chrome (Chromium) on Windows 11; Firefox/Edge as spot checks | Owner's machine |
| Input | Mouse + keyboard only; no touch/controller requirement | Desktop target |
| Play time goal | One match ≈ 10–15 minutes | Short judge-friendly session |
| Rounds | Short **custom** round set (labeled original, not BTD6 parity) unless owner chooses reference rounds (D-03) | Vanilla T5 prices are unreachable in 10–15 rounds |
| Prices | BTD6 v56 Medium baseline + verified v57 overrides, configurable | D-04 |
| Upgrade depth shipped | Architecture supports 3×5; ship only verified, tested tiers (D-07) | Data gaps GAP-001 |
| Gold snowball | Configurable special class, not a 6th linear layer (D-02) | Pending owner |
| Minimum acceptance | Stranger can open the hosted URL, place/upgrade towers, finish or lose a match, restart | Master plan §13 |
| Hackathon deadline & submission rules | **Unknown** — needed from owner (`docs/HACKATHON.md`) | Drives scope cuts |
