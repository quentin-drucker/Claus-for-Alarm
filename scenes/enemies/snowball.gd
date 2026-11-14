extends Node3D
## Greybox snowball. Holds simulation state only; the Match moves and damages it on simulation ticks.

## Layer colours (A-01 enemy swatches) — presentation only, never read by the simulation.
const COLORS: Dictionary[StringName, Color] = {
	&"powder": Color("dbe9f5"), &"blue": Color("72cef5"), &"mint": Color("4acaaa"),
	&"violet": Color("bd8df1"), &"coral": Color("f59471"),
	# Neutral placeholders for the specials (no art decision): plain dark / white / purple.
	&"black": Color("262626"), &"white": Color("ffffff"), &"purple": Color("7a3fd6"),
}
## Placeholder letter marker for special types, so they read without colour (P13-T09). Camo adds "C".
const MARKERS: Dictionary[StringName, String] = {&"black": "B", &"white": "W", &"purple": "P"}
## Dark outline so pale Powder still reads on snow (P05-T10); shared by every layer.
const OUTLINE: Color = Color("173548")
## P15 art: one shared shell (vertex-colour AO, tinted per layer) and one marker band with material variants.
const SHELL_SCENE: PackedScene = preload("res://assets/models/snowball_shell.glb")
const MARKER_SCENE: PackedScene = preload("res://assets/models/snowball_marker.glb")
const MARKER_COLORS: Dictionary[StringName, Color] = {
	&"black": Color("2b2f36"), &"white": Color("f7fbff"), &"purple": Color("7a3fd6"), &"camo": Color("b8c9c4"),
}
const RADIUS_M: float = 0.4
## Meshes pulled out of the GLBs once; one material per layer/marker type, shared by every snowball.
static var _meshes: Dictionary[PackedScene, Mesh] = {}
static var _materials: Dictionary[StringName, Material] = {}

var def: EnemyDefinition
var entity_id: int = 0
## Ids this snowball had before multi-child splits (a split gives every child a fresh id). A shot that hit any
## of them never hits this snowball: children are safe from the hit that made them.
var ancestors: Array[int] = []
## Metres travelled along the track from the entry.
var distance: float = 0.0
## Wax status: fraction of speed removed, seconds left, and whether it survives layer breaks (Glue Soak).
var slow_factor: float = 0.0
var slow_left: float = 0.0
var slow_soaks: bool = false
## Corrosive wax: layers lost every `dot_interval` s while the wax lasts; `dot_source` gets the pop credit.
var dot_damage: int = 0
var dot_interval: float = 0.0
var dot_timer: float = 0.0
var dot_source: int = 0
## Presentation only: last drawn position, for the roll.
var _last_pos: Vector3 = Vector3.INF


func setup(definition: EnemyDefinition, id: int) -> void:
	entity_id = id
	set_layer(definition)


## Speed in reference units/s after the wax status.
func current_speed() -> float:
	return def.speed_units * (1.0 - slow_factor if slow_left > 0.0 else 1.0)


## A stronger or equal wax replaces the current one and refreshes its time; a weaker one is ignored (no stacking).
func apply_slow(factor: float, duration: float, soaks: bool, attack: AttackDefinition = null, source_id: int = 0) -> void:
	if slow_left > 0.0 and factor < slow_factor:
		return
	slow_factor = factor
	slow_left = duration
	slow_soaks = soaks
	var damage: int = attack.dot_damage if attack else 0
	if damage != dot_damage or (attack and attack.dot_interval_s != dot_interval):
		dot_timer = attack.dot_interval_s if attack else 0.0  # a new corrosion starts its own clock; a refresh keeps it
	dot_damage = damage
	dot_interval = attack.dot_interval_s if attack else 0.0
	dot_source = source_id


## Current outer layer; a break swaps it in place, keeping id, distance and position.
func set_layer(definition: EnemyDefinition) -> void:
	def = definition
	var camo: bool = &"camo" in def.properties
	var base: StringName = StringName(String(def.id).trim_prefix("camo_"))
	$Mesh.mesh = _mesh(SHELL_SCENE)
	$Mesh.material_override = _material(base, COLORS.get(base, Color.WHITE), true)
	var kind: StringName = &"camo" if camo else def.id
	var band: MeshInstance3D = $Mesh.get_node_or_null(^"Band")
	if band == null and MARKER_COLORS.has(kind):
		band = MeshInstance3D.new()
		band.name = "Band"
		band.mesh = _mesh(MARKER_SCENE)
		$Mesh.add_child(band)
	if band:
		band.visible = MARKER_COLORS.has(kind)
		band.material_override = _material(StringName("marker_" + kind), MARKER_COLORS.get(kind, Color.WHITE), false)
	var text: String = MARKERS.get(def.id, "") + ("C" if camo else "")
	var marker: Label3D = get_node_or_null(^"Marker")
	if marker == null and text != "":
		marker = Label3D.new()
		marker.name = "Marker"
		marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		marker.no_depth_test = true
		marker.font_size = 64
		marker.pixel_size = 0.01  # ~0.6 m letter on a 0.8 m snowball
		marker.outline_size = 16
		marker.position = Vector3.UP * 0.9
		add_child(marker)
	if marker:
		marker.text = text


## Presentation only: roll the shell about the axis across its travel (B-07), never read by the simulation.
func _process(_delta: float) -> void:
	var step: Vector3 = position - _last_pos
	_last_pos = position
	step.y = 0.0
	if step.length() > 1e-4 and step.length() < 2.0:
		var basis: Basis = Basis(Vector3.UP.cross(step.normalized()), step.length() / RADIUS_M) * $Mesh.basis
		$Mesh.basis = basis.orthonormalized()


static func _mesh(scene: PackedScene) -> Mesh:
	if not _meshes.has(scene):
		var node: Node = scene.instantiate()
		_meshes[scene] = (node.get_child(0) as MeshInstance3D).mesh
		node.free()
	return _meshes[scene]


## Shell materials multiply the baked vertex-colour AO by the layer tint; all get the shared dark outline.
static func _material(key: StringName, color: Color, shell: bool) -> Material:
	if not _materials.has(key):
		var outline: StandardMaterial3D = StandardMaterial3D.new()
		outline.albedo_color = OUTLINE
		outline.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		outline.cull_mode = BaseMaterial3D.CULL_FRONT
		outline.grow = true
		outline.grow_amount = 0.03 if shell else 0.015
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = color
		material.vertex_color_use_as_albedo = shell
		material.roughness = 0.75 if shell else 0.4
		if key == &"marker_purple":
			material.emission_enabled = true
			material.emission = color
			material.emission_energy_multiplier = 0.6
		material.next_pass = outline
		_materials[key] = material
	return _materials[key]
