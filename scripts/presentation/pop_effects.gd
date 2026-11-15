extends Node3D
## Layer-break feedback (P16-T09 / P17-T02 slice, Dev 12): a short puff + ground ring in the broken layer's colour.
## Presentation only: listens to Events `layer_broken`, never touches the simulation. A fixed pool (POOL slots, oldest
## reused) keeps late 4x rounds cheap; it advances from the match tick (pause and 1x/2x/4x apply).

const POOL: int = 32
const LIFE_S: float = 0.28
## Dev 13: icy shards thrown out of each pop (one MultiMesh for the whole pool = one draw call).
const SHARDS: int = 5
const SHARD_LIFE_S: float = 0.42
const SNOWBALL: Script = preload("res://scenes/enemies/snowball.gd")

var _puffs: Array[MeshInstance3D] = []
var _rings: Array[MeshInstance3D] = []
var _age: Array[float] = []
var _next: int = 0
var _materials: Dictionary[Color, StandardMaterial3D] = {}
var _shards: MultiMesh = MultiMesh.new()
var _origin: Array[Vector3] = []


func _ready() -> void:
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 1.0
	sphere.radial_segments = 10
	sphere.rings = 5
	var ring: TorusMesh = TorusMesh.new()
	ring.inner_radius = 0.42
	ring.outer_radius = 0.5
	ring.rings = 24
	ring.ring_segments = 4
	for i: int in POOL:
		for pair: Array in [[sphere, _puffs], [ring, _rings]]:
			var node: MeshInstance3D = MeshInstance3D.new()
			node.mesh = pair[0]
			node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			node.visible = false
			add_child(node)
			pair[1].append(node)
		_age.append(INF)
		_origin.append(Vector3.ZERO)
	var shard: BoxMesh = BoxMesh.new()
	shard.size = Vector3(0.11, 0.11, 0.11)
	var shard_material: StandardMaterial3D = StandardMaterial3D.new()
	shard_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shard_material.vertex_color_use_as_albedo = true
	shard.material = shard_material
	_shards.transform_format = MultiMesh.TRANSFORM_3D
	_shards.use_colors = true
	_shards.mesh = shard
	_shards.instance_count = POOL * SHARDS
	for j: int in _shards.instance_count:
		_shards.set_instance_transform(j, Transform3D(Basis.from_scale(Vector3.ZERO), Vector3.ZERO))
	var shards_node: MultiMeshInstance3D = MultiMeshInstance3D.new()
	shards_node.multimesh = _shards
	shards_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(shards_node)
	Events.emitted.connect(_on_event)


func _on_event(e: GameEvent) -> void:
	if e.type != &"layer_broken" or e.tags.is_empty():
		return
	var base: StringName = StringName(String(e.tags[0]).trim_prefix("camo_"))
	var color: Color = SNOWBALL.COLORS.get(base, Color.WHITE)
	var i: int = _next
	_next = (_next + 1) % POOL
	_age[i] = 0.0
	var material: StandardMaterial3D = _material(color)
	_puffs[i].material_override = material
	_rings[i].material_override = material
	_puffs[i].position = e.position + Vector3.UP * 0.45
	_rings[i].position = e.position + Vector3.UP * 0.05
	_origin[i] = e.position + Vector3.UP * 0.45
	for j: int in SHARDS:
		_shards.set_instance_color(i * SHARDS + j, color.lightened(0.45) if j % 2 == 0 else Color("eaf6ff"))
	_pose(i)


## Called by the match every simulation tick.
func advance(dt: float) -> void:
	for i: int in POOL:
		if _age[i] != INF:
			_age[i] += dt
			_pose(i)


func _pose(i: int) -> void:
	_pose_shards(i)
	var u: float = _age[i] / LIFE_S
	var on: bool = u < 1.0
	_puffs[i].visible = on
	_rings[i].visible = on
	if not on:
		if _age[i] >= SHARD_LIFE_S:
			_age[i] = INF
		return
	var k: float = 1.0 - (1.0 - u) * (1.0 - u)
	_puffs[i].scale = Vector3.ONE * (0.7 + 0.5 * k)
	_puffs[i].transparency = 0.3 + 0.7 * u
	_rings[i].scale = Vector3(0.8 + 1.0 * k, 0.2, 0.8 + 1.0 * k)
	_rings[i].transparency = 0.2 + 0.8 * u


## Shards fly out on fixed per-slot directions (no RNG), arc under gravity, spin and shrink.
func _pose_shards(i: int) -> void:
	var t: float = _age[i]
	for j: int in SHARDS:
		var index: int = i * SHARDS + j
		if t >= SHARD_LIFE_S:
			_shards.set_instance_transform(index, Transform3D(Basis.from_scale(Vector3.ZERO), Vector3.ZERO))
			continue
		var a: float = TAU * (j + 0.37 * i) / SHARDS
		var dir: Vector3 = Vector3(cos(a), 0.0, sin(a))
		var pos: Vector3 = _origin[i] + dir * (2.2 * t) + Vector3.UP * (2.4 * t - 6.0 * t * t)
		var size: float = 1.0 - t / SHARD_LIFE_S
		_shards.set_instance_transform(index, Transform3D(Basis(dir.cross(Vector3.UP), t * 14.0).scaled(Vector3.ONE * size), pos))


func _material(color: Color) -> StandardMaterial3D:
	if not _materials.has(color):
		var m: StandardMaterial3D = StandardMaterial3D.new()
		m.albedo_color = color.lightened(0.15)
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_materials[color] = m
	return _materials[color]
