# Claus for Alarm — Roster registry (P00-T06)

Source: `references/design/01_Camel_Claus_Hybrid_Gameplay_and_Balance.md` M-01/M-06 and master plan §3.2.
This lists what is approved. Decision status lives in master plan §12.3.

| Status | Game ID | Name | BTD6 mechanical parent |
|---|---|---|---|
| INITIAL | `snowball_rookie` | Snowball Rookie | Dart Monkey |
| INITIAL | `avalanche_cannon` | Avalanche Cannon | Bomb Shooter |
| INITIAL | `biathlon_ranger` | Biathlon Ranger | Sniper Monkey |
| INITIAL | `slope_wax_sprayer` | Slope Wax Sprayer | Glue Gunner |
| INITIAL | `snow_sorcerer` | Snow Sorcerer | Wizard Monkey |
| INITIAL | `ski_resort_ticket_booth` | Ski Resort Ticket Booth | Banana Farm |
| HERO | `camel_claus` | Camel Claus | Quincy |
| PLANNED (not now) | `hockey_slapper` | Hockey Slapper | Boomerang Monkey |
| PLANNED (not now) | `snowboard_trickster` | Snowboard Trickster | Ninja Monkey |
| DEFERRED (optional expansion; excluded from hackathon) | `winter_games_lodge` | Winter Games Lodge | Monkey Village |
| DEFERRED (optional expansion; excluded from hackathon) | `track_gritter` | Track Gritter | Spike Factory |

**Excluded — no placeholders, data, icons, buttons or models:** Dartling Gunner, Monkey Ace, Engineer Monkey,
Ice Monkey, Tack Shooter, Alchemist (and any reskin of them).

## Snowballs (DEC-017/018/019)

| Status | Game ID | Name | BTD6 counterpart | Notes |
|---|---|---|---|---|
| ACTIVE | `powder` | Powder | Red | 1:1 source: 1 layer, 25 u/s, $1 |
| ACTIVE | `blue` | Blue | Blue | → Powder, 35 u/s |
| ACTIVE | `mint` | Mint | Green | → Blue, 45 u/s |
| ACTIVE | `violet` | Violet | Yellow | → Mint, 80 u/s |
| ACTIVE | `coral` | Coral | Pink | → Violet, 87.5 u/s |
| ACTIVE | `black` | Black (provisional) | Black | 45 u/s, → 2 Coral, RBE 11, `immune_explosion`; rounds 20, 23. Placeholder: dark + "B" |
| ACTIVE | `white` | White (provisional) | White | 50 u/s, → 2 Coral, RBE 11, `immune_cold` (no shipped attack is cold); rounds 22, 23. Placeholder: white + "W" |
| ACTIVE | `purple` | Aurora (DEC-036; id frozen) | Purple | 75 u/s, → 2 Coral, RBE 11, `immune_energy/fire/plasma` (Sorcerer bolt); round 25. Art (P15): Aurora shell `#7A3FD6` + marker band + letter "A" |
| ACTIVE | `camo_mint` → `camo_blue` → `camo_powder` | Camo Mint/Blue/Powder | Camo Green/Blue/Red | `camo` kept by children; needs detection; round 24. Placeholder: layer colour + "C" |
| DEFERRED | — | Rainbow (provisional) | Rainbow | same role and children |
| DEFERRED | — | Stone (provisional) | Ceramic | |
| DEFERRED | — | Metal (provisional) | Lead | immune to sharp (`immune_sharp`), needs explosive |
| DEFERRED | — | Zebra (provisional) | Zebra | Black + White children |
| NOT NOW | — | Gold | — | D-02: not needed (DEC-018) |

**DEC-025:** any special type that appears in BTD6 rounds 17–25 is needed now for the 25-round demo (mechanics
first, placeholder visuals). The rest stay deferred until the game is functional and most towers + art are in.

## Blimp class — Endless only (DEC-027/028, DEFERRED)

| BTD6 | First source round | Snowball counterpart (look) |
|---|---|---|
| MOAB | 40 | Ice sled carrying ice blocks; ice cracks/melts/chips as it takes damage; on death the sled tips over and despawns smoothly |
| BFB | 60 | Same family, bigger/heavier sled |
| ZOMG | 80 | Same family; final boss of the round-80 hard cap |

DDT (round 90+) and later are out of scope.
Names and materials are provisional; the owner may rename them.

## Backburner — may not make the hackathon

| Item | Decision | Note |
|---|---|---|
| Regrow snowballs | DEC-031 | Regrow rounds spawn the plain type instead; add the property far later if ever |
| Endless "Continue" rounds 26–80 | DEC-027 | Exact BTD6 rounds; hard cap 80 (ZOMG final boss) |
| Blimp class (MOAB r40, BFB r60, ZOMG r80) | DEC-028 | Ice-sled look, crack/melt damage states, tip-over death |
| Tiers 4–5 + abilities, hero levels beyond round-25 reach | DEC-030 | Needed for Endless |
| Remaining deferred specials (Rainbow, Stone/Ceramic, Metal/Lead, …) | DEC-019/025 | Only types needed by rounds ≤ 25 ship now |
| Planned towers (Hockey Slapper, Snowboard Trickster) | M-08 | Post-jam |
| Deferred towers (Winter Games Lodge, Track Gritter) | M-08 | Optional expansion only; no hackathon creation/submission |
| Gold snowball | DEC-018 | Not needed |
