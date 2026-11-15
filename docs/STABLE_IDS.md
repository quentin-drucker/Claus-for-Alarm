# Claus for Alarm - Stable IDs (P14-T04, frozen at `technical-alpha`)

Gameplay ids used by data, events and future art bindings (`gameplay_id` -> model/VFX/audio).
Renaming one after the freeze needs a change request (master plan 12.5). Display names may change freely.
Generated from `resources/` and `scripts/core/events.gd`.

## Towers and upgrades
- `avalanche_cannon` - upgrades: `avalanche_cannon_b1`, `avalanche_cannon_b2`, `avalanche_cannon_b3`, `avalanche_cannon_b4`, `avalanche_cannon_b5`, `avalanche_cannon_m1`, `avalanche_cannon_m2`, `avalanche_cannon_m3`, `avalanche_cannon_m4`, `avalanche_cannon_m5`, `avalanche_cannon_t1`, `avalanche_cannon_t2`, `avalanche_cannon_t3`, `avalanche_cannon_t4`, `avalanche_cannon_t5`
  - attacks: `avalanche_cannon_base`, `avalanche_cannon_blast`, `avalanche_cannon_cluster_blast`, `avalanche_cannon_frag`
- `biathlon_ranger` - upgrades: `biathlon_ranger_b1`, `biathlon_ranger_b2`, `biathlon_ranger_b3`, `biathlon_ranger_b4`, `biathlon_ranger_b5`, `biathlon_ranger_m1`, `biathlon_ranger_m2`, `biathlon_ranger_m3`, `biathlon_ranger_m4`, `biathlon_ranger_m5`, `biathlon_ranger_t1`, `biathlon_ranger_t2`, `biathlon_ranger_t3`, `biathlon_ranger_t4`, `biathlon_ranger_t5`
  - attacks: `biathlon_ranger_base`, `biathlon_ranger_shrapnel`
- `ski_resort_ticket_booth` - upgrades: `ski_resort_ticket_booth_b1`, `ski_resort_ticket_booth_b2`, `ski_resort_ticket_booth_b3`, `ski_resort_ticket_booth_b4`, `ski_resort_ticket_booth_b5`, `ski_resort_ticket_booth_m1`, `ski_resort_ticket_booth_m2`, `ski_resort_ticket_booth_m3`, `ski_resort_ticket_booth_m4`, `ski_resort_ticket_booth_m5`, `ski_resort_ticket_booth_t1`, `ski_resort_ticket_booth_t2`, `ski_resort_ticket_booth_t3`, `ski_resort_ticket_booth_t4`, `ski_resort_ticket_booth_t5`
  - attacks: none (income only)
- `slope_wax_sprayer` - upgrades: `slope_wax_sprayer_b1`, `slope_wax_sprayer_b2`, `slope_wax_sprayer_b3`, `slope_wax_sprayer_b4`, `slope_wax_sprayer_b5`, `slope_wax_sprayer_m1`, `slope_wax_sprayer_m2`, `slope_wax_sprayer_m3`, `slope_wax_sprayer_m4`, `slope_wax_sprayer_m5`, `slope_wax_sprayer_t1`, `slope_wax_sprayer_t2`, `slope_wax_sprayer_t3`, `slope_wax_sprayer_t4`, `slope_wax_sprayer_t5`
  - attacks: `slope_wax_sprayer_base`, `slope_wax_sprayer_splatter`
- `snow_sorcerer` - upgrades: `snow_sorcerer_b1`, `snow_sorcerer_b2`, `snow_sorcerer_b3`, `snow_sorcerer_b4`, `snow_sorcerer_b5`, `snow_sorcerer_m1`, `snow_sorcerer_m2`, `snow_sorcerer_m3`, `snow_sorcerer_m4`, `snow_sorcerer_m5`, `snow_sorcerer_t1`, `snow_sorcerer_t2`, `snow_sorcerer_t3`, `snow_sorcerer_t4`, `snow_sorcerer_t5`
  - attacks: `snow_sorcerer_base`, `snow_sorcerer_breath`, `snow_sorcerer_fireball`, `snow_sorcerer_fireball_blast`, `snow_sorcerer_wall`
- `snowball_rookie` - upgrades: `snowball_rookie_b1`, `snowball_rookie_b2`, `snowball_rookie_b3`, `snowball_rookie_b4`, `snowball_rookie_b5`, `snowball_rookie_m1`, `snowball_rookie_m2`, `snowball_rookie_m3`, `snowball_rookie_m4`, `snowball_rookie_m5`, `snowball_rookie_t1`, `snowball_rookie_t2`, `snowball_rookie_t3`, `snowball_rookie_t4`, `snowball_rookie_t5`
  - attacks: `snowball_rookie_base`

## Hero
- `camel_claus`; attacks: `camel_claus_base`
- skills: `blizzard_barrage`, `focused_shot`, `snowball_frenzy`

## Snowball types
`black`, `blue`, `camo_blue`, `camo_mint`, `camo_powder`, `coral`, `mint`, `powder`, `purple`, `violet`, `white`

## Rounds
`round_01` ... `round_25` (exact BTD6 v56 rounds, DEC-025/026)

## Event types (`Events.TYPES`)
`tower_placed`, `tower_sold`, `purchase_failed`, `tower_upgraded`, `target_changed`, `attack_fired`, `enemy_spawned`, `enemy_hit`, `enemy_immune`, `layer_broken`, `enemy_split`, `enemy_leaked`, `status_applied`, `ability_ready`, `ability_used`, `hero_level_up`, `round_started`, `round_complete`, `income_collected`, `income_banked`, `pickup_spawned`, `pickup_expired`, `match_won`, `match_lost`

## Damage types and properties
Damage types in data: `corrosive`, `energy`, `explosion`, `glue`, `normal`, `plasma`, `sharp`, `shatter`. `cold` is reserved (White immunity). Properties: `camo`, `immune_<damage type>`.

## Scene / placeholder paths (art-swap points, P15+)
- Tower body: `res://scenes/towers/tower.tscn` (one scene; `def.id` picks the look)
- Tower art binding: `res://resources/presentation/<tower id>.tres` (`PresentationProfile`: model, display scale,
  optional clips, recoil, muzzle puff); markers in the GLB: `muzzle_A`, `effect_center` (P15-A02)
- Snowball: `res://scenes/enemies/snowball.tscn` (`$Mesh` material by `def.id`, `Marker` letter for specials)
- Map `res://scenes/world/ski_circuit.tscn`; match `res://scenes/main/match.tscn`; HUD `res://scenes/ui/match_hud.tscn`
- Placeholder feedback `res://scenes/ui/feedback_layer.gd` (listens to Events; replace with VFX/SFX)
