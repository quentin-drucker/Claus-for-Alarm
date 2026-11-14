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
## Tower type being placed (null = not placing).
var placing: TowerDefinition
var selected: Node3D
var _next_id: int = 1
var _schedule: Array = []
var _spawn_cursor: int = 0
var _round_time: float = 0.0

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
			else:
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


# --- Simulation tick. Fixed order: spawn -> move -> leaks -> round state. ---

func _on_tick(dt: float) -> void:
	Events.tick = clock.tick
	if is_over():
		return
	if state == State.ROUND_SPAWN:
		_round_time += dt
		while _spawn_cursor < _schedule.size() and _schedule[_spawn_cursor][0] <= _round_time + 1e-6:
			_spawn(_schedule[_spawn_cursor][1])
			_spawn_cursor += 1
	for snowball: Node3D in snowballs.duplicate():
		snowball.distance += snowball.def.speed_units * GameDefinition.UNIT_M * dt
		if snowball.distance >= course.length():
			_leak(snowball)
		else:
			snowball.position = course.position_at(snowball.distance)
	if lives <= 0:
		lives = 0
		_set_state(State.LOST)
		Events.send(&"match_lost", 0, 0, round_index + 1)
	elif state == State.ROUND_SPAWN and _spawn_cursor == _schedule.size():
		_set_state(State.ROUND_CLEANUP)
	elif state == State.ROUND_CLEANUP and snowballs.is_empty():
		_reward()


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
