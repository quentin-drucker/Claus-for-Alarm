class_name HeroDefinition
extends GameDefinition
## Camel Claus (Quincy, M-09): own XP progression, no upgrade paths.

@export var display_name: String = ""
@export var source_hero: String = ""
@export var price: int = 0
@export var range_units: float = 0.0
@export var footprint_units: float = 6.0
@export var attack: AttackDefinition
## Cumulative XP for levels 1..20; index 0 = level 1 = 0 XP.
@export var level_xp: PackedInt32Array = []
## Changes gained at each level, same indexing (stat values, unlocks); applied from P10.
@export var level_changes: Array[Dictionary] = []


func balance_fields() -> PackedStringArray:
	return ["price", "range_units", "footprint_units"]


func validate() -> PackedStringArray:
	var errors: PackedStringArray = super()
	if attack == null:
		errors.append("%s: no attack" % id)
	else:
		errors.append_array(attack.validate())
	if level_xp.is_empty() or level_xp[0] != 0:
		errors.append("%s: level_xp must start at 0" % id)
	for i: int in range(1, level_xp.size()):
		if level_xp[i] <= level_xp[i - 1]:
			errors.append("%s: level_xp not increasing at level %d" % [id, i + 1])
	if level_changes.size() != level_xp.size():
		errors.append("%s: level_changes and level_xp sizes differ" % id)
	return errors
