extends Node3D
## Match scene: owns the simulation clock, match state, ledger, towers and snowballs. All rule checks live here
## or in scripts/core; the HUD and meshes only display state (docs/ARCHITECTURE.md §Match).

## Any HUD-visible value changed: state, cash, lives, round, selection, speed, pause.
signal changed

enum State { BOOT, PREPARE, ROUND_SPAWN, ROUND_CLEANUP, ROUND_REWARD, WON, LOST }

## Allowed transitions. Pause is not a state: it freezes the clock in any live state and resumes where it was.
const TRANSITIONS: Dictionary[State, Array] = {
	State.BOOT: [State.PREPARE],
	State.PREPARE: [State.ROUND_SPAWN],
	State.ROUND_SPAWN: [State.ROUND_CLEANUP, State.LOST],
	State.ROUND_CLEANUP: [State.ROUND_REWARD, State.LOST],
	State.ROUND_REWARD: [State.PREPARE, State.WON],
	State.WON: [],
	State.LOST: [],
}
const FAST_SPEED: float = 2.0
const GROUND: Plane = Plane(Vector3.UP, 0.0)
const TOWER_SCENE: PackedScene = preload("res://scenes/towers/tower.tscn")
const SNOWBALL_SCENE: PackedScene = preload("res://scenes/enemies/snowball.tscn")
## Contact radius of a snowball for projectile hits (snowball mesh radius, metres).
## ponytail: one size for all five basic layers; per-type size when large specials arrive (P11).
const HIT_RADIUS_M: float = 0.4
const SHOT_MESH: SphereMesh = preload("res://scenes/main/shot_mesh.tres")
const BURST_COLOR: Color = Color(1.0, 0.85, 0.6, 0.45)
const PICKUP_COLOR: Color = Color("f9c96d")
## Click distance that collects a ticket pickup (metres).
const PICKUP_RADIUS_M: float = 0.6


## One flying projectile (simulation state; `node` is its placeholder visual).
class Shot:
	var node: MeshInstance3D
	var pos: Vector3
	var velocity: Vector3
	var life: float
	var pierce: int
	var attack: AttackDefinition
	var source_id: int
	## Entity ids already hit: a snowball keeps its id when a layer breaks, so one shot never hits it twice.
	var hit: Dictionary[int, bool] = {}

## One uncollected ticket pickup (simulation state; `node` is its placeholder visual).
class Pickup:
	var node: MeshInstance3D
	var pos: Vector3
	var value: int
	var life: float
	var source_id: int

var state: State = State.BOOT
## Index of the current (or last finished) round in Content.rounds; -1 before round 1.
var round_index: int = -1
## Shop order: cheapest first; keys 1-6 pick these.
var shop: Array[TowerDefinition] = []
var clock: SimClock
var ledger: EconomyLedger
var lives: int = 0
## Live snowballs in spawn order (authoritative; nodes are freed after removal from this list).
var snowballs: Array[Node3D] = []
var shots: Array[Shot] = []
## Ticket Booth income lying on the ground until collected or expired.
var pickups: Array[Pickup] = []
## Tower type being placed (null = not placing).
var placing: TowerDefinition
var selected: Node3D
var _next_id: int = 1
var _schedule: Array = []
var _spawn_cursor: int = 0
## This round's ticket drops: [round time, booth, index], by time.
var _drops: Array = []
var _drop_cursor: int = 0
var _round_time: float = 0.0
var _shots_root: Node3D = Node3D.new()

@onready var course: Node3D = $SkiCircuit
@onready var camera: Camera3D = $Camera3D
@onready var towers_root: Node3D = $Towers
@onready var snowballs_root: Node3D = $Snowballs
@onready var ghost: Node3D = $Ghost


func _ready() -> void:
	clock = SimClock.new()
	add_child(clock)
	clock.ticked.connect(_on_tick)
	ledger = EconomyLedger.new(Content.rules.start_cash)
	lives = Content.rules.start_lives
	shop.assign(Content.towers)
	shop.sort_custom(func(a: TowerDefinition, b: TowerDefinition) -> bool: return a.price < b.price)
	ghost.visible = false
	_shots_root.name = "Shots"
	add_child(_shots_root)
	_set_state(State.PREPARE)


