extends Node3D
## lumoize's Christmas village, menu-only. Original animated FBX -> prepared GLB.
## Camera always looks toward the tree at world XZ (0, 0); no match state is involved.

const VILLAGE: PackedScene = preload("res://assets/models/menu/christmas_village.glb")

@export_range(45.0, 95.0, 1.0) var field_of_view_degrees: float = 72.0
@export_range(6.0, 24.0, 0.5) var orbit_radius_m: float = 12.0
@export_range(3.0, 16.0, 0.5) var camera_height_m: float = 6.5
@export var look_at_height_m: float = 3.2
@export_range(0.0, 8.0, 0.1) var orbit_speed_degrees: float = 2.0
@export var starting_angle_degrees: float = 28.0
## Keep snow/ice below clipping in the Web Compatibility renderer.
@export_range(0.0, 2.0, 0.05) var sun_energy: float = 0.7
@export_range(0.0, 1.0, 0.05) var ambient_energy: float = 0.35
@export var fog_start_m: float = 16.0
@export var fog_end_m: float = 44.0

var camera: Camera3D
var animation_player: AnimationPlayer
var orbit_angle: float = 0.0


func _ready() -> void:
	var village: Node3D = VILLAGE.instantiate()
	village.name = "ChristmasVillage"
	add_child(village)
	animation_player = village.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if animation_player:
		for clip_name: StringName in animation_player.get_animation_list():
			if clip_name != &"RESET":
				animation_player.get_animation(clip_name).loop_mode = Animation.LOOP_LINEAR
				animation_player.play(clip_name)
				break
	var environment: Environment = Environment.new()
	var sky_material: ProceduralSkyMaterial = ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("739bb8")
	sky_material.sky_horizon_color = Color("c9dce6")
	sky_material.ground_horizon_color = Color("c9dce6")
	sky_material.ground_bottom_color = Color("9db6c5")
	sky_material.sky_curve = 0.5
	sky_material.ground_curve = 0.12
	sky_material.sun_angle_max = 0.0
	var sky: Sky = Sky.new()
	sky.sky_material = sky_material
	environment.sky = sky
	environment.background_mode = Environment.BG_SKY
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("d7e3ed")
	environment.ambient_light_energy = ambient_energy
	environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	# Depth fog leaves the central tree/rink clear and softens the far forest/edge.
	# Traditional fog works in Web Compatibility; no volumetric rendering needed.
	environment.fog_enabled = true
	environment.fog_mode = Environment.FOG_MODE_DEPTH
	environment.fog_light_color = Color("c9dce6")
	environment.fog_light_energy = 1.0
	environment.fog_density = 1.0
	environment.fog_depth_begin = fog_start_m
	environment.fog_depth_end = fog_end_m
	environment.fog_depth_curve = 1.2
	environment.fog_sky_affect = 0.25
	var world: WorldEnvironment = WorldEnvironment.new()
	world.name = "WinterEnvironment"
	world.environment = environment
	add_child(world)
	# Continue the snow below the diorama instead of exposing its finite island edge.
	var horizon: MeshInstance3D = MeshInstance3D.new()
	horizon.name = "SnowHorizon"
	var snow_plane: PlaneMesh = PlaneMesh.new()
	snow_plane.size = Vector2(450, 450)
	var snow_material: StandardMaterial3D = StandardMaterial3D.new()
	snow_material.albedo_color = Color("dce6ed")
	snow_material.roughness = 0.95
	snow_plane.material = snow_material
	horizon.mesh = snow_plane
	horizon.position.y = -0.65
	horizon.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(horizon)
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.name = "WinterSun"
	sun.rotation_degrees = Vector3(-45, -30, 0)
	sun.light_color = Color("fff7eb")
	sun.light_energy = sun_energy
	sun.shadow_enabled = true
	add_child(sun)
	camera = Camera3D.new()
	camera.name = "OrbitCamera"
	camera.current = true
	camera.near = 0.1
	camera.far = 130.0
	add_child(camera)
	orbit_angle = deg_to_rad(starting_angle_degrees)
	update_camera()


func _process(delta: float) -> void:
	orbit_angle = fposmod(orbit_angle + deg_to_rad(orbit_speed_degrees) * delta, TAU)
	update_camera()


func update_camera() -> void:
	if camera == null:
		return
	camera.fov = field_of_view_degrees
	camera.position = Vector3(sin(orbit_angle) * orbit_radius_m, camera_height_m,
			cos(orbit_angle) * orbit_radius_m)
	camera.look_at(Vector3(0, look_at_height_m, 0))
