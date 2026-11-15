extends Node3D
## First-use warm-up PROBE (Dev 11, measurement tool, not shipped): draws one of every gameplay visual (tower models
## with puffs/rings, the placement-ghost look, every snowball type, shot, flash, ticket, text) once, near-zero size in
## the camera view, one group per frame, and records each group's first-draw frame time (`group_ms`). Used by
## stress.gd `-- probe warm`. Never touches the simulation (nothing joins towers_root/snowballs; no ledger/RNG/clock/
## round/audio calls). Result (p15e_stutter_web.txt): it removes the gameplay stalls but costs 2-3x their time.

signal finished

## Frames to keep the last group on screen before freeing.
const FRAMES: int = 2
## World size of the warm-up group (metres): small enough to be invisible at the game camera, still rasterised.
const SIZE: float = 0.002

var _left: int = FRAMES
## Visual groups still to add, one per frame (so a probe can time each group's first draw).
var _groups: Array[Callable] = []
var _m: Node3D
var _x: float = 0.0
## Group names in order; `group_ms` gets the frame time measured after each group was added.
var group_names: Array[String] = []
var group_ms: Array[float] = []
var _t: int = 0
var _added: int = 0


## Builds the warm-up set under this node; `m` is the match (read only: its camera, scenes and Content data).
func prime(m: Node3D, groups: Array[String] = ["towers", "ghosts", "snowballs", "misc"]) -> void:
	_m = m
	var cam: Camera3D = m.camera
	var fwd: Vector3 = -cam.global_transform.basis.z
	position = cam.global_position + fwd * (-cam.global_position.y / fwd.y)  # ground point at the screen centre
	scale = Vector3.ONE * SIZE
	group_names = groups
	for g: String in groups:
		_groups.append(Callable(self, "_add_" + g))
	_t = Time.get_ticks_usec()


func _add_towers(ghost: bool = false) -> void:
	var defs: Array = Content.towers.duplicate()
	defs.append(Content.hero)
	for def: TowerDefinition in defs:
		var t: Node3D = _m.TOWER_SCENE.instantiate()
		add_child(t)
		t.position.x = _x
		_x += 2.0
		t.setup(def, 0)
		if ghost:
			t.show_ghost("")
		for fx: Node in t.find_children("*", "MeshInstance3D", true, false):
			(fx as MeshInstance3D).visible = true  # muzzle puffs, hero rings, glint, lens


func _add_ghosts() -> void:
	_add_towers(true)


func _add_snowballs() -> void:
	for id: StringName in Content.enemies:
		var s: Node3D = _m.SNOWBALL_SCENE.instantiate()
		add_child(s)
		s.set_layer(Content.enemies[id])
		s.position.x = _x
		_x += 1.0


func _add_misc() -> void:
	var shot: MeshInstance3D = MeshInstance3D.new()
	shot.mesh = _m.SHOT_MESH
	add_child(shot)
	for color: Color in [_m.BURST_COLOR, _m.PICKUP_COLOR]:
		var box: MeshInstance3D = MeshInstance3D.new()
		box.mesh = BoxMesh.new()
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = color
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		if color == _m.PICKUP_COLOR:  # ticket material (match._drop_pickup)
			material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
			material.emission_enabled = true
			material.no_depth_test = true
		box.mesh.material = material
		add_child(box)
	var text: Label3D = Label3D.new()
	text.text = "IMMUNE -5 lives Level 4! $0123456789"
	add_child(text)


func _process(_delta: float) -> void:
	var now: int = Time.get_ticks_usec()
	if group_ms.size() < _added:  # this frame's time includes drawing the group added last frame
		group_ms.append((now - _t) / 1000.0)
	_t = now
	if _added < _groups.size():
		_groups[_added].call()
		_added += 1
		return
	_left -= 1
	if _left <= 0:
		finished.emit()
		queue_free()