func _process(_delta: float) -> void:
	if placing:
		var hit: Variant = mouse_ground()
		ghost.visible = hit != null
		if hit != null:
			ghost.position = Vector3(hit.x, 0.0, hit.z)
			ghost.show_ghost(placement_reason(placing, Vector2(hit.x, hit.z)))


## World input only; clicks on HUD controls never reach here (GUI handles them first).
func _unhandled_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key and key.pressed and not key.echo:
		match key.keycode:
			KEY_SPACE:
				start_round()
			KEY_P:
				set_paused(not clock.paused)
			KEY_F:
				toggle_speed()
			KEY_ESCAPE:
				cancel()
			KEY_T:
				cycle_priority(selected)
			_:
				if key.keycode >= KEY_1 and key.keycode < KEY_1 + shop.size():
					begin_placing(shop[key.keycode - KEY_1])
	var click: InputEventMouseButton = event as InputEventMouseButton
	if click and click.pressed:
		if click.button_index == MOUSE_BUTTON_RIGHT:
			cancel()
		elif click.button_index == MOUSE_BUTTON_LEFT:
			var hit: Variant = mouse_ground()
			if hit == null:
				return
			if placing:
				if try_place(placing, Vector2(hit.x, hit.z)):
					cancel()
			elif not collect_at(hit):
				select(tower_at(Vector2(hit.x, hit.z)))


# --- Flow controls (P04-T02). Each one checks the state itself, so repeated clicks are harmless. ---

func is_over() -> bool:
	return state == State.WON or state == State.LOST


func can_start_round() -> bool:
	return state == State.PREPARE and not clock.paused


func start_round() -> bool:
	if not can_start_round():
		return false
	round_index += 1
	_schedule = Content.rounds[round_index].schedule()
	_spawn_cursor = 0
	_round_time = 0.0
	_plan_drops()
	_set_state(State.ROUND_SPAWN)
	Events.send(&"round_started", 0, 0, round_index + 1)
	return true


func set_paused(on: bool) -> void:
	if is_over():
		return
	clock.paused = on
	changed.emit()


func toggle_speed() -> void:
	clock.speed = FAST_SPEED if clock.speed == 1.0 else 1.0
	changed.emit()


## Fresh scene = fresh clock, ledger, towers, snowballs and event connections (P04-T09).
func restart() -> void:
	get_tree().reload_current_scene()


func cycle_priority(tower: Node3D) -> void:
	if is_instance_valid(tower):
		tower.priority = (tower.priority + 1) % Targeting.Priority.size()
		changed.emit()


# --- Simulation tick. Fixed order: spawn -> move -> leaks -> towers fire -> shots hit -> round state. ---

func _on_tick(dt: float) -> void:
	Events.tick = clock.tick
	if is_over():
		return
	if state == State.ROUND_SPAWN:
		_round_time += dt
		while _spawn_cursor < _schedule.size() and _schedule[_spawn_cursor][0] <= _round_time + 1e-6:
			_spawn(_schedule[_spawn_cursor][1])
			_spawn_cursor += 1
		while _drop_cursor < _drops.size() and _drops[_drop_cursor][0] <= _round_time + 1e-6:
			_drop_pickup(_drops[_drop_cursor][1], _drops[_drop_cursor][2])
			_drop_cursor += 1
	for pickup: Pickup in pickups.duplicate():
		pickup.life -= dt
		if pickup.life <= 0.0:
			_remove_pickup(pickup)
			Events.send(&"pickup_expired", pickup.source_id, 0, pickup.value, pickup.pos)
	for snowball: Node3D in snowballs.duplicate():
		snowball.distance += snowball.current_speed() * GameDefinition.UNIT_M * dt
		snowball.slow_left -= dt
		if snowball.distance >= course.length():
			_leak(snowball)
		else:
			snowball.position = course.position_at(snowball.distance)
	_fire_towers(dt)
	_move_shots(dt)
	if lives <= 0:
		lives = 0
		_set_state(State.LOST)
		Events.send(&"match_lost", 0, 0, round_index + 1)
	elif state == State.ROUND_SPAWN and _spawn_cursor == _schedule.size():
		_set_state(State.ROUND_CLEANUP)
	elif state == State.ROUND_CLEANUP and snowballs.is_empty():
		_reward()


