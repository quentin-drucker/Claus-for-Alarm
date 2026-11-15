extends RefCounted
## Dev 13 attack feedback, presentation only (the simulation never reads it). One look per damage family so every
## tower reads differently: snowball (sharp), ice chunk (shatter), cannon shell (explosion), frost bolt (energy),
## fireball (plasma), wax glob (glue); a matching expanding impact burst; a tracer for instant hits; the Wall of Fire
## zone. Meshes/materials are built once and shared; every effect frees itself.

## damage_type -> [radius m, colour, glowing (unshaded)]
const SHOTS: Dictionary[StringName, Array] = {
	&"sharp": [0.12, Color("f4f8fb"), false], &"shatter": [0.2, Color("bfe6f5"), false],
	&"explosion": [0.17, Color("2e3a48"), false], &"energy": [0.13, Color("7fe3ff"), true],
	&"plasma": [0.15, Color("ff8a2a"), true], &"glue": [0.12, Color("e2b04a"), false],
}
## damage_type -> impact burst colour (alpha = start opacity).
const BURSTS: Dictionary[StringName, Color] = {
	&"explosion": Color(1.0, 0.72, 0.38, 0.75), &"plasma": Color(1.0, 0.5, 0.15, 0.7),
	&"energy": Color(0.5, 0.9, 1.0, 0.6), &"glue": Color(0.93, 0.74, 0.3, 0.6),
}
const ICE_BURST: Color = Color(0.86, 0.95, 1.0, 0.65)

static var _meshes: Dictionary[StringName, Mesh] = {}
static var _materials: Dictionary[String, StandardMaterial3D] = {}
static var _disc: CylinderMesh
static var _puff: SphereMesh
static var _beam: BoxMesh
static var _flame: CylinderMesh


static func material(color: Color, glow: bool = true) -> StandardMaterial3D:
	var key: String = "%s|%s" % [color, glow]
	if not _materials.has(key):
		var m: StandardMaterial3D = StandardMaterial3D.new()
		m.albedo_color = color
		if glow:
			m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		else:
			m.roughness = 0.45
		if color.a < 1.0:
			m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_materials[key] = m
	return _materials[key]


## Projectile mesh for an attack, by damage family (fallback: snowball).
static func shot_mesh(attack: Resource) -> Mesh:
	var kind: StringName = attack.damage_type if SHOTS.has(attack.damage_type) else &"sharp"
	if not _meshes.has(kind):
		var spec: Array = SHOTS[kind]
		var sphere: SphereMesh = SphereMesh.new()
		sphere.radius = spec[0]
		sphere.height = spec[0] * 2.0
		sphere.radial_segments = 10
		sphere.rings = 5
		sphere.material = material(spec[1], spec[2])
		_meshes[kind] = sphere
	return _meshes[kind]


## Expanding, fading impact disc + puff at a hit or explosion, coloured by damage family.
static func burst(parent: Node3D, center: Vector3, radius: float, damage_type: StringName) -> void:
	_init_meshes()
	var color: Color = BURSTS.get(damage_type, ICE_BURST)
	var r: float = maxf(radius, 0.25)
	var root: Node3D = Node3D.new()
	root.position = Vector3(center.x, 0.0, center.z)
	parent.add_child(root)
	var disc: MeshInstance3D = _part(root, _disc, material(Color(color, color.a * 0.6)), Vector3.UP * 0.12)
	var puff: MeshInstance3D = _part(root, _puff, material(color.lightened(0.35)), Vector3.UP * 0.45)
	disc.scale = Vector3(r * 0.4, 1.0, r * 0.4)
	puff.scale = Vector3.ONE * minf(r, 0.6) * 0.3
	var t: Tween = root.create_tween().set_parallel().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(disc, ^"scale", Vector3(r, 1.0, r), 0.2)
	t.tween_property(disc, ^"transparency", 1.0, 0.24)
	t.tween_property(puff, ^"scale", Vector3.ONE * minf(r, 0.6) * 0.85, 0.2)
	t.tween_property(puff, ^"transparency", 1.0, 0.22)
	t.chain().tween_callback(root.queue_free)


## Brief bright streak for instant hits (Biathlon Ranger), muzzle to target or bounce to bounce.
static func tracer(parent: Node3D, from: Vector3, to: Vector3) -> void:
	if from.distance_to(to) < 0.05:
		return
	if _beam == null:
		_beam = BoxMesh.new()
		_beam.size = Vector3(0.05, 0.05, 1.0)
	var node: MeshInstance3D = _part(parent, _beam, material(Color(1.0, 0.93, 0.7, 0.9)), (from + to) / 2.0)
	node.look_at_from_position(node.position, to, Vector3.UP if absf((to - from).normalized().y) < 0.99 else Vector3.RIGHT)
	node.scale = Vector3(1.0, 1.0, from.distance_to(to))
	var t: Tween = node.create_tween()
	t.tween_property(node, ^"transparency", 1.0, 0.1)
	t.tween_callback(node.queue_free)


## Wall of Fire zone: a glowing ember disc and a ring of flames; animate_zone() flickers and fades it.
static func fire_zone(radius: float) -> Node3D:
	_init_meshes()
	var root: Node3D = Node3D.new()
	var disc: MeshInstance3D = _part(root, _disc, material(Color(1.0, 0.42, 0.12, 0.45)), Vector3.UP * 0.06)
	disc.scale = Vector3(radius, 1.0, radius)
	for i: int in 7:
		var a: float = TAU * i / 6.0
		var at: Vector3 = Vector3.ZERO if i == 6 else Vector3(cos(a), 0.0, sin(a)) * radius * 0.62
		var color: Color = Color(1.0, 0.82, 0.3, 0.9) if i % 2 == 0 else Color(1.0, 0.45, 0.12, 0.9)
		_part(root, _flame, material(color), at + Vector3.UP * 0.3).name = "Flame%d" % i
	return root


## `left` = remaining fraction (1 -> 0); `t` = simulation seconds (flicker follows pause and speed).
static func animate_zone(node: Node3D, left: float, t: float) -> void:
	node.scale = Vector3.ONE * clampf(minf(left * 6.0, (1.0 - left) * 12.0 + 0.3), 0.0, 1.0)
	for i: int in 7:
		var flame: Node3D = node.get_node(NodePath("Flame%d" % i))
		var k: float = 0.65 + 0.35 * sin(t * 13.0 + i * 1.7) * sin(t * 7.0 + i)
		flame.scale = Vector3(1.0, k, 1.0)
		flame.position.y = 0.3 * k


static func _init_meshes() -> void:
	if _disc != null:
		return
	_disc = CylinderMesh.new()
	_disc.top_radius = 1.0
	_disc.bottom_radius = 1.0
	_disc.height = 0.04
	_disc.radial_segments = 24
	_disc.rings = 1
	_puff = SphereMesh.new()
	_puff.radius = 1.0
	_puff.height = 1.4
	_puff.radial_segments = 10
	_puff.rings = 5
	_flame = CylinderMesh.new()
	_flame.top_radius = 0.0
	_flame.bottom_radius = 0.14
	_flame.height = 0.6
	_flame.radial_segments = 6
	_flame.rings = 1


static func _part(parent: Node3D, mesh: Mesh, mat: Material, pos: Vector3) -> MeshInstance3D:
	var node: MeshInstance3D = MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = mat
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	node.position = pos
	parent.add_child(node)
	return node
