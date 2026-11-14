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

## Map `map_v1` (P03) — `scenes/world/ski_circuit.tscn`

- Original route, entry upper-left → finish right, 5 corners. Centre line = `Waypoints/W0..W7` Marker3D children;
  the track mesh is generated from them at runtime so visuals can't drift from the simulated path.
- Scale: 1 reference unit = 0.1 m. Map (buildable) 32×20 m = 320×200 units; route 66 m = 660 units (Powder
  needs 26.4 s); track width 2.2 m = 22 units; tower footprint 0.6 m (Dart 6 units; others copied, PROTOTYPE).
- Blockers (`Blockers/*`, BoxMesh, axis-aligned): Lodge, Pond. They block **placement only**; map_v1 has no
  line-of-sight occluders, so nothing hides targets invisibly.
- `check_placement(pos_xz, radius, towers)` → `""` or a reason (`Outside the course`, `On the ski track`,
  `Blocked by scenery`, `Too close to another tower`); the match adds `Not enough cash`. Ghost and purchase use the
  same call, so the preview can never disagree with the rule.
- Camera (P03-T02 decision): fixed orthographic, pitch −60°, `keep_aspect = KEEP_WIDTH`, width 42 m, centred
  2.5 m right of the map so the right-hand shop never covers the course. Orthographic keeps range rings true
  circles in size everywhere and makes cursor → ground picking exact at any window size.
- Geometry is frozen by `tests/test_map.gd`; changing the route/blockers requires a balance review.
