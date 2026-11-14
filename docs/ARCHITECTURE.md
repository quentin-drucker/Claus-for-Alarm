# Claus for Alarm — Architecture (P02-T14)

Stable interfaces for agents. Simulation decides; presentation (meshes, HUD, VFX, audio) only reads state and
listens to events. Nothing in presentation may change cash, lives, damage or round flow.

## Data (`scripts/data/`, values in `resources/`)

| Resource | File(s) | Holds |
|---|---|---|
| `MatchRules` | `resources/rules/rules_medium.tres` | start cash/lives, round bonus base, sell ratio |
| `TowerDefinition` (+ `AttackDefinition`, `UpgradeDefinition` sub-resources) | `resources/towers/<id>.tres` | price, range, footprint, attacks, 3×5 upgrades |
| `EnemyDefinition` | `resources/enemies/<id>.tres` | speed, child chain, cash per pop, property flags |
| `RoundDefinition` (+ `SpawnGroup`) | `resources/rounds/round_NN.tres` | spawn groups; round number = sorted file order |
| `HeroDefinition` | `resources/heroes/camel_claus.tres` | price, range, base attack, XP table, per-level changes |

- All extend `GameDefinition`: `id`, `source_url`, `notes`, and `status[field]` for every name in
  `balance_fields()`. Statuses: `VERIFIED_SOURCE` (BTD6 v56 page), `PATCHED_SOURCE` (v57 override),
  `PROTOTYPE_ASSUMPTION`, `ORIGINAL_DEVIATION`, `UNKNOWN_REFERENCE`, `NOT_APPLICABLE`.
- Units: reference map units (BTD6). `GameDefinition.UNIT_M = 0.1` m per unit (range 32 → 3.2 m, Powder 25 u/s → 2.5 m/s).
- Changing a stat = edit the `.tres` (Inspector or `godot_resource_set`). Never put numbers in HUD/scene scripts.
- Crosspaths: `TowerDefinition.is_legal_crosspath(Vector3i)` and `can_upgrade(tiers, path)` (one path ≤5, one ≤2, one 0).

## Autoloads

- `Content` (`scripts/core/content.gd`): loads everything under `res://resources/` in sorted order, runs all
  validators into `Content.errors` (pushed as errors at boot). `rbe(id)`, `round_rbe(i)`, `get_tower(id)`,
  `status_report()` (one line per balance value with its status).
- `Events` (`scripts/core/events.gd`): `Events.send(type, source_id, target_id, magnitude, position, tags)` →
  `Events.emitted(GameEvent)`. Allowed types in `Events.TYPES`. Run with `-- --log-events` to print them.

## Simulation

- `SimClock` (`scripts/core/sim_clock.gd`): fixed 60 Hz `ticked(dt)`; `speed` scales time, `paused` stops it.
  All gameplay state changes happen inside ticks, never in `_process` of visual nodes.
- `EconomyLedger` (`scripts/core/economy_ledger.gd`): the only place cash changes; `spend()` refuses
  unaffordable amounts; every change is logged with tick, reason and source entity.
