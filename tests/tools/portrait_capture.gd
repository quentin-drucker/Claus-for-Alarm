extends SceneTree
## Dev 13: batch-render shop/detail portraits from the real runtime tower scenes (needs a window, not --headless):
##   godot --path . -s res://tests/tools/portrait_capture.gd
## Writes assets/ui/portraits/<id>.png (transparent, 256 px). Same lights and lens for every model; characters are
## framed torso-up (slight three-quarter), the Cannon and the Booth as whole objects.

const OUT: String = "res://assets/ui/portraits/"
const SIZE: int = 256
## id -> [fraction of the model height to frame from the top, yaw of the camera around the model (deg)]
const FRAMING: Dictionary = {
	&"snowball_rookie": [0.62, 28.0], &"slope_wax_sprayer": [0.62, 28.0], &"snow_sorcerer": [0.6, 24.0],
	&"biathlon_ranger": [0.6, 28.0], &"avalanche_cannon": [1.0, 35.0], &"ski_resort_ticket_booth": [1.0, 30.0],
	&"camel_claus": [0.55, 24.0],
}


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var content: Node = root.get_node("Content")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var vp: SubViewport = SubViewport.new()
	vp.size = Vector2i(SIZE, SIZE)
	vp.transparent_bg = true
	vp.own_world_3d = true
	vp.msaa_3d = Viewport.MSAA_4X
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var env: WorldEnvironment = WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_CLEAR_COLOR
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("dfe9f2")
	env.environment.ambient_light_energy = 0.55
	vp.add_child(env)
	for spec: Array in [[Vector3(-35, -30, 0), 1.0, Color("fff3e0")], [Vector3(-15, 140, 0), 0.35, Color("bcd6ff")]]:
		var light: DirectionalLight3D = DirectionalLight3D.new()
		light.rotation_degrees = spec[0]
		light.light_energy = spec[1]
		light.light_color = spec[2]
		vp.add_child(light)
	var cam: Camera3D = Camera3D.new()
	cam.fov = 18.0
	vp.add_child(cam)
	var scene: PackedScene = load("res://scenes/towers/tower.tscn")
	var defs: Array = content.towers.duplicate()
	defs.append(content.hero)
	for def: Resource in defs:
		var tower: Node3D = scene.instantiate()
		vp.add_child(tower)
		tower.setup(def, 1)
		for n: Node in tower.find_children("*", "", true, false):
			if n is Label3D or n.name == "Range" or n.name == "Body":
				(n as Node3D).visible = false
		for k: int in 4:
			await process_frame
		var box: AABB = _bounds(tower)
		var spec: Array = FRAMING.get(def.id, [1.0, 30.0])
		var top: float = box.end.y
		var bottom: float = top - box.size.y * spec[0]
		var target: Vector3 = Vector3(box.get_center().x, (top + bottom) / 2.0, box.get_center().z)
		var half: float = maxf((top - bottom) / 2.0, maxf(box.size.x, box.size.z) * 0.5 * (0.75 if spec[0] < 1.0 else 1.0)) * 1.32
		var dist: float = half / tan(deg_to_rad(cam.fov / 2.0))
		var yaw: float = deg_to_rad(spec[1])
		cam.position = target + Vector3(sin(yaw), 0.14, cos(yaw)).normalized() * dist  # the placed tower faces +Z (toward the game camera)
		cam.look_at(target)
		for k: int in 3:
			await process_frame
		await RenderingServer.frame_post_draw
		var img: Image = vp.get_texture().get_image()
		img.save_png(OUT + String(def.id) + ".png")
		print("portrait %s  box %s" % [def.id, box])
		tower.queue_free()
		await process_frame
	quit(0)


func _bounds(node: Node3D) -> AABB:
	var out: AABB = AABB()
	var first: bool = true
	for n: Node in node.find_children("*", "VisualInstance3D", true, false):
		var v: VisualInstance3D = n as VisualInstance3D
		if not v.is_visible_in_tree() or v is Light3D:
			continue
		var b: AABB = v.global_transform * v.get_aabb()
		out = b if first else out.merge(b)
		first = false
	return out
