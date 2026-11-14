extends Node3D
## Match scene: owns the simulation clock, ledger, towers and snowballs. All rule checks live here or in
## scripts/core; the HUD and meshes only display state.

const GROUND: Plane = Plane(Vector3.UP, 0.0)
const TOWER_SCENE: PackedScene = preload("res://scenes/towers/tower.tscn")

## Shop order: cheapest first; keys 1-6 pick these.
var shop: Array[TowerDefinition] = []
var clock: SimClock
var ledger: EconomyLedger
var lives: int = 0
## Tower type being placed (null = not placing).
var placing: TowerDefinition
var selected: Node3D
var _next_id: int = 1

@onready var course: Node3D = $SkiCircuit
@onready var camera: Camera3D = $Camera3D
@onready var towers_root: Node3D = $Towers
@onready var ghost: Node3D = $Ghost


func _ready() -> void:
	clock = SimClock.new()
	add_child(clock)
	ledger = EconomyLedger.new(Content.rules.start_cash)
	lives = Content.rules.start_lives
	shop.assign(Content.towers)
	shop.sort_custom(func(a: TowerDefinition, b: TowerDefinition) -> bool: return a.price < b.price)
	ghost.visible = false


func _process(_delta: float) -> void:
	if placing:
		var hit: Variant = mouse_ground()
		ghost.visible = hit != null
		if hit != null:
			ghost.position = Vector3(hit.x, 0.0, hit.z)
			ghost.show_ghost(placement_reason(placing, Vector2(hit.x, hit.z)))


func _unhandled_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key and key.pressed and not key.echo:
		if key.keycode >= KEY_1 and key.keycode < KEY_1 + shop.size():
			begin_placing(shop[key.keycode - KEY_1])
		elif key.keycode == KEY_ESCAPE:
			cancel()
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


## Cursor ray on the ground plane (Vector3) or null when it misses.
func mouse_ground() -> Variant:
	var mouse: Vector2 = get_viewport().get_mouse_position()
	return GROUND.intersects_ray(camera.project_ray_origin(mouse), camera.project_ray_normal(mouse))


func begin_placing(def: TowerDefinition) -> void:
	select(null)
	placing = def
	ghost.setup(def, 0)


func cancel() -> void:
	placing = null
	ghost.visible = false
	select(null)


## "" if `def` may be placed at `pos` (XZ) right now, else the reason. Same rule for ghost and purchase.
func placement_reason(def: TowerDefinition, pos: Vector2) -> String:
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
	tower.setup(def, _next_id)
	_next_id += 1
	tower.position = Vector3(pos.x, 0.0, pos.y)
	Events.send(&"tower_placed", tower.entity_id, 0, def.price, tower.position, [def.id])
	return tower


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


func _footprints() -> Array[Vector3]:
	var out: Array[Vector3] = []
	for tower: Node3D in towers_root.get_children():
		out.append(tower.footprint())
	return out
