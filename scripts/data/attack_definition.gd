class_name AttackDefinition
extends GameDefinition
## One attack of a tower or hero (M-10). Ranges/speeds live on the owner, in reference units.

@export var interval_s: float = 1.0
@export var damage: int = 1
## Distinct targets one projectile may hit (not damage per target, M-05).
@export var pierce: int = 1
@export var projectile_count: int = 1
## Damage family for immunity checks (P05+): sharp, explosion, energy, glue.
@export var damage_type: StringName = &"sharp"
## Targets hit by the explosion an explosive projectile creates (Bomb: contact pierce 1, blast 22).
@export var splash_pierce: int = 0
## Fraction of speed removed by the slow status this attack applies (Glue base: 0.5).
@export var slow_factor: float = 0.0


func balance_fields() -> PackedStringArray:
	return ["interval_s", "damage", "pierce", "projectile_count", "splash_pierce", "slow_factor"]


func validate() -> PackedStringArray:
	var errors: PackedStringArray = super()
	if interval_s <= 0.0:
		errors.append("%s.interval_s: must be > 0" % id)
	return errors
