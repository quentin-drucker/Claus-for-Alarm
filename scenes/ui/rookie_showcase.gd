extends SubViewportContainer
## Menu-only remodeled Rookie; a separate transparent world stays fixed beside the orbiting village.

const MODEL: PackedScene = preload("res://assets/models/menu/rookie_showcase.glb")
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
	world.add_child(model)
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
	if not is_instance_valid(model) or not is_visible_in_tree():
		return
	elapsed += delta
	if reduced_motion:
		return
	model.position.y = 0.07 * sin(elapsed * 1.7)
	model.rotation.y = 0.12 + 0.22 * sin(elapsed * 0.65)
	model.rotation.z = 0.025 * sin(elapsed * 1.3)
