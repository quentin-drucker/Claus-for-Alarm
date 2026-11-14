class_name EnemyDefinition
extends GameDefinition
## One snowball type (M-03). Layers are a child chain: breaking a shell spawns `child_count` of `child_id`.

@export var display_name: String = ""
## Reference map units per second (Powder/Red = 25).
@export var speed_units: float = 25.0
## Spawned on layer break; empty = fully destroyed. child_count > 1 splits into that many snowballs.
@export var child_id: StringName
@export var child_count: int = 0
@export var cash_per_pop: int = 1
## Property flags: `camo` (needs AttackDefinition.detects_camo; camo types chain to camo children),
## `immune_<damage_type>` (Black immune_explosion, White immune_cold, Aurora (`purple`) immune_energy/fire/plasma).
## Regrow is not used (DEC-031); fortified is DEFERRED (REGISTRY.md).
@export var properties: Array[StringName] = []  # not Packed*: see HeroDefinition.level_xp


func balance_fields() -> PackedStringArray:
	return ["speed_units", "child_count", "cash_per_pop"]


func validate() -> PackedStringArray:
	var errors: PackedStringArray = super()
	if (child_id == &"") != (child_count == 0):
		errors.append("%s: child_id and child_count must both be set or both empty" % id)
	return errors
