extends Node3D
## Course dressing (P16-T11/T12 slice, Dev 12): cosmetic only. Built from the parent SkiCircuit's locked data at load
## (waypoints, bounds, track width, blocker boxes), so it can never drift from the simulation. Nothing here joins
## `Blockers`: placement and line of sight are unchanged. Luma order snow > stone/wood > track (ART_STYLE).
## Repeated props (pines, fence posts, flags) are MultiMeshes; colours are A-01/ART_STYLE tokens.

const SNOW: Color = Color("eef6fa")
const BERM: Color = Color("fbfdff")
const GROOVE: Color = Color("9aaec0")
const SNOW_FAR: Color = Color("d9e7ef")
const PINE: Color = Color("1f5a4a")
const PINE_DARK: Color = Color("173f36")
const TRUNK: Color = Color("6b4a35")
const WOOD: Color = Color("a8795a")
const RED: Color = Color("c73e49")
const GOLD: Color = Color("f9c96d")
const ICE: Color = Color("a9d6e8")
const SEED: int = 20261115

var _course: Node3D
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()  # local, fixed seed: never the global RNG
var _materials: Dictionary[Color, StandardMaterial3D] = {}


func _ready() -> void:
	_course = get_parent()
	_rng.seed = SEED
	var pts: PackedVector3Array = PackedVector3Array()
	for marker: Node in _course.get_node("Waypoints").get_children():
		pts.append((marker as Node3D).position)
	var hw: float = _course.track_half_width
	(_course.get_node("Backdrop") as MeshInstance3D).material_override = _mat(SNOW_FAR, 1.0)
	(_course.get_node("Ground") as MeshInstance3D).material_override = _mat(SNOW, 1.0)
	# Groomed track: raised snow berms on both edges, corduroy grooves down the lane.
	for side: float in [-1.0, 1.0]:
		_strip(_offset_line(pts, side * (hw + 0.16)), 0.32, 0.12, BERM)
	_strip(_offset_line(pts, 0.0), 0.05, 0.05, GROOVE)
	_gate(pts[0].lerp(pts[1], 1.0 / pts[0].distance_to(pts[1])), pts[1] - pts[0], hw, "START")
	_gate(pts[-1].lerp(pts[-2], 1.0 / pts[-1].distance_to(pts[-2])), pts[-1] - pts[-2], hw, "FINISH")
	_flags(pts, hw)
	_rink(_course.get_node("Blockers/Pond") as MeshInstance3D)
	var bounds: Rect2 = _course.bounds
	_fence(bounds)
	_pines(bounds, pts)
	_skis(Vector3(bounds.position.x + 0.8, 0.0, pts[0].z + hw + 1.2))


func _mat(color: Color, roughness: float = 0.85) -> StandardMaterial3D:
	if not _materials.has(color):
		var m: StandardMaterial3D = StandardMaterial3D.new()
		m.albedo_color = color
		m.roughness = roughness
		_materials[color] = m
	return _materials[color]


func _box(size: Vector3, pos: Vector3, yaw: float, color: Color) -> MeshInstance3D:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	mesh.material = _mat(color)
	var node: MeshInstance3D = MeshInstance3D.new()
	node.mesh = mesh
	node.position = pos
	node.rotation.y = yaw
	add_child(node)
	return node


## Centre line offset sideways by `d` (left of travel = +), mitred at the right-angle corners; ends run to the map edge.
func _offset_line(pts: PackedVector3Array, d: float) -> PackedVector3Array:
	var out: PackedVector3Array = PackedVector3Array()
	for i: int in pts.size():
		var n: Vector3 = Vector3.ZERO
		if i > 0:
			n += _normal(pts[i - 1], pts[i])
		if i < pts.size() - 1:
			n += _normal(pts[i], pts[i + 1])
		if i > 0 and i < pts.size() - 1:
			out.append(pts[i] + n * d)  # 90-degree corners: n1 + n2 is the exact mitre offset
		else:
			out.append(pts[i] + n.normalized() * d)
	return out


func _normal(a: Vector3, b: Vector3) -> Vector3:
	var t: Vector3 = (b - a).normalized()
	return Vector3(-t.z, 0.0, t.x)


