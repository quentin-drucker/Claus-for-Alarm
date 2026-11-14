extends Node3D
## Greybox tower (P03-T07/T08): one fixed coordinate, stats only from `def`. Also used as the placement ghost.

## Placeholder body colours per tower id (presentation only, A-01 tokens).
const COLORS: Dictionary[StringName, Color] = {
	&"snowball_rookie": Color("20517a"), &"avalanche_cannon": Color("173c4e"), &"biathlon_ranger": Color("1b6d68"),
	&"slope_wax_sprayer": Color("d9545c"), &"snow_sorcerer": Color("7a4fb0"), &"ski_resort_ticket_booth": Color("f9c96d"),
}
## P15 art binding (presentation only): tower id -> model. Towers without one keep the greybox body.
const MODELS: Dictionary[StringName, PackedScene] = {&"snowball_rookie": preload("res://assets/models/elf_rookie.glb")}
## Dark inverted-hull outline for character models (docs/ART_STYLE.md section 6).
const OUTLINE: Color = Color("173c4e")
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
var auto_collect_ratio: float = 0.0
var bank_capacity: int = 0
var bank_interest: float = 0.0
var sell_bonus: float = 0.0
## Cash waiting in this Booth's bank (Monkey Bank).
var bank: int = 0
## Hero only (def is HeroDefinition): total XP, level, Focus stance, Frenzy seconds left / cooldown left,
## and the level-dependent Frenzy multiplier and cooldown.
var xp: int = 0
var level: int = 1
var focus: bool = false
var frenzy_left: float = 0.0
var frenzy_cooldown_left: float = 0.0
var frenzy_multiplier: float = 0.0
var frenzy_cooldown_s: float = 0.0
## Seconds until each attack may fire again (simulation time), parallel to `attacks`.
var cooldowns: Array[float] = []
## Targeting.Priority; new towers target First.
var priority: int = 0

@onready var _body: MeshInstance3D = $Body
@onready var _label: Label3D = $Label
@onready var _range: MeshInstance3D = $Range
var _model: Node3D
var _anim: AnimationPlayer


func setup(definition: TowerDefinition, id: int) -> void:
	def = definition
	entity_id = id
	spent = def.price
	rebuild_stats()
	var radius: float = def.footprint_units * GameDefinition.UNIT_M
	_body.scale = Vector3(radius / 0.5, 1.0, radius / 0.5)  # Body mesh radius is 0.5
	_label.text = def.display_name.get_slice(" ", def.display_name.get_slice_count(" ") - 1)
	_set_color(COLORS.get(def.id, Color.GRAY))
	_set_model(MODELS.get(def.id))
	set_selected(false)


## Swaps the art model (the ghost is re-setup for every tower type). With a model, the greybox body only
## shows as a flat footprint disc under the ghost.
func _set_model(scene: PackedScene) -> void:
	if _model:
		_model.free()
		_model = null
		_anim = null
	_body.visible = scene == null
	_body.scale.y = 1.0 if scene == null else 0.04
	_body.position.y = 0.5 if scene == null else 0.02
	if scene == null:
		return
	_model = scene.instantiate()
	_model.rotation.y = PI  # models face -Z; idle towers face the camera (+Z)
	add_child(_model)
	var outline: StandardMaterial3D = StandardMaterial3D.new()
	outline.albedo_color = OUTLINE
	outline.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	outline.cull_mode = BaseMaterial3D.CULL_FRONT
	outline.grow = true
	outline.grow_amount = 0.012
	for mesh: MeshInstance3D in _model.find_children("*", "MeshInstance3D"):
		mesh.material_overlay = outline
	_anim = _model.find_child("AnimationPlayer")
	_anim.play(&"idle")


## Presentation only (called after the simulation fired): face the shot and play the throw.
func play_attack(dir: Vector3) -> void:
	if _anim == null:
		return
	_model.rotation.y = atan2(-dir.x, -dir.z)
	_anim.stop()
	_anim.play(&"attack")
	_anim.queue(&"idle")


## Recomputes the working stats from `def`. Attack resources are deep copies so upgrades never touch shared data.
func rebuild_stats() -> void:
	range_units = def.range_units
	pickups_per_round = def.pickups_per_round
	cash_per_pickup = def.cash_per_pickup
	pickup_lifetime_s = def.pickup_lifetime_s
	auto_collect_ratio = def.auto_collect_ratio
	bank_capacity = def.bank_capacity
	bank_interest = def.bank_interest
	sell_bonus = def.sell_bonus
	attacks.clear()
	for attack: AttackDefinition in def.attacks:
		attacks.append(attack.duplicate_deep())
	# Two passes: every added attack first (so a stat change on another path can reach it, e.g. Full Metal
	# Jacket on Shrapnel), then the stat changes, each in path -> tier -> list order.
	for appends: bool in [true, false]:
		for path: int in 3:
			for tier: int in range(1, tiers[path] + 1):
				for effect: UpgradeEffect in def.get_upgrade(path, tier).effects:
					if (effect.op == UpgradeEffect.Op.APPEND) == appends:
						_apply(effect)
	if def is HeroDefinition:
		_apply_levels()
	cooldowns.resize(attacks.size())  # keeps running cooldowns; an attack added by an upgrade starts ready
	var range_m: float = range_units * GameDefinition.UNIT_M
	_range.scale = Vector3(range_m, 1.0, range_m)  # Range mesh radius is 1


## Hero: each reached level's changes once, in level order (P10-T04), then Focus and Frenzy on top.
func _apply_levels() -> void:
	var hero: HeroDefinition = def
	var shot: AttackDefinition = attacks[0]
	frenzy_multiplier = hero.frenzy_multiplier
	frenzy_cooldown_s = hero.frenzy_cooldown_s
	for i: int in level:
		var changes: Dictionary = hero.level_changes[i]
		for key: String in changes:
			match key:
				"pierce", "interval_s", "projectile_count":
					shot.set(key, changes[key])
				"range_units":
					range_units = changes[key]
				"camo_detection":
					shot.detects_camo = changes[key]
				"frenzy_multiplier":
					frenzy_multiplier = changes[key]
				"frenzy_cooldown_s":
					frenzy_cooldown_s = changes[key]
	if focus:
		shot.interval_s *= hero.focus_interval_mult
		shot.projectile_speed_units *= hero.focus_speed_mult
		range_units *= hero.focus_range_mult
	if frenzy_left > 0.0:
		shot.interval_s /= frenzy_multiplier


## Ability/stance unlocked by the current level (hero only), e.g. "snowball_frenzy", "focused_shot".
func has_unlock(what: String) -> bool:
	if not def is HeroDefinition:
		return false
	for i: int in level:
		if def.level_changes[i].get("unlock_ability", "") == what or def.level_changes[i].get("unlock_stance", "") == what:
			return true
	return false


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
	_body.visible = true
	_label.text = reason if reason != "" else def.display_name
	_label.modulate = INVALID if reason != "" else Color("173548")
	set_selected(true)


func _set_color(color: Color) -> void:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	if color.a < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_body.material_override = material