func _fire_towers(dt: float) -> void:
	for tower: Node3D in towers_root.get_children():
		for i: int in tower.attacks.size():
			var attack: AttackDefinition = tower.attacks[i]
			tower.cooldowns[i] -= dt
			if tower.cooldowns[i] > 1e-6:
				continue
			var target: Node3D = _pick_target(tower, attack)
			if target == null:
				tower.cooldowns[i] = 0.0  # ready, fires the moment something becomes eligible
				continue
			tower.cooldowns[i] += attack.interval_s
			var dir: Vector3 = target.position - tower.position
			Events.send(&"attack_fired", tower.entity_id, target.entity_id, attack.damage, tower.position, [attack.id])
			if tower.def.global_range:
				_flash(target.position, 0.3)
				_hit(attack, target, {target.entity_id: true}, dir, tower.entity_id)  # instant hit, no projectile
			else:
				# ponytail: aimed at the target's current position (no lead); fine at these projectile speeds.
				_launch(attack, tower.position, dir, {}, tower.entity_id)


## Eligible target for one attack: range (edge contact) or whole map with line of sight, then priority.
func _pick_target(tower: Node3D, attack: AttackDefinition) -> Node3D:
	var range_m: float = tower.range_units * GameDefinition.UNIT_M + HIT_RADIUS_M
	var accept: Callable = Callable()
	if tower.def.global_range:
		range_m = INF
		accept = func(s: Node3D) -> bool: return course.has_line_of_sight(tower.position, s.position)
	elif attack.damage == 0 and attack.slow_factor > 0.0:
		# ponytail: pure wax skips already-waxed snowballs (PROTOTYPE_ASSUMPTION; BTD6 Glue behaviour unverified).
		accept = func(s: Node3D) -> bool: return s.slow_left <= 0.0
	return Targeting.pick(snowballs, tower.position, range_m, tower.priority, attack.detects_camo, accept)


## Creates `attack` at `origin`: a burst hits around it at once; otherwise a volley flies along `dir`,
## `spread_deg` apart and centred on it. Every projectile starts with a copy of `hit` (no double hits).
func _launch(attack: AttackDefinition, origin: Vector3, dir: Vector3, hit: Dictionary[int, bool], source_id: int) -> void:
	if attack.radius_units > 0.0:
		_burst(attack, origin, source_id)
		return
	var heading: float = atan2(dir.x, dir.z)
	for k: int in attack.projectile_count:
		var angle: float = heading + deg_to_rad(attack.spread_deg * (k - (attack.projectile_count - 1) / 2.0))
		var shot: Shot = Shot.new()
		shot.pos = Vector3(origin.x, 0.0, origin.z)
		shot.velocity = Vector3(sin(angle), 0.0, cos(angle)) * attack.projectile_speed_units * GameDefinition.UNIT_M
		shot.life = attack.projectile_lifetime_s
		shot.pierce = attack.pierce
		shot.attack = attack
		shot.source_id = source_id
		shot.hit = hit.duplicate()
		shot.node = MeshInstance3D.new()
		shot.node.mesh = SHOT_MESH
		shot.node.position = shot.pos + Vector3.UP * 0.5
		_shots_root.add_child(shot.node)
		shots.append(shot)


## Instant area hit: up to `pierce` snowballs touching the circle, in spawn order. Explosions ignore camo
## (they do not target) and include the snowball the projectile hit.
func _burst(attack: AttackDefinition, center: Vector3, source_id: int) -> void:
	var radius: float = attack.radius_units * GameDefinition.UNIT_M
	var left: int = attack.pierce
	for s: Node3D in snowballs.duplicate():
		if left <= 0:
			break
		if snowballs.has(s) and Vector2(s.position.x - center.x, s.position.z - center.z).length() <= radius + HIT_RADIUS_M:
			left -= 1
			_apply(attack, s, source_id)
	_flash(center, radius)


## Placeholder hit/explosion flash (presentation only).
func _flash(center: Vector3, radius: float) -> void:
	var flash: MeshInstance3D = MeshInstance3D.new()
	var disc: CylinderMesh = CylinderMesh.new()
	disc.top_radius = radius
	disc.bottom_radius = radius
	disc.height = 0.05
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = BURST_COLOR
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	disc.material = material
	flash.mesh = disc
	flash.position = Vector3(center.x, 0.3, center.z)
	_shots_root.add_child(flash)
	get_tree().create_timer(0.15, false).timeout.connect(flash.queue_free)


