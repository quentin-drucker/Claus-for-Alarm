class_name AttackDefinition
extends GameDefinition
## One attack of a tower or hero (M-10), or a sub-attack it creates. Ranges/speeds in reference units.
## A projectile flies straight; a burst (radius_units > 0) hits everything in its circle at once.

@export var interval_s: float = 1.0
## Layers removed per hit; leftover damage carries into the next layer (BTD6 overflow, M-05). 0 = no damage.
@export var damage: int = 1
## Distinct targets one projectile (or burst) may hit (not damage per target, M-05).
@export var pierce: int = 1
@export var projectile_count: int = 1
## Degrees between the projectiles of one volley (360 / count = radial ring around the origin).
@export var spread_deg: float = 0.0
## Damage family for immunity checks: an enemy with property `immune_<damage_type>` takes no damage.
@export var damage_type: StringName = &"sharp"
## > 0: instant area burst of this radius at its origin instead of a projectile (Bomb explosion).
@export var radius_units: float = 0.0
## Fraction of speed removed by the slow status this attack applies (Glue base: 0.5), and for how long.
@export var slow_factor: float = 0.0
@export var slow_duration_s: float = 0.0
## The slow survives layer breaks (Glue Soak); otherwise a break removes it.
@export var soaks_layers: bool = false
## Extra damage against `camo` snowballs (Sniper Night Vision Goggles).
@export var bonus_vs_camo: int = 0
## Straight-line projectile speed in reference units/s, and how long it flies before expiring.
@export var projectile_speed_units: float = 300.0
@export var projectile_lifetime_s: float = 0.3
## Can see and target enemies with the `camo` property.
@export var detects_camo: bool = false
## Sub-attacks created where a projectile hits (explosion, shrapnel), and where it ends (pierce used up or
## lifetime over: cluster bombs). Sub-projectiles inherit the parent's hit history and direction.
@export var on_contact: Array[AttackDefinition] = []
@export var on_expire: Array[AttackDefinition] = []


func balance_fields() -> PackedStringArray:
	return ["interval_s", "damage", "pierce", "projectile_count", "radius_units", "slow_factor", "slow_duration_s",
			"projectile_speed_units", "projectile_lifetime_s"]


func validate() -> PackedStringArray:
	var errors: PackedStringArray = super()
	if interval_s <= 0.0:
		errors.append("%s.interval_s: must be > 0" % id)
	for sub: AttackDefinition in on_contact + on_expire:
		errors.append_array(sub.validate())
	return errors


## This attack and every sub-attack below it.
func tree() -> Array[AttackDefinition]:
	var out: Array[AttackDefinition] = [self]
	for sub: AttackDefinition in on_contact + on_expire:
		out.append_array(sub.tree())
	return out
