extends Node3D
## Greybox tower (P03-T07/T08): one fixed coordinate, stats only from `def`. Also used as the placement ghost.

## Placeholder body colours per tower id (presentation only, A-01 tokens).
const COLORS: Dictionary[StringName, Color] = {
	&"snowball_rookie": Color("20517a"), &"avalanche_cannon": Color("173c4e"), &"biathlon_ranger": Color("1b6d68"),
	&"slope_wax_sprayer": Color("d9545c"), &"snow_sorcerer": Color("7a4fb0"), &"ski_resort_ticket_booth": Color("f9c96d"),
}
## P15 art binding (presentation only): tower id -> PresentationProfile. Towers without one keep the greybox body.
const PROFILES: Dictionary[StringName, PresentationProfile] = {
	&"snowball_rookie": preload("res://resources/presentation/snowball_rookie.tres"),
	&"avalanche_cannon": preload("res://resources/presentation/avalanche_cannon.tres"),
	&"biathlon_ranger": preload("res://resources/presentation/biathlon_ranger.tres"),
	&"slope_wax_sprayer": preload("res://resources/presentation/slope_wax_sprayer.tres"),
	&"snow_sorcerer": preload("res://resources/presentation/snow_sorcerer.tres"),
	&"ski_resort_ticket_booth": preload("res://resources/presentation/ski_resort_ticket_booth.tres"),
	&"camel_claus": preload("res://resources/presentation/camel_claus.tres"),
}
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
## Presentation: `_pivot` turns to aim; `_model` (the GLB) recoils inside it. The tower root never moves.
var _profile: PresentationProfile
var _pivot: Node3D
var _model: Node3D
var _anim: AnimationPlayer
var _muzzle: Node3D
var _flash: MeshInstance3D
## Seconds since the recoil started (simulation time); past kick + recover = at rest.
var _recoil_t: float = INF
## Hero presentation (P16-T01 base form): seconds since the last shot, wind-up and Focus pose weights 0..1,
## ground rings (Frenzy pulse, Focus reticle), the level-up glint at the hat and the level it last showed.
var _since_shot: float = INF
var _windup: float = 0.0
var _focus_k: float = 0.0
var _fx_time: float = 0.0
var _frenzy_ring: MeshInstance3D
var _focus_ring: MeshInstance3D
var _glint: MeshInstance3D
var _lens: MeshInstance3D
var _xp_ring: MeshInstance3D
var _shown_level: int = 1
var _level_t: float = INF


func setup(definition: TowerDefinition, id: int) -> void:
	def = definition
	entity_id = id
	spent = def.price
	rebuild_stats()
	var radius: float = def.footprint_units * GameDefinition.UNIT_M
	_body.scale = Vector3(radius / 0.5, 1.0, radius / 0.5)  # Body mesh radius is 0.5
	_label.text = def.display_name.get_slice(" ", def.display_name.get_slice_count(" ") - 1)
	_set_color(COLORS.get(def.id, Color.GRAY))
	_set_model(PROFILES.get(def.id))
	set_selected(false)


