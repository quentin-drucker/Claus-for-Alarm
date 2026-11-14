class_name HeroDefinition
extends TowerDefinition
## Camel Claus (Quincy, M-09): a tower with its own XP progression instead of upgrade paths (no `upgrades`).
## Uses the TowerDefinition fields price / range_units / footprint_units / attacks (attacks[0] = ricochet shot).

@export var source_hero: String = ""
## Cumulative XP for levels 1..20; index 0 = level 1 = 0 XP.
## Array[int], not PackedInt32Array: the Web export dropped the packed version from the .tres (2026-11-13).
@export var level_xp: Array[int] = []
## Changes gained at each level, same indexing. Applied keys: pierce, interval_s, projectile_count, range_units,
## camo_detection, frenzy_multiplier, frenzy_cooldown_s, unlock_ability, unlock_stance. Other keys (explosion_every,
## bonus_vs_large, barrage_cooldown_s, projectile_lifetime_mult) are data only: unreachable in the 19-round match.
@export var level_changes: Array[Dictionary] = []
## Snowball Frenzy (Rapid Shot, level 3): attack speed multiplier, duration and cooldown (seconds of sim time).
@export var frenzy_multiplier: float = 3.0
@export var frenzy_duration_s: float = 8.0
@export var frenzy_cooldown_s: float = 60.0
## Focused Shot stance (v57, level 4): multipliers while on.
@export var focus_interval_mult: float = 1.25
@export var focus_speed_mult: float = 1.25
@export var focus_range_mult: float = 1.2


## XP every hero on the map earns at the end of round `r` (BTD6 round XP, ratio 1 for Quincy).
## ponytail: community formula, not on the teemo.dev pages (PROTOTYPE_ASSUMPTION); rounds > 20 never happen here.
static func xp_for_round(r: int) -> int:
	if r <= 20:
		return 20 * r + 20
	if r <= 50:
		return 40 * r - 380
	return 90 * r - 2880


## Level (1-based) for a total XP.
func level_for_xp(xp: int) -> int:
	var level: int = 1
	while level < level_xp.size() and xp >= level_xp[level]:
		level += 1
	return level


func balance_fields() -> PackedStringArray:
	return ["price", "range_units", "footprint_units", "frenzy_multiplier",
			"frenzy_duration_s", "frenzy_cooldown_s", "focus_interval_mult", "focus_speed_mult", "focus_range_mult"]


func validate() -> PackedStringArray:
	var errors: PackedStringArray = super()
	if attacks.size() != 1:
		errors.append("%s: a hero needs exactly one attack" % id)
	if not upgrades.is_empty():
		errors.append("%s: a hero has no upgrade paths" % id)
	if level_xp.is_empty() or level_xp[0] != 0:
		errors.append("%s: level_xp must start at 0" % id)
	for i: int in range(1, level_xp.size()):
		if level_xp[i] <= level_xp[i - 1]:
			errors.append("%s: level_xp not increasing at level %d" % [id, i + 1])
	if level_changes.size() != level_xp.size():
		errors.append("%s: level_changes and level_xp sizes differ" % id)
	return errors
