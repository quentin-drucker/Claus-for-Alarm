extends Node3D
## Course dressing (P16-T11/T12 slice, Dev 12): cosmetic only. Built from the parent SkiCircuit's locked data at load
## (waypoints, bounds, track width, blocker boxes), so it can never drift from the simulation. Nothing here joins
## `Blockers`: placement and line of sight are unchanged. Luma order snow > stone/wood > track (ART_STYLE).
## Repeated props (pines, fence posts, flags) are MultiMeshes; colours are A-01/ART_STYLE tokens.

const SNOW: Color = Color("eef6fa")
const BERM: Color = Color("fbfdff")
const SNOW_FAR: Color = Color("d9e7ef")
const PINE: Color = Color("1f5a4a")
const PINE_DARK: Color = Color("173f36")
const TRUNK: Color = Color("6b4a35")
const WOOD: Color = Color("a8795a")
const RED: Color = Color("c73e49")
const GOLD: Color = Color("f9c96d")
const ICE: Color = Color("a9d6e8")
const SEED: int = 20261115
const SNOW_SHADER: Shader = preload("res://assets/materials/snow.gdshader")
const TRACK_SHADER: Shader = preload("res://assets/materials/track.gdshader")
const ICE_SHADER: Shader = preload("res://assets/materials/ice.gdshader")
const DETAIL: Texture2D = preload("res://assets/textures/terrain/snow_detail.png")

var _course: Node3D
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()  # local, fixed seed: never the global RNG
var _materials: Dictionary[Color, StandardMaterial3D] = {}
var _snow: ShaderMaterial


func _ready() -> void:
	_course = get_parent()
	_rng.seed = SEED
	var pts: PackedVector3Array = PackedVector3Array()
	for marker: Node in _course.get_node("Waypoints").get_children():
		pts.append((marker as Node3D).position)
	var hw: float = _course.track_half_width
	_snow = ShaderMaterial.new()
	_snow.shader = SNOW_SHADER
	_snow.set_shader_parameter(&"detail", DETAIL)
	(_course.get_node("Backdrop") as MeshInstance3D).material_override = _snow
	(_course.get_node("Ground") as MeshInstance3D).material_override = _snow
	# Groomed trail (Dev 13): one ribbon whose outer corners are arcs of radius hw about each waypoint and whose inner
	# corners are sharp: exactly the capsule-union track that Placement blocks, and the snowballs' centre line stays
	# hw inside it everywhere. Ends run past the map edge. Irregular snow banks follow both edges.
	var route: PackedVector3Array = pts.duplicate()
	route[0] += (pts[0] - pts[1]).normalized() * 3.0
	route[-1] += (pts[-1] - pts[-2]).normalized() * 3.0
	var track: ShaderMaterial = ShaderMaterial.new()
	track.shader = TRACK_SHADER
	track.set_shader_parameter(&"detail", DETAIL)
	for side: float in [-1.0, 1.0]:
		_ribbon(route, side, PackedFloat32Array([0.0, hw]), PackedFloat32Array([0.035, 0.035]), track, 0.0)
		_ribbon(route, side, PackedFloat32Array([hw - 0.02, hw + 0.12, hw + 0.32, hw + 0.55]),
				PackedFloat32Array([0.03, 0.16, 0.13, 0.0]), _snow, 0.07)
	_gate(pts[0].lerp(pts[1], 1.0 / pts[0].distance_to(pts[1])), pts[1] - pts[0], hw, "START")
	_gate(pts[-1].lerp(pts[-2], 1.0 / pts[-1].distance_to(pts[-2])), pts[-1] - pts[-2], hw, "FINISH")
	_flags(pts, hw)
	_rink(_course.get_node("Blockers/Pond") as MeshInstance3D)
	var bounds: Rect2 = _course.bounds
	_fence(bounds)
	_pines(bounds, pts)
	_skis(Vector3(bounds.position.x + 0.8, 0.0, pts[0].z + hw + 1.2))