## A projectile touches snowball `s`: its own effect, then its contact sub-attacks at the contact point.
func _hit(attack: AttackDefinition, s: Node3D, hit: Dictionary[int, bool], dir: Vector3, source_id: int) -> void:
	var where: Vector3 = s.position
	_apply(attack, s, source_id)
	for sub: AttackDefinition in attack.on_contact:
		_launch(sub, where, dir, hit, source_id)


## Wax status (unless immune to the attack's type), then damage (+ camo bonus) through the single damage path.
func _apply(attack: AttackDefinition, s: Node3D, source_id: int) -> void:
	if attack.slow_factor > 0.0 and StringName("immune_" + attack.damage_type) not in s.def.properties:
		s.apply_slow(attack.slow_factor, attack.slow_duration_s, attack.soaks_layers)
		Events.send(&"status_applied", source_id, s.entity_id, attack.slow_duration_s, s.position, [attack.id])
	var damage: int = attack.damage + (attack.bonus_vs_camo if &"camo" in s.def.properties else 0)
	if damage > 0:
		damage_snowball(s, damage, attack.damage_type, source_id)


## Swept hits along each shot's step, so fast shots cannot tunnel through a snowball.
func _move_shots(dt: float) -> void:
	for shot: Shot in shots.duplicate():
		var from: Vector3 = shot.pos
		shot.pos += shot.velocity * dt
		shot.life -= dt
		for s: Node3D in snowballs.duplicate():
			if shot.pierce <= 0:
				break
			if shot.hit.has(s.entity_id) or not snowballs.has(s):
				continue
			if Geometry3D.get_closest_point_to_segment(s.position, from, shot.pos).distance_to(s.position) > HIT_RADIUS_M:
				continue
			shot.hit[s.entity_id] = true
			shot.pierce -= 1  # an immune contact still uses pierce (BTD6: Lead blocks darts)
			_hit(shot.attack, s, shot.hit, shot.velocity, shot.source_id)
		if shot.pierce <= 0 or shot.life <= 0.0:
			shots.erase(shot)
			shot.node.queue_free()
			for sub: AttackDefinition in shot.attack.on_expire:
				_launch(sub, shot.pos, shot.velocity, shot.hit, shot.source_id)
		else:
			shot.node.position = shot.pos + Vector3.UP * 0.5


## The single damage path (P05-T04, P06-T10): immunity, layer breaks with overflow, pop cash, events.
## Each broken layer pays its cash_per_pop exactly once; the last layer removes the snowball.
func damage_snowball(s: Node3D, damage: int, damage_type: StringName, source_id: int) -> void:
	if StringName("immune_" + damage_type) in s.def.properties:
		Events.send(&"enemy_immune", source_id, s.entity_id, 0, s.position, [damage_type])
		return
	Events.send(&"enemy_hit", source_id, s.entity_id, damage, s.position, [s.def.id])
	while damage > 0:
		damage -= 1
		var old: EnemyDefinition = s.def
		ledger.credit(clock.tick, old.cash_per_pop, &"pop", source_id)
		if old.child_id == &"":
			snowballs.erase(s)
			s.queue_free()
			Events.send(&"layer_broken", source_id, s.entity_id, old.cash_per_pop, s.position, [old.id, ""])
			break
		s.set_layer(Content.enemies[old.child_id])  # 1:1 basic chain: same snowball, next layer
		if not s.slow_soaks:
			s.slow_left = 0.0  # a break sheds ordinary wax; Glue Soak keeps it
		Events.send(&"layer_broken", source_id, s.entity_id, old.cash_per_pop, s.position, [old.id, old.child_id])
	changed.emit()


func _spawn(enemy_id: StringName) -> void:
	var snowball: Node3D = SNOWBALL_SCENE.instantiate()
	snowballs_root.add_child(snowball)
	snowball.setup(Content.enemies[enemy_id], _new_id())
	snowball.position = course.position_at(0.0)
	snowballs.append(snowball)
	Events.send(&"enemy_spawned", snowball.entity_id, 0, 0.0, snowball.position, [enemy_id])