func _strip(line: PackedVector3Array, width: float, height: float, color: Color) -> void:
	for i: int in line.size() - 1:
		var a: Vector3 = line[i]
		var b: Vector3 = line[i + 1]
		_box(Vector3(width, height, a.distance_to(b) + width), (a + b) / 2.0 + Vector3.UP * height / 2.0,
				atan2(b.x - a.x, b.z - a.z), color)


## Arch over the track: two red posts, a white banner with a gold trim, centred at `at`, facing along `dir`.
func _gate(at: Vector3, dir: Vector3, hw: float, _name: String) -> void:
	var yaw: float = atan2(dir.x, dir.z)
	var side: Vector3 = _normal(Vector3.ZERO, dir) * (hw + 0.45)
	for s: float in [-1.0, 1.0]:
		_box(Vector3(0.22, 2.6, 0.22), at + side * s + Vector3.UP * 1.3, yaw, RED)
	_box(Vector3((hw + 0.45) * 2.0 + 0.3, 0.5, 0.12), at + Vector3.UP * 2.45, yaw + PI / 2.0, BERM)
	_box(Vector3((hw + 0.45) * 2.0 + 0.3, 0.1, 0.14), at + Vector3.UP * 2.2, yaw + PI / 2.0, GOLD)


## Slalom flags on the outside of each bend, just past the berm.
func _flags(pts: PackedVector3Array, hw: float) -> void:
	var xforms: Array[Transform3D] = []
	for i: int in range(1, pts.size() - 1):
		var outer: Vector3 = -(_normal(pts[i - 1], pts[i]) + _normal(pts[i], pts[i + 1]))
		var turn: float = _normal(pts[i - 1], pts[i]).dot(pts[i + 1] - pts[i])
		if turn < 0.0:
			outer = -outer
		xforms.append(Transform3D(Basis(), pts[i] + outer * (hw + 0.45)))
	var pole: CylinderMesh = CylinderMesh.new()
	pole.top_radius = 0.03
	pole.bottom_radius = 0.03
	pole.height = 1.2
	pole.material = _mat(BERM)
	_multi(pole, xforms, Vector3.UP * 0.6)
	var flag: BoxMesh = BoxMesh.new()
	flag.size = Vector3(0.45, 0.32, 0.03)
	flag.material = _mat(RED)
	_multi(flag, xforms, Vector3(0.24, 1.0, 0.0))


## The Pond blocker becomes a frozen rink: ice top, white boards with a red stripe, two curling stones.
func _rink(pond: MeshInstance3D) -> void:
	var ice: StandardMaterial3D = _mat(ICE, 0.15)
	pond.material_override = ice
	var size: Vector3 = (pond.mesh as BoxMesh).size
	var c: Vector3 = Vector3(pond.position.x, 0.0, pond.position.z)
	for k: int in 4:
		var horizontal: bool = k < 2
		var s: float = -1.0 if k % 2 == 0 else 1.0
		var length: float = (size.x if horizontal else size.z) + 0.2
		var offset: Vector3 = Vector3(0, 0, s * (size.z / 2.0 + 0.05)) if horizontal else Vector3(s * (size.x / 2.0 + 0.05), 0, 0)
		var yaw: float = PI / 2.0 if horizontal else 0.0
		_box(Vector3(0.1, 0.3, length), c + offset + Vector3.UP * 0.15, yaw, BERM)
		_box(Vector3(0.11, 0.06, length), c + offset + Vector3.UP * 0.24, yaw, RED)
	for stone: Array in [[Vector3(-0.6, 0, 0.4), RED], [Vector3(0.5, 0, -0.5), GOLD]]:
		var body: CylinderMesh = CylinderMesh.new()
		body.top_radius = 0.16
		body.bottom_radius = 0.2
		body.height = 0.14
		body.material = _mat(Color("6d7680"))
		var node: MeshInstance3D = MeshInstance3D.new()
		node.mesh = body
		node.position = c + stone[0] + Vector3.UP * 0.13
		add_child(node)
		_box(Vector3(0.22, 0.05, 0.06), node.position + Vector3.UP * 0.09, 0.0, stone[1])


