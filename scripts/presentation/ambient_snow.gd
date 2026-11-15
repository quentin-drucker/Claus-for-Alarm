extends Node3D
## Ambient winter motion (P17-T07 slice): gentle snowfall over the whole course plus, every few seconds, a gust that
## rolls a spiral ribbon of flakes across the map. Cosmetic only: never touches the simulation, runs in real time
## (keeps falling while paused), and the shader animates every flake, so the per-frame cost is one uniform update.
## Flakes stay tiny and translucent so they never read as snowballs. Reduced motion: lighter snowfall, no gusts.

const SHADER: Shader = preload("res://assets/materials/ambient_snow.gdshader")

@export var flake_count: int = 700
@export var gust_flakes: int = 220
@export var gust_interval_s: Vector2 = Vector2(6.0, 13.0)
@export var gust_life_s: float = 2.8
## Snowfall volume (world metres); matches the shader defaults and covers the orthographic view around the course.
@export var box: AABB = AABB(Vector3(-27.0, 0.0, -22.0), Vector3(54.0, 13.0, 40.0))

var _gust_material: ShaderMaterial
var _gust_node: MultiMeshInstance3D
var _gust_age_s: float = INF
var _next_gust_s: float = 3.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()  # cosmetic: deliberately not the simulation's seeded RNG
	var reduced: bool = LodgeTheme.reduced_motion()
	var fall: ShaderMaterial = _material(false)
	if reduced:
		fall.set_shader_parameter(&"fall_speed", 0.5)
	var flakes: Array[Color] = []
	for i: int in (flake_count / 2 if reduced else flake_count):
		var p: Vector3 = box.position + Vector3(_rng.randf(), _rng.randf(), _rng.randf()) * box.size
		flakes.append(Color(p.x, p.y, p.z, _rng.randf()))
	add_child(_layer(flakes, fall, box))
	if reduced:
		set_process(false)
		return
	_gust_material = _material(true)
	var ribbon: Array[Color] = []
	for i: int in gust_flakes:
		ribbon.append(Color(_rng.randf(), _rng.randf() * TAU, _rng.randf_range(0.5, 1.1), _rng.randf()))
	_gust_node = _layer(ribbon, _gust_material, box.grow(10.0))
	_gust_node.visible = false
	add_child(_gust_node)


func _process(delta: float) -> void:
	_next_gust_s -= delta
	if _next_gust_s <= 0.0 and _gust_age_s >= gust_life_s:
		_start_gust()
	if _gust_age_s < gust_life_s:
		_gust_age_s += delta
		_gust_material.set_shader_parameter(&"gust_age", minf(_gust_age_s / gust_life_s, 1.0))
		_gust_node.visible = _gust_age_s < gust_life_s


## A gust enters from a random point on a ring around the course and crosses it toward the opposite side.
func _start_gust() -> void:
	var heading: float = _rng.randf() * TAU
	var dir: Vector2 = Vector2.from_angle(heading)
	var centre: Vector3 = box.get_center()
	var start: Vector3 = Vector3(centre.x - dir.x * 16.0, 0.0, centre.z - dir.y * 11.0)
	_gust_material.set_shader_parameter(&"gust_start", start)
	_gust_material.set_shader_parameter(&"gust_dir", dir)
	_gust_material.set_shader_parameter(&"gust_age", 0.0)
	_gust_material.set_shader_parameter(&"gust_phase", _rng.randf() * TAU)
	_gust_age_s = 0.0
	_gust_node.visible = true
	_next_gust_s = _rng.randf_range(gust_interval_s.x, gust_interval_s.y)


func _material(is_gust: bool) -> ShaderMaterial:
	var m: ShaderMaterial = ShaderMaterial.new()
	m.shader = SHADER
	m.set_shader_parameter(&"gust", is_gust)
	m.set_shader_parameter(&"box_min", box.position)
	m.set_shader_parameter(&"box_max", box.end)
	return m


## One MultiMesh = one draw call. Per-flake data rides in custom data; transforms stay identity, so cull by `aabb`.
func _layer(data: Array[Color], material: ShaderMaterial, aabb: AABB) -> MultiMeshInstance3D:
	var quad: QuadMesh = QuadMesh.new()
	quad.material = material
	var mm: MultiMesh = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	mm.mesh = quad
	mm.instance_count = data.size()
	mm.custom_aabb = aabb
	for i: int in data.size():
		mm.set_instance_custom_data(i, data[i])
	var node: MultiMeshInstance3D = MultiMeshInstance3D.new()
	node.multimesh = mm
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return node