## Swaps the art model (the ghost is re-setup for every tower type). With a model, the greybox body only
## shows as a flat footprint disc under the ghost.
func _set_model(profile: PresentationProfile) -> void:
	if _pivot:
		_pivot.free()
		_pivot = null
		_model = null
		_anim = null
		_muzzle = null
		_flash = null
	for fx: MeshInstance3D in [_frenzy_ring, _focus_ring, _xp_ring]:
		if fx:
			fx.free()
	_frenzy_ring = null
	_focus_ring = null
	_xp_ring = null
	_glint = null
	_lens = null
	_profile = profile
	_recoil_t = INF
	_since_shot = INF
	_windup = 0.0
	_focus_k = 0.0
	_level_t = INF
	_body.visible = profile == null
	_body.scale.y = 1.0 if profile == null else 0.04
	_body.position.y = 0.5 if profile == null else 0.02
	_label.position.y = 1.5 if profile == null else 2.7  # clear of the 1.5x model cap at the game camera
	if profile == null:
		return
	_pivot = Node3D.new()
	_pivot.rotation.y = PI  # models face -Z; idle towers face the camera (+Z)
	add_child(_pivot)
	_model = profile.model.instantiate()
	_model.scale = Vector3.ONE * profile.display_scale
	_pivot.add_child(_model)
	var outline: StandardMaterial3D = StandardMaterial3D.new()
	outline.albedo_color = OUTLINE
	outline.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	outline.cull_mode = BaseMaterial3D.CULL_FRONT
	outline.grow = true
	outline.grow_amount = 0.012
	for mesh: MeshInstance3D in _model.find_children("*", "MeshInstance3D"):
		mesh.material_overlay = outline
		if profile.vertex_color_albedo:
			for i: int in mesh.mesh.get_surface_count():
				var material: BaseMaterial3D = mesh.mesh.surface_get_material(i) as BaseMaterial3D
				if material:
					material.vertex_color_use_as_albedo = true
	_muzzle = _model.find_child("muzzle_A")
	_anim = _model.find_child("AnimationPlayer")
	if _anim:
		# Advanced from animate() in simulation time, so pause and 1x/2x/4x apply to skeletal clips too.
		_anim.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
		if _anim.has_animation(&"idle"):
			_anim.play(&"idle")
			_anim.advance(0.0)
	if profile.muzzle_flash_m > 0.0 and _muzzle:
		var puff: SphereMesh = SphereMesh.new()
		puff.radius = 0.5 * profile.muzzle_flash_m / profile.display_scale  # the marker inherits the display scale
		puff.height = 2.0 * puff.radius
		puff.radial_segments = 12
		puff.rings = 6
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = profile.flash_color
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		puff.material = material
		_flash = MeshInstance3D.new()
		_flash.mesh = puff
		_flash.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_flash.visible = false
		_muzzle.add_child(_flash)
	if def is HeroDefinition and profile.ring_radius_m > 0.0:
		_shown_level = level
		_frenzy_ring = _fx_ring(profile.ring_radius_m, 0.06, profile.frenzy_color)
		_focus_ring = _fx_ring(profile.ring_radius_m * 0.8, 0.03, profile.focus_color)
		_xp_ring = _fx_ring(profile.ring_radius_m * 0.6, 0.05, profile.level_up_color)
		var hat: Node3D = _model.find_child("hat_top")
		if hat:
			_glint = _fx_mesh(SphereMesh.new(), profile.level_up_color)
			_glint.mesh.radius = 0.12 / profile.display_scale
			_glint.mesh.height = 0.24 / profile.display_scale
			hat.add_child(_glint)
		var goggle: Node3D = _model.find_child("focus_goggle")
		if goggle:  # Focus: the goggles light up (doc 02: "goggles/aim reticle")
			_lens = _fx_mesh(SphereMesh.new(), profile.focus_color)
			_lens.mesh.radius = 0.09 / profile.display_scale
			_lens.mesh.height = 0.09 / profile.display_scale
			goggle.add_child(_lens)


## Hidden flat unshaded ring on the ground (hero feedback), child of the tower root so aiming never turns it.
func _fx_ring(radius: float, width: float, color: Color) -> MeshInstance3D:
	var torus: TorusMesh = TorusMesh.new()
	torus.inner_radius = radius - width
	torus.outer_radius = radius
	torus.rings = 48
	torus.ring_segments = 4
	var ring: MeshInstance3D = _fx_mesh(torus, color)
	ring.scale.y = 0.15
	ring.position.y = 0.03
	add_child(ring)
	return ring


func _fx_mesh(mesh: PrimitiveMesh, color: Color) -> MeshInstance3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material = material
	var node: MeshInstance3D = MeshInstance3D.new()
	node.mesh = mesh
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	node.visible = false
	return node


## Where shot visuals start: the model's muzzle_A marker (thrower's hand, cannon bore), else the greybox 0.5 m point.
func muzzle_position() -> Vector3:
	if _muzzle and _muzzle.is_inside_tree():
		return _muzzle.global_position
	return position + Vector3.UP * 0.5


## Presentation only (called after the simulation fired): face the shot, play the attack clip if the model has one,
## and start the procedural recoil.
func play_attack(dir: Vector3) -> void:
	if _pivot == null:
		return
	_pivot.rotation.y = atan2(-dir.x, -dir.z) - deg_to_rad(_profile.weapon_yaw_deg)  # the weapon faces the shot
	if _anim and _anim.has_animation(&"attack"):
		_anim.stop()
		_anim.play(&"attack")
		if _anim.has_animation(&"idle"):
			_anim.queue(&"idle")
	_since_shot = 0.0
	_start_reaction()


## Presentation only (called after the simulation produced Booth income): the reaction and window puff, no turning.
func play_income() -> void:
	if _pivot:
		_start_reaction()


func _start_reaction() -> void:
	if _profile.recoil_m > 0.0 or _profile.recoil_squash != 0.0 or _flash:
		# Re-entering mid-recovery starts the kick at the current amount: no snap, and no drift under rapid fire.
		_recoil_t = _profile.recoil_kick_s * _recoil_amount()