## Low split-rail snow fence just outside the long edges of the buildable ground.
func _fence(b: Rect2) -> void:
	var posts: Array[Transform3D] = []
	for z: float in [b.position.y - 0.4, b.end.y + 0.4]:
		var x: float = b.position.x
		while x <= b.end.x + 0.01:
			posts.append(Transform3D(Basis(), Vector3(x, 0.0, z)))
			x += 2.0
		for h: float in [0.35, 0.65]:
			_box(Vector3(b.size.x, 0.07, 0.07), Vector3(b.get_center().x, h, z), 0.0, WOOD)
	var post: BoxMesh = BoxMesh.new()
	post.size = Vector3(0.12, 0.85, 0.12)
	post.material = _mat(WOOD)
	_multi(post, posts, Vector3.UP * 0.42)


## Pine clusters in the margins around the buildable ground (never inside it): three snow-dusted tiers + trunk.
func _pines(b: Rect2, pts: PackedVector3Array) -> void:
	var xforms: Array[Transform3D] = []
	var areas: Array[Rect2] = [Rect2(b.position.x - 9, b.position.y - 6, 8, b.size.y + 12),
			Rect2(b.end.x + 1, b.position.y - 6, 8, b.size.y + 12),
			Rect2(b.position.x, b.position.y - 6, b.size.x, 4.6), Rect2(b.position.x, b.end.y + 1.4, b.size.x, 4.6)]
	for area: Rect2 in areas:
		var count: int = int(area.get_area() / 9.0)
		for k: int in count:
			var p: Vector3 = Vector3(_rng.randf_range(area.position.x, area.end.x), 0.0,
					_rng.randf_range(area.position.y, area.end.y))
			if _near_track(Vector2(p.x, p.z), pts, 3.2):
				continue  # keep the entry/exit lanes beyond the map edge open
			var s: float = _rng.randf_range(0.8, 1.35)
			xforms.append(Transform3D(Basis(Vector3.UP, _rng.randf() * TAU).scaled(Vector3.ONE * s), p))
	var trunk: CylinderMesh = CylinderMesh.new()
	trunk.top_radius = 0.12
	trunk.bottom_radius = 0.16
	trunk.height = 0.6
	trunk.material = _mat(TRUNK)
	_multi(trunk, xforms, Vector3.UP * 0.3)
	for tier: Array in [[1.1, 1.3, 0.55, PINE_DARK], [0.85, 1.1, 1.25, PINE], [0.55, 0.95, 1.85, PINE], [0.3, 0.45, 2.45, BERM]]:
		var cone: CylinderMesh = CylinderMesh.new()
		cone.top_radius = 0.0
		cone.bottom_radius = tier[0]
		cone.height = tier[1]
		cone.radial_segments = 8
		cone.material = _mat(tier[3])
		_multi(cone, xforms, Vector3.UP * (tier[2] + tier[1] / 2.0 - 0.2))


func _near_track(p: Vector2, pts: PackedVector3Array, r: float) -> bool:
	for i: int in pts.size() - 1:
		var q: Vector2 = Geometry2D.get_closest_point_to_segment(p, Vector2(pts[i].x, pts[i].z), Vector2(pts[i + 1].x, pts[i + 1].z))
		if p.distance_to(q) < r:
			return true
	return false


## Crossed skis and poles stuck in the snow by the start.
func _skis(at: Vector3) -> void:
	for k: int in 2:
		var ski: MeshInstance3D = _box(Vector3(0.1, 1.5, 0.03), at + Vector3(k * 0.12, 0.7, 0.0), 0.0, RED if k == 0 else Color("20517a"))
		ski.rotation.z = 0.25 if k == 0 else -0.25
	for k: int in 2:
		var pole: MeshInstance3D = _box(Vector3(0.03, 1.2, 0.03), at + Vector3(0.55 + k * 0.15, 0.55, 0.1), 0.0, Color("2b2f36"))
		pole.rotation.z = 0.15 if k == 0 else -0.15


func _multi(mesh: Mesh, xforms: Array[Transform3D], local_offset: Vector3) -> void:
	var mm: MultiMesh = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = xforms.size()
	for i: int in xforms.size():
		var x: Transform3D = xforms[i]
		mm.set_instance_transform(i, Transform3D(x.basis, x.origin + x.basis * local_offset))
	var node: MultiMeshInstance3D = MultiMeshInstance3D.new()
	node.multimesh = mm
	add_child(node)
