extends Node3D
## Greybox tower (P03-T07/T08): one fixed coordinate, stats only from `def`. Also used as the placement ghost.

## Placeholder body colours per tower id (presentation only, A-01 tokens).
const COLORS: Dictionary[StringName, Color] = {
	&"snowball_rookie": Color("20517a"), &"avalanche_cannon": Color("173c4e"), &"biathlon_ranger": Color("1b6d68"),
	&"slope_wax_sprayer": Color("d9545c"), &"snow_sorcerer": Color("7a4fb0"), &"ski_resort_ticket_booth": Color("f9c96d"),
}
const VALID: Color = Color("3f9b7b")
const INVALID: Color = Color("c73e49")

var def: TowerDefinition
var entity_id: int = 0
## Cash invested (base + upgrades), for the sell value.
var spent: int = 0
var tiers: Vector3i = Vector3i.ZERO
## Working stats: copies of `def` values with owned upgrades applied (rebuild_stats). The simulation reads these.
var range_units: float = 0.0
var attacks: Array[AttackDefinition] = []
var pickups_per_round: int = 0
var cash_per_pickup: int = 0
var pickup_lifetime_s: float = 0.0
## Seconds until each attack may fire again (simulation time), parallel to `attacks`.
var cooldowns: Array[float] = []
## Targeting.Priority; new towers target First.
var priority: int = 0

@onready var _body: MeshInstance3D = $Body
@onready var _label: Label3D = $Label
@onready var _range: MeshInstance3D = $Range


func setup(definition: TowerDefinition, id: int) -> void:
	def = definition
	entity_id = id
	spent = def.price
	rebuild_stats()
	var radius: float = def.footprint_units * GameDefinition.UNIT_M
	_body.scale = Vector3(radius / 0.5, 1.0, radius / 0.5)  # Body mesh radius is 0.5
	_label.text = def.display_name.get_slice(" ", def.display_name.get_slice_count(" ") - 1)
	_set_color(COLORS.get(def.id, Color.GRAY))
	set_selected(false)


## Recomputes the working stats from `def`. Attack resources are deep copies so upgrades never touch shared data.
func rebuild_stats() -> void:
	range_units = def.range_units
	pickups_per_round = def.pickups_per_round
	cash_per_pickup = def.cash_per_pickup
	pickup_lifetime_s = def.pickup_lifetime_s
	attacks.clear()
	for attack: AttackDefinition in def.attacks:
		attacks.append(attack.duplicate_deep())
	for path: int in 3:
		for tier: int in range(1, tiers[path] + 1):
			for effect: UpgradeEffect in def.get_upgrade(path, tier).effects:
				_apply(effect)
	cooldowns.resize(attacks.size())  # keeps running cooldowns; an attack added by an upgrade starts ready
	var range_m: float = range_units * GameDefinition.UNIT_M
	_range.scale = Vector3(range_m, 1.0, range_m)  # Range mesh radius is 1


func _apply(effect: UpgradeEffect) -> void:
	var target: Object = self if effect.target == &"" else find_attack(effect.target)
	if target == null:
		return  # an attack another path adds; this tower does not own it
	var current: Variant = target.get(effect.field)
	match effect.op:
		UpgradeEffect.Op.ADD:
			target.set(effect.field, type_convert(current + effect.value, typeof(current)))
		UpgradeEffect.Op.MULTIPLY:
			target.set(effect.field, type_convert(current * effect.value, typeof(current)))
		UpgradeEffect.Op.SET:
			target.set(effect.field, effect.text if effect.text != &"" else type_convert(effect.value, typeof(current)))
		UpgradeEffect.Op.APPEND:
			current.append(effect.attack.duplicate_deep())


## Working attack (or sub-attack) with this id, or null.
func find_attack(attack_id: StringName) -> AttackDefinition:
	for attack: AttackDefinition in attacks:
		for sub: AttackDefinition in attack.tree():
			if sub.id == attack_id:
				return sub
	return null


## Footprint for placement checks: Vector3(x, z, radius).
func footprint() -> Vector3:
	return Vector3(position.x, position.z, def.footprint_units * GameDefinition.UNIT_M)


func set_selected(on: bool) -> void:
	_range.visible = on and range_units > 0.0


## Ghost look: translucent green/red body, range ring, reason text when invalid.
func show_ghost(reason: String) -> void:
	_set_color(Color(VALID if reason == "" else INVALID, 0.55))
	_label.text = reason if reason != "" else def.display_name
	_label.modulate = INVALID if reason != "" else Color("173548")
	set_selected(true)


func _set_color(color: Color) -> void:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	if color.a < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_body.material_override = material