## Presentation step, called by the match every simulation tick (so it stops with pause and follows 1x/2x/4x).
## The pose is a pure function of the reaction timers and hero state, rebuilt from rest each step.
func animate(dt: float) -> void:
	if _anim:
		_anim.advance(dt)
	if _model == null:
		return
	if _frenzy_ring:
		_animate_hero(dt)
	if _recoil_t != INF:
		_recoil_t += dt
	var k: float = _recoil_amount()
	var p: PresentationProfile = _profile
	var s: float = p.display_scale
	var w: float = deg_to_rad(p.weapon_yaw_deg)
	var elastic: float = p.frenzy_recoil_mult if frenzy_left > 0.0 else 1.0
	var squash: float = p.recoil_squash * k * elastic + p.anticipation_squash * _windup + p.focus_squash * _focus_k
	var tilt: float = p.recoil_tilt_deg * k + p.anticipation_tilt_deg * _windup + p.focus_tilt_deg * _focus_k
	# Models face -Z, the weapon along R_y(w) * -Z: slide back opposite the weapon and pitch across its axis.
	_model.position = Vector3(sin(w), 0.0, cos(w)) * p.recoil_m * k
	_model.basis = Basis(Vector3(cos(w), 0.0, -sin(w)), deg_to_rad(tilt)) * Basis.from_scale(
			Vector3(s * (1.0 + 0.5 * squash), s * (1.0 - squash), s * (1.0 + 0.5 * squash)))
	if _flash:
		var flash_on: bool = _recoil_t < p.recoil_kick_s + 0.5 * p.recoil_recover_s
		_flash.visible = flash_on
		_flash.scale = Vector3.ONE * (0.4 + 0.6 * k) if flash_on else Vector3.ONE
	if _recoil_t >= p.recoil_kick_s + p.recoil_recover_s:
		_recoil_t = INF  # exactly at rest


## Hero feedback from existing state only (never writes simulation state): wind-up from the first attack's
## cooldown while engaged, Focus pose ease, Frenzy pulse ring, Focus reticle ring, level-up glint + XP pulse.
func _animate_hero(dt: float) -> void:
	var p: PresentationProfile = _profile
	_fx_time += dt
	_since_shot += dt
	var interval: float = attacks[0].interval_s
	# Engaged = fired within the last interval; fades over 0.25 s when no target follows (no snap back).
	var engaged: float = clampf((interval + 0.25 - _since_shot) / 0.25, 0.0, 1.0)
	_windup = 0.0
	if p.anticipation_s > 0.0 and engaged > 0.0:
		_windup = clampf(1.0 - cooldowns[0] / p.anticipation_s, 0.0, 1.0) * engaged
	_focus_k = move_toward(_focus_k, 1.0 if focus else 0.0, dt / 0.15)
	var frenzy: bool = frenzy_left > 0.0
	_frenzy_ring.visible = frenzy
	if frenzy:
		var pulse: float = 0.5 + 0.5 * sin(_fx_time * TAU * 3.0)
		_frenzy_ring.scale = Vector3(1.0 + 0.06 * pulse, 0.15, 1.0 + 0.06 * pulse)
		_frenzy_ring.transparency = 0.45 * (1.0 - pulse)
	_focus_ring.visible = _focus_k > 0.0
	_focus_ring.transparency = 1.0 - _focus_k
	if _lens:
		_lens.visible = _focus_k > 0.0
		_lens.scale = Vector3.ONE * _focus_k
	if level != _shown_level:
		if level > _shown_level:
			_level_t = 0.0
		_shown_level = level
	if _level_t != INF:
		_level_t += dt
		var u: float = _level_t / 0.8
		if u >= 1.0:
			_level_t = INF
		_xp_ring.visible = u < 1.0
		_xp_ring.scale = Vector3(1.0 + 1.2 * u, 0.15, 1.0 + 1.2 * u)
		_xp_ring.transparency = u
		if _glint:
			_glint.visible = u < 1.0
			_glint.scale = Vector3.ONE * sin(PI * minf(u * 1.6, 1.0))


## Recoil amount 0..1 at `_recoil_t`: fast linear kick, ease-out recovery, 0 at rest.
func _recoil_amount() -> float:
	if _recoil_t == INF:
		return 0.0
	if _recoil_t < _profile.recoil_kick_s:
		return _recoil_t / _profile.recoil_kick_s
	var u: float = clampf((_recoil_t - _profile.recoil_kick_s) / _profile.recoil_recover_s, 0.0, 1.0)
	return (1.0 - u) * (1.0 - u)


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
	_label.visible = on or _profile == null  # Dev 12: names only on the selected tower/ghost (no overlap)


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
