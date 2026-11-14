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
| `HeroDefinition` (extends `TowerDefinition`) | `resources/heroes/camel_claus.tres` | price, range, attacks[0] = ricochet, XP table, per-level changes, Frenzy/Focus numbers |

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

## Match (P04) — `scenes/main/match.tscn` + `scenes/ui/match_hud.tscn`

States (`match.gd` `State`, legal moves in `TRANSITIONS`; illegal ones push an error and are ignored):

```
BOOT → PREPARE → ROUND_SPAWN → ROUND_CLEANUP → ROUND_REWARD → PREPARE … → WON
                  ROUND_SPAWN / ROUND_CLEANUP → LOST (lives ≤ 0)
```

- READY is folded into PREPARE. **Pause is not a state**: it freezes `SimClock` in any live state and resumes
  exactly where it was.
- ROUND_SPAWN ends when the round's schedule is fully spawned; ROUND_CLEANUP ends only when no snowball is
  left, so a round can't complete while snowballs are still on the course. ROUND_REWARD credits
  `round_bonus_base + round` through the ledger.
- Tick order: spawn due enemies + ticket drops → pickup expiry → move snowballs (wax slows) → leaks (lives −= RBE,
  once) → towers fire → shots move/hit → state checks.
- Combat (P08): every attack is data (`AttackDefinition`). Top-level attacks fire as a projectile volley, or as an
  instant hit for `global_range` towers (line of sight via `SkiCircuit.has_line_of_sight`, group `blocks_sight`).
  `radius_units > 0` = burst. `on_contact` / `on_expire` sub-attacks chain (explosion, frags, shrapnel, cluster).
  All damage goes through `damage_snowball`; status through `_apply`.
- Upgrades (P09): towers keep working copies of their stats (`tower.rebuild_stats`), rebuilt from the definition
  plus owned tiers' `UpgradeEffect`s (appends first, then add/multiply/set). `TowerDefinition.can_upgrade` is the
  authority (crosspath + shipped tier); `match.buy_upgrade` is the only purchase path.
- `match.changed` fires on every HUD-visible change; the HUD refreshes only then (debug overlay excepted).

| Control | PREPARE | ROUND_SPAWN / CLEANUP | Paused | WON / LOST |
|---|---|---|---|---|
| Start round (Space / button) | ✔ | — (ignored) | — | — |
| Pause / resume (P / button) | ✔ | ✔ | ✔ | — |
| Speed 1×/2× (F / button) | ✔ | ✔ | ✔ | — |
| Buy (1–6 / shop), place (click), sell | ✔ | ✔ | ✔ | — |
| Cancel (Esc / right-click) | ✔ | ✔ | ✔ | — |
| Restart (overlay button) | — | — | ✔ | ✔ |

- Browser input: HUD buttons use `focus_mode = NONE`, so Space can't re-press a focused button; world clicks
  come through `_unhandled_input`, so clicks on HUD panels never place or select in the world. Esc only
  cancels (browsers reserve Esc to leave fullscreen). F3 debug overlay exists only in debug builds.
- Restart = `reload_current_scene()`: fresh clock, ledger, towers, snowballs, event connections.

## Hero (P10)

- Camel Claus is a `TowerDefinition` subclass placed through the same `try_place` (7th shop entry, one per match:
  `placement_reason` refuses a second). It has no upgrades; `tower.rebuild_stats` applies `level_changes[0..level-1]`
  once, then Focus (×1.25 interval/speed, ×1.2 range) and Frenzy (interval ÷ multiplier).
- XP: `HeroDefinition.xp_for_round(r)` at each round reward. Abilities: `match.use_frenzy`, `toggle_focus`,
  `frenzy_state`; timers tick on sim time during rounds only. `set_hero_level` is the test/debug cheat (F4, debug builds).
- Ricochet = `AttackDefinition.bounce_range_units`: after a hit the projectile turns to the nearest unhit snowball
  (global instant hits chain the same way, Bouncing Bullet).

## UI flow (P13)

- Main scene `scenes/ui/title_screen.tscn` → Play loads `scenes/main/match.tscn`; overlay "Main menu" returns.
- Audio buses Master → Music, SFX (`default_bus_layout.tres`); title Settings sliders set their volume, saved in
  `user://settings.cfg`. Nothing plays yet.