## A snowball reached the finish: lives drop by its RBE exactly once, then it is gone.
func _leak(snowball: Node3D) -> void:
	var damage: int = Content.rbe(snowball.def.id)
	lives -= damage
	snowballs.erase(snowball)
	Events.send(&"enemy_leaked", snowball.entity_id, 0, damage, snowball.position, [snowball.def.id])
	snowball.queue_free()
	changed.emit()


func _reward() -> void:
	_set_state(State.ROUND_REWARD)
	var round_number: int = round_index + 1
	var bonus: int = Content.rules.round_bonus_base + round_number
	ledger.credit(clock.tick, bonus, &"round_bonus", 0)
	Events.send(&"round_complete", 0, 0, bonus, Vector3.ZERO, [str(round_number)])
	if round_index == Content.rounds.size() - 1:
		_set_state(State.WON)
		Events.send(&"match_won", 0, 0, round_number)
	else:
		_set_state(State.PREPARE)


func _set_state(next: State) -> void:
	if next not in TRANSITIONS[state]:
		push_error("Match: illegal transition %s -> %s" % [State.keys()[state], State.keys()[next]])
		return
	print("STATE %s -> %s tick=%d round=%d lives=%d cash=%d" % [State.keys()[state], State.keys()[next],
			clock.tick, round_index + 1, lives, ledger.cash])
	state = next
	if is_over():
		cancel()
	changed.emit()


# --- Ticket Booth income (P08-T06). ---

## Each booth drops its pickups evenly over the round's spawn time.
## ponytail: even spacing is a PROTOTYPE_ASSUMPTION; the source pages give no in-round timing.
func _plan_drops() -> void:
	_drops.clear()
	_drop_cursor = 0
	var duration: float = _schedule[-1][0] if not _schedule.is_empty() else 0.0
	for tower: Node3D in towers_root.get_children():
		for k: int in tower.pickups_per_round:
			_drops.append([duration * (k + 0.5) / tower.pickups_per_round, tower, k])
	_drops.sort_custom(func(a: Array, b: Array) -> bool: return a[0] < b[0] or (a[0] == b[0] and a[1].entity_id < b[1].entity_id))


func _drop_pickup(booth: Node3D, k: int) -> void:
	if not is_instance_valid(booth) or booth.get_parent() != towers_root:
		return  # sold this round
	var pickup: Pickup = Pickup.new()
	var offset: float = booth.footprint().z + 0.3
	pickup.pos = booth.position + Vector3(cos(k * 2.4), 0.0, sin(k * 2.4)) * offset
	pickup.value = booth.cash_per_pickup
	pickup.life = booth.pickup_lifetime_s
	pickup.source_id = booth.entity_id
	pickup.node = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(0.35, 0.2, 0.35)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = PICKUP_COLOR
	material.emission_enabled = true
	material.emission = PICKUP_COLOR * 0.4
	box.material = material
	pickup.node.mesh = box
	pickup.node.position = pickup.pos + Vector3.UP * 0.15
	_shots_root.add_child(pickup.node)
	pickups.append(pickup)
	Events.send(&"pickup_spawned", booth.entity_id, 0, pickup.value, pickup.pos)


## Collects the pickup nearest to `point` within reach. Returns whether one was collected.
func collect_at(point: Vector3) -> bool:
	for pickup: Pickup in pickups:
		if Vector2(pickup.pos.x - point.x, pickup.pos.z - point.z).length() <= PICKUP_RADIUS_M:
			collect(pickup)
			return true
	return false


func collect(pickup: Pickup) -> void:
	if is_over() or pickup not in pickups:
		return
	ledger.credit(clock.tick, pickup.value, &"ticket_income", pickup.source_id)
	_remove_pickup(pickup)
	Events.send(&"income_collected", pickup.source_id, 0, pickup.value, pickup.pos)
	changed.emit()


func _remove_pickup(pickup: Pickup) -> void:
	pickups.erase(pickup)
	pickup.node.queue_free()


# --- Placement and selection (P03). ---

## Cursor ray on the ground plane (Vector3) or null when it misses.
func mouse_ground() -> Variant:
	var mouse: Vector2 = get_viewport().get_mouse_position()
	return GROUND.intersects_ray(camera.project_ray_origin(mouse), camera.project_ray_normal(mouse))


