extends SubViewportContainer
## Menu showcase (DEC-053): Camel Claus pokes in from the right screen edge, leaning in, bobbing and peeking, in a
## separate transparent world beside the orbiting village. (Node/script keep the old Rookie name for scene stability.)
## The camera looks toward +Z, so world -X is screen-right and a negative rotation.z leans the camel's top to the left.

const MODEL: PackedScene = preload("res://assets/models/camel_claus.glb")
const SCALE: float = 2.0
## Rest pose: pushed past the right edge (x), feet below the frame (y), turned toward the menu (yaw) and leaning in.
const BASE: Vector3 = Vector3(-1.05, -0.95, 0.0)
const YAW: float = -0.45
const LEAN: float = -0.22
var model: Node3D
var elapsed: float = 0.0
var reduced_motion: bool = false
var portrait_camera: Camera3D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	stretch = true
	# DEC-052: full-resolution render (the DEC-049 1/3-res nearest pixel finish was removed by the owner).
	var viewport: SubViewport = SubViewport.new()
	viewport.name = "PortraitViewport"
	viewport.size = Vector2i(420, 540)
	viewport.transparent_bg = true
	viewport.own_world_3d = true
	viewport.gui_disable_input = true
	viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	add_child(viewport)
	var world: Node3D = Node3D.new()
	viewport.add_child(world)
	model = MODEL.instantiate()
	model.scale = Vector3.ONE * SCALE
	world.add_child(model)
	_pose(0.0, false)
	var environment: WorldEnvironment = WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color("c8dfed")
	environment.environment.ambient_light_energy = 0.55
	world.add_child(environment)
	var key: DirectionalLight3D = DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-30, -155, 0)
	key.light_energy = 0.8
	world.add_child(key)
	var camera: Camera3D = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 3.8
	world.add_child(camera)
	camera.position = Vector3(0, 1.5, -6)
	camera.look_at(Vector3(0, 1.25, 0))
	portrait_camera = camera
	resized.connect(_fit_camera)
	_fit_camera()
	if OS.has_feature("web"):
		reduced_motion = bool(JavaScriptBridge.eval("window.matchMedia('(prefers-reduced-motion: reduce)').matches"))


func _fit_camera() -> void:
	if portrait_camera:
		portrait_camera.size = maxf(3.8, 2.2 * size.y / maxf(size.x, 1.0))


func _process(delta: float) -> void:
	if not is_instance_valid(model) or not is_visible_in_tree() or reduced_motion:
		return
	elapsed += delta
	_pose(elapsed, true)


func _pose(t: float, animate: bool) -> void:
	var k: float = 1.0 if animate else 0.0
	var peek: float = sin(t * 0.7)  # slow lean in and back out
	model.position = BASE + Vector3(0.12 * peek, 0.06 * sin(t * 2.1), 0.0) * k
	model.rotation = Vector3(0.0, YAW + 0.18 * sin(t * 0.55) * k, LEAN + 0.07 * peek * k)