## Ribbon on one `side` of the route (+1 left of travel) through cross-section offsets `d` (m from the centre line)
## at heights `h`; heights above 5 cm get +-`jitter` noise along the route (banks). Straights are sampled every
## 0.5 m; an outer corner sweeps an arc about the waypoint, an inner corner meets at the mitre. UV: x across
## (0 centre -> 1 outer edge, for the trail shader), y = metres along the route.
func _ribbon(pts: PackedVector3Array, side: float, d: PackedFloat32Array, h: PackedFloat32Array, material: Material,
		jitter: float) -> void:
	var sections: Array = []  # [base points (one per offset), v]
	var v: float = 0.0
	for i: int in pts.size() - 1:
		var a: Vector3 = pts[i]
		var b: Vector3 = pts[i + 1]
		var n: Vector3 = _normal(a, b) * side
		var length: float = a.distance_to(b)
		var steps: int = maxi(1, ceili(length / 0.5))
		# On the inner side of a corner the mitre lies d[-1] back along the segment: stop samples short of it.
		var keep_from: float = d[-1] + 0.05 if i > 0 and _turn(pts[i - 1], a, b) * side > 0.0 else 0.0
		var keep_to: float = length - d[-1] - 0.05 if i < pts.size() - 2 and _turn(a, b, pts[i + 2]) * side > 0.0 else length
		for k: int in steps + 1:
			var at: float = length * k / steps
			if (k == 0 and i > 0) or (k == steps and i < pts.size() - 2) or at < keep_from or at > keep_to:
				continue  # corners are added below
			sections.append([_cross(a.lerp(b, float(k) / steps), n, d), v + at])
		v += length
		if i < pts.size() - 2:
			var n2: Vector3 = _normal(b, pts[i + 2]) * side
			if _turn(a, b, pts[i + 2]) * side > 0.0:
				sections.append([_cross(b, n + n2, d), v])  # inner side: offsets meet at the mitre (exact at 90 deg)
			else:
				for k: int in 9:
					sections.append([_cross(b, n.slerp(n2, k / 8.0).normalized(), d), v])
	var st: SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for s: int in sections.size():
		var base: PackedVector3Array = sections[s][0]
		var along: float = sections[s][1]
		for k: int in d.size():
			var y: float = h[k]
			if jitter > 0.0 and h[k] > 0.05:
				y += jitter * sin(along * 1.7 + side * 2.0 + k) * sin(along * 0.63 + k * 1.3)
			st.set_uv(Vector2(float(k) / (d.size() - 1), along))
			st.add_vertex(base[k] + Vector3.UP * y)
	var row: int = d.size()
	for s: int in sections.size() - 1:
		for k: int in row - 1:
			var i0: int = s * row + k
			var quad: Array[int] = [i0, i0 + row, i0 + 1, i0 + 1, i0 + row, i0 + row + 1]
			if side < 0.0:
				quad = [i0, i0 + 1, i0 + row, i0 + 1, i0 + row + 1, i0 + row]
			for idx: int in quad:
				st.add_index(idx)
	st.generate_normals()
	var node: MeshInstance3D = MeshInstance3D.new()
	node.mesh = st.commit()
	node.material_override = material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(node)


func _cross(p: Vector3, dir: Vector3, d: PackedFloat32Array) -> PackedVector3Array:
	var out: PackedVector3Array = PackedVector3Array()
	for x: float in d:
		out.append(p + dir * x)
	return out


## > 0 when the route turns left (toward +normal) at b.
func _turn(a: Vector3, b: Vector3, c: Vector3) -> float:
	return _normal(a, b).dot(c - b)


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
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF  # flat trims/props: shadows cost more than they show
	node.position = pos
	node.rotation.y = yaw
	add_child(node)
	return node


func _normal(a: Vector3, b: Vector3) -> Vector3:
	var t: Vector3 = (b - a).normalized()
	return Vector3(-t.z, 0.0, t.x)


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