func begin_placing(def: TowerDefinition) -> void:
	if is_over():
		return
	select(null)
	placing = def
	ghost.setup(def, 0)


func cancel() -> void:
	placing = null
	ghost.visible = false
	select(null)


## "" if `def` may be placed at `pos` (XZ) right now, else the reason. Same rule for ghost and purchase.
func placement_reason(def: TowerDefinition, pos: Vector2) -> String:
	if is_over():
		return "Match is over"
	var reason: String = course.check_placement(pos, def.footprint_units * GameDefinition.UNIT_M, _footprints())
	if reason == "" and ledger.cash < def.price:
		reason = "Not enough cash"
	return reason


## The only way a tower enters the match: validates, charges once, spawns. Returns the tower or null.
func try_place(def: TowerDefinition, pos: Vector2) -> Node3D:
	var reason: String = placement_reason(def, pos)
	if reason != "" or not ledger.spend(clock.tick, def.price, &"tower_purchase", _next_id):
		Events.send(&"purchase_failed", 0, 0, def.price, Vector3(pos.x, 0, pos.y), [reason])
		return null
	var tower: Node3D = TOWER_SCENE.instantiate()
	towers_root.add_child(tower)
	tower.setup(def, _new_id())
	tower.position = Vector3(pos.x, 0.0, pos.y)
	Events.send(&"tower_placed", tower.entity_id, 0, def.price, tower.position, [def.id])
	changed.emit()
	return tower


## Upgrade slot state for the HUD (P09-T10); TowerDefinition.can_upgrade stays the authority.
## "max", "soon" (tier not shipped), "locked" (crosspath), "unaffordable" or "ok".
func upgrade_state(tower: Node3D, path: int) -> String:
	var next: UpgradeDefinition = tower.def.get_upgrade(path, tower.tiers[path] + 1)
	if next == null:
		return "max"
	var tiers: Vector3i = tower.tiers
	tiers[path] += 1
	if not TowerDefinition.is_legal_crosspath(tiers):
		return "locked"
	if not next.is_available():
		return "soon"
	return "ok" if ledger.cash >= next.price else "unaffordable"


## The only way a tower gains a tier: legality + cash checked, charged once, stats rebuilt (P09-T04).
func buy_upgrade(tower: Node3D, path: int) -> bool:
	if is_over() or not is_instance_valid(tower) or not tower.def.can_upgrade(tower.tiers, path):
		return false
	var next: UpgradeDefinition = tower.def.get_upgrade(path, tower.tiers[path] + 1)
	if not ledger.spend(clock.tick, next.price, &"upgrade", tower.entity_id):
		Events.send(&"purchase_failed", tower.entity_id, 0, next.price, tower.position, ["Not enough cash"])
		return false
	tower.tiers[path] += 1
	tower.spent += next.price
	tower.rebuild_stats()
	Events.send(&"tower_upgraded", tower.entity_id, 0, next.price, tower.position, [next.id])
	changed.emit()
	return true


func sell_value(tower: Node3D) -> int:
	return roundi(tower.spent * Content.rules.sell_ratio)


func sell(tower: Node3D) -> void:
	if is_over() or not is_instance_valid(tower):
		return
	var value: int = sell_value(tower)
	ledger.credit(clock.tick, value, &"tower_sale", tower.entity_id)
	Events.send(&"tower_sold", tower.entity_id, 0, value, tower.position)
	if tower == selected:
		select(null)
	towers_root.remove_child(tower)  # out of footprint checks immediately
	tower.queue_free()
	changed.emit()


func tower_at(pos: Vector2) -> Node3D:
	for tower: Node3D in towers_root.get_children():
		var f: Vector3 = tower.footprint()
		if pos.distance_to(Vector2(f.x, f.y)) <= f.z:
			return tower
	return null


func select(tower: Node3D) -> void:
	if is_instance_valid(selected):
		selected.set_selected(false)
	selected = tower
	if tower:
		tower.set_selected(true)
	changed.emit()


func _footprints() -> Array[Vector3]:
	var out: Array[Vector3] = []
	for tower: Node3D in towers_root.get_children():
		out.append(tower.footprint())
	return out


func _new_id() -> int:
	_next_id += 1
	return _next_id - 1