## The Pond blocker becomes an organic frozen rink (Dev 13). The logical blocker box stays (placement reads its
## BoxMesh) but is hidden; the ice shoreline covers the whole blocked rectangle (never inside its corners) and a snowy
## rim rings it, so no buildable-looking snow rejects a placement. Two curling stones and a painted ring.
func _rink(pond: MeshInstance3D) -> void:
	pond.visible = false
	var half: Vector3 = (pond.mesh as BoxMesh).size / 2.0
	var c: Vector3 = Vector3(pond.position.x, 0.0, pond.position.z)
	var shore: PackedVector2Array = PackedVector2Array()
	for k: int in 48:
		var a: float = TAU * k / 48.0
		var dir: Vector2 = Vector2(cos(a), sin(a))
		# superellipse (power 4) whose 45-degree points pass 0.12 m outside the corners; the wobble only grows it
		var se: float = pow(pow(absf(dir.x) / half.x, 4.0) + pow(absf(dir.y) / half.z, 4.0), -0.25)
		shore.append(dir * se * (1.0 / pow(0.5, 0.25) * 1.0 + 0.12 / half.x) * (1.0 + 0.04 * (1.0 + sin(a * 3.0 + 1.0) * sin(a * 5.0))))
	var st: SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_normal(Vector3.UP)
	for k: int in shore.size():
		var p0: Vector2 = shore[k]
		var p1: Vector2 = shore[(k + 1) % shore.size()]
		for p: Vector2 in [Vector2.ZERO, p0, p1]:
			st.set_uv(p)
			st.add_vertex(c + Vector3(p.x, 0.045, p.y))
	var ice: MeshInstance3D = MeshInstance3D.new()
	ice.mesh = st.commit()
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = ICE_SHADER
	material.set_shader_parameter(&"detail", DETAIL)
	material.set_shader_parameter(&"shore_radius", shore[0].length())
	ice.material_override = material
	ice.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(ice)
	# Snowy rim: a low bank around the shoreline (closed ribbon).
	var rim: SurfaceTool = SurfaceTool.new()
	rim.begin(Mesh.PRIMITIVE_TRIANGLES)
	var profile: Array = [[-0.05, 0.05], [0.15, 0.17], [0.38, 0.12], [0.62, 0.0]]
	for k: int in shore.size() + 1:
		var p: Vector2 = shore[k % shore.size()]
		var out: Vector2 = p.normalized()
		for q: Array in profile:
			var at: Vector2 = p + out * q[0]
			var y: float = q[1] * (1.0 + 0.3 * sin(k * 1.9)) if q[1] > 0.06 else q[1]
			rim.set_uv(at)
			rim.add_vertex(c + Vector3(at.x, y, at.y))
	var n: int = profile.size()
	for k: int in shore.size():
		for j: int in n - 1:
			var i0: int = k * n + j
			for idx: int in [i0, i0 + 1, i0 + n, i0 + 1, i0 + n + 1, i0 + n]:
				rim.add_index(idx)
	rim.generate_normals()
	var rim_node: MeshInstance3D = MeshInstance3D.new()
	rim_node.mesh = rim.commit()
	rim_node.material_override = _snow
	rim_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(rim_node)
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
		var count: int = int(area.get_area() / 14.0)  # density tuned for Web (Dev 12 stress)
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
		cone.radial_segments = 6
		cone.material = _mat(tier[3])
		_multi(cone, xforms, Vector3.UP * (tier[2] + tier[1] / 2.0 - 0.2), tier[3] == PINE_DARK)  # one shadow tier per pine


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


func _multi(mesh: Mesh, xforms: Array[Transform3D], local_offset: Vector3, shadows: bool = false) -> void:
	var mm: MultiMesh = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = xforms.size()
	for i: int in xforms.size():
		var x: Transform3D = xforms[i]
		mm.set_instance_transform(i, Transform3D(x.basis, x.origin + x.basis * local_offset))
	var node: MultiMeshInstance3D = MultiMeshInstance3D.new()
	node.multimesh = mm
	if not shadows:
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(node)
